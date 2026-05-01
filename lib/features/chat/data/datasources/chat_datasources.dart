import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:financo/core/errors/exceptions.dart' as app;
import 'package:financo/features/chat/data/models/chat_message_model.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';

/// Contract for sending a message through the backend chat pipeline.
abstract class ChatBackendDataSource {
  Future<ChatMessageModel> sendMessage({
    required String userId,
    required String content,
    required List<ChatMessageEntity> history,
    ChatImageAttachment? image,
  });

  Future<String> transcribeAudio({
    required String base64Data,
    required String mimeType,
  });
}

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getChatHistory({required String userId});
  Future<void> saveChatMessage(ChatMessageModel message);
}

// Strips app-generated assistant messages (action results, e.g.
// "Transaction X created successfully!") before sending the history to the
// AI. Without this, Gemini mimics the pattern in subsequent turns —
// emitting fake success text without the [TRANSACTION_DATA] block, which
// produces bubbles with no action card and no actual write to Firestore.
//
// Two-pronged: the metadata tag handles new messages, while the regex
// covers messages persisted before the tag existed (legacy data already in
// the user's Firestore history).
bool _shouldSendToAi(ChatMessageEntity m) {
  final kind = m.metadata?['kind'];
  if (kind == 'actionResult' || kind == 'actionRejected') return false;
  if (m.role == ChatRole.assistant &&
      _legacyResultPattern.hasMatch(m.content)) {
    return false;
  }
  return true;
}

final RegExp _legacyResultPattern = RegExp(
  '^(Transaction|Account|Category|Bill|Transação|Conta|Categoria) '
  '.*(created successfully|deleted successfully|updated|paid|'
  'criada com sucesso|removida com sucesso|scheduled for)',
  caseSensitive: false,
);

// Reconstructs the action block (e.g. [TRANSACTION_DATA]{...}[/...]) from
// a saved assistant message's metadata before sending it back to Gemini.
//
// The Cloud Function strips action blocks from the response text before
// persisting (only metadata survives — see chat spec). Without this
// reconstruction, the AI sees its own past replies as plain
// "Pronto, confirma o gasto?" with no block, learns that pattern, and
// stops emitting the block in subsequent turns — producing bubbles with
// no action card and no actual write.
String _historyContent(ChatMessageEntity m) {
  final meta = m.metadata;
  if (meta == null) return m.content;
  final actionType = meta['actionType'] as String?;
  if (actionType == null) return m.content;
  final tag = _actionTag(actionType);
  if (tag == null) return m.content;
  final data = Map<String, dynamic>.from(meta)
    ..remove('actionType')
    ..remove('kind');
  return '${m.content}\n[$tag]\n${jsonEncode(data)}\n[/$tag]';
}

String? _actionTag(String actionType) => switch (actionType) {
  'transaction' => 'TRANSACTION_DATA',
  'account' => 'ACCOUNT_ACTION',
  'category' => 'CATEGORY_ACTION',
  'bill' => 'BILL_ACTION',
  _ => null,
};

class ChatBackendDataSourceImpl implements ChatBackendDataSource {
  ChatBackendDataSourceImpl({required FirebaseFunctions functions})
    : _callable = functions.httpsCallable('chatSend'),
      _transcribeCallable = functions.httpsCallable('transcribeChatAudio');

  final HttpsCallable _callable;
  final HttpsCallable _transcribeCallable;

  @override
  Future<ChatMessageModel> sendMessage({
    required String userId,
    required String content,
    required List<ChatMessageEntity> history,
    ChatImageAttachment? image,
  }) async {
    try {
      final filteredHistory = history.where(_shouldSendToAi).toList();
      final payload = <String, dynamic>{
        'content': content,
        'history': filteredHistory
            .map(
              (m) => {
                'role': m.role == ChatRole.user ? 'user' : 'assistant',
                'content': _historyContent(m),
              },
            )
            .toList(),
      };
      if (image != null) {
        payload['image'] = {
          'data': image.base64Data,
          'mimeType': image.mimeType,
        };
      }
      final response = await _callable.call<Map<Object?, Object?>>(payload);

      final data = Map<String, dynamic>.from(response.data);
      final id = data['id'] as String;
      final cleanText = data['content'] as String? ?? '';
      final rawMetadata = data['metadata'];
      final metadata = rawMetadata == null
          ? null
          : Map<String, dynamic>.from(rawMetadata as Map);

      return ChatMessageModel(
        id: id,
        userId: userId,
        role: ChatRole.assistant,
        content: cleanText,
        metadata: metadata,
        createdAt: DateTime.now(),
      );
    } on FirebaseFunctionsException catch (e, st) {
      log(
        'ChatBackendDataSource: FirebaseFunctionsException',
        name: 'ChatBackendDataSource',
        error: e,
        stackTrace: st,
      );
      throw app.AiException('AI processing failed: ${e.message ?? e.code}');
    } on Exception catch (e, st) {
      log(
        'ChatBackendDataSource: error',
        name: 'ChatBackendDataSource',
        error: e,
        stackTrace: st,
      );
      throw app.AiException('AI processing failed: $e');
    }
  }

  @override
  Future<String> transcribeAudio({
    required String base64Data,
    required String mimeType,
  }) async {
    try {
      final response = await _transcribeCallable.call<Map<Object?, Object?>>({
        'audio': {
          'data': base64Data,
          'mimeType': mimeType,
        },
      });
      final data = Map<String, dynamic>.from(response.data);
      return (data['transcript'] as String? ?? '').trim();
    } on FirebaseFunctionsException catch (e, st) {
      log(
        'ChatBackendDataSource: transcribe FirebaseFunctionsException',
        name: 'ChatBackendDataSource',
        error: e,
        stackTrace: st,
      );
      throw app.AiException('Transcription failed: ${e.message ?? e.code}');
    } on Exception catch (e, st) {
      log(
        'ChatBackendDataSource: transcribe error',
        name: 'ChatBackendDataSource',
        error: e,
        stackTrace: st,
      );
      throw app.AiException('Transcription failed: $e');
    }
  }
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ChatMessageModel>> getChatHistory({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('chat_messages')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt')
          .get();
      return snapshot.docs.map(ChatMessageModel.fromFirestore).toList();
    } on Exception {
      throw const app.ServerException('Failed to fetch chat history.');
    }
  }

  @override
  Future<void> saveChatMessage(ChatMessageModel message) async {
    try {
      await _firestore
          .collection('chat_messages')
          .doc(message.id)
          .set(message.toJson());
    } on Exception {
      throw const app.ServerException('Failed to save chat message.');
    }
  }
}
