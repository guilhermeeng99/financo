import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart' as app;
import 'package:financo/features/chat/data/models/chat_message_model.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

const geminiSystemPrompt = '''
You are a personal financial assistant. You help users manage their finances by creating transactions, accounts, and categories through natural conversation.

Rules:
1. Always respond in the same language the user wrote to you.
2. Never fabricate data — ask the user if unsure.
3. Use ISO 8601 format for dates. The currency is BRL (Brazilian Real).

You can perform the following ACTIONS. When the user asks to create, edit, or delete something, extract the data and return the appropriate JSON block:

=== TRANSACTIONS ===
[TRANSACTION_DATA]
{"type": "expense|income", "amount": 45.00, "category": "Food", "date": "2026-04-10", "description": "Lunch"}
[/TRANSACTION_DATA]

=== ACCOUNTS ===
To create an account, ALWAYS ask the user:
1. The account nickname (apelido)
2. The bank name (e.g. Nubank, Itaú, Bradesco, Inter, etc.)
3. Whether it is a checking account or credit card (conta corrente ou cartão de crédito)
4. The current balance
5. For credit cards only: credit limit, closing day, and due day

Once all info is collected, return:
[ACCOUNT_ACTION]
{"action": "create", "name": "Nubank Gui", "type": "checking|creditCard", "bank": "Nubank", "balance": 0.0}
[/ACCOUNT_ACTION]

To delete an account (ask user to confirm by nickname):
[ACCOUNT_ACTION]
{"action": "delete", "name": "Nubank Gui"}
[/ACCOUNT_ACTION]

=== CATEGORIES ===
To create a category:
[CATEGORY_ACTION]
{"action": "create", "name": "Groceries", "type": "expense|income|both", "color": 4294198070, "icon": 58332}
[/CATEGORY_ACTION]

To delete a category (ask user to confirm by name):
[CATEGORY_ACTION]
{"action": "delete", "name": "Groceries"}
[/CATEGORY_ACTION]

Available Material icon codes: 59470 (account_balance), 59473 (account_balance_wallet), 58332 (shopping_cart), 58746 (restaurant), 58715 (directions_car), 58288 (home), 59545 (fitness_center), 58714 (local_hospital), 59494 (school), 58726 (flight), 58261 (work), 59560 (pets).

Available colors (as int): 4294198070 (red), 4294940672 (orange), 4294961979 (yellow), 4283215696 (green), 4280391411 (blue), 4284955975 (purple), 4288585374 (pink).

After each action block, add a friendly confirmation message asking the user to confirm.
''';

/// Abstraction for Gemini AI interaction — single method by design.
abstract class GeminiDataSource {
  Future<ChatMessageModel> sendMessage({
    required String userId,
    required String content,
    required List<ChatMessageEntity> history,
  });
}

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getChatHistory({required String userId});
  Future<void> saveChatMessage(ChatMessageModel message);
}

class GeminiDataSourceImpl implements GeminiDataSource {
  GeminiDataSourceImpl({required GenerativeModel model}) : _model = model;

  final GenerativeModel _model;
  static const _uuid = Uuid();

  @override
  Future<ChatMessageModel> sendMessage({
    required String userId,
    required String content,
    required List<ChatMessageEntity> history,
  }) async {
    try {
      final chatHistory = <Content>[
        // System prompt as first user turn + model ack to satisfy
        // the required user→model alternation in the history.
        Content.text(geminiSystemPrompt),
        Content('model', [
          TextPart('Understood. I will follow these guidelines.'),
        ]),
        ...history.map((msg) {
          return Content(
            msg.role == ChatRole.user ? 'user' : 'model',
            [TextPart(msg.content)],
          );
        }),
      ];

      final chat = _model.startChat(history: chatHistory);

      final response = await chat.sendMessage(Content.text(content));
      final responseText = response.text ?? 'Sorry, I could not process that.';

      Map<String, dynamic>? metadata;

      // Extract TRANSACTION_DATA
      final txMatch = RegExp(
        r'\[TRANSACTION_DATA\]\s*(.*?)\s*\[/TRANSACTION_DATA\]',
        dotAll: true,
      ).firstMatch(responseText);
      if (txMatch != null) {
        try {
          metadata = {
            'actionType': 'transaction',
            ...Map<String, dynamic>.from(
              _parseJson(txMatch.group(1)!),
            ),
          };
        } on Exception {
          // Metadata extraction failed — continue without it.
        }
      }

      // Extract ACCOUNT_ACTION
      final accMatch = RegExp(
        r'\[ACCOUNT_ACTION\]\s*(.*?)\s*\[/ACCOUNT_ACTION\]',
        dotAll: true,
      ).firstMatch(responseText);
      if (accMatch != null) {
        try {
          metadata = {
            'actionType': 'account',
            ...Map<String, dynamic>.from(
              _parseJson(accMatch.group(1)!),
            ),
          };
        } on Exception {
          // continue
        }
      }

      // Extract CATEGORY_ACTION
      final catMatch = RegExp(
        r'\[CATEGORY_ACTION\]\s*(.*?)\s*\[/CATEGORY_ACTION\]',
        dotAll: true,
      ).firstMatch(responseText);
      if (catMatch != null) {
        try {
          metadata = {
            'actionType': 'category',
            ...Map<String, dynamic>.from(
              _parseJson(catMatch.group(1)!),
            ),
          };
        } on Exception {
          // continue
        }
      }

      // Clean all action blocks from the display text.
      final cleanText = responseText
          .replaceAll(
            RegExp(
              r'\[(TRANSACTION_DATA|ACCOUNT_ACTION|CATEGORY_ACTION)\]'
              '.*?'
              r'\[/\1\]',
              dotAll: true,
            ),
            '',
          )
          .trim();

      return ChatMessageModel(
        id: _uuid.v4(),
        userId: userId,
        role: ChatRole.assistant,
        content: cleanText,
        metadata: metadata,
        createdAt: DateTime.now(),
      );
    } on Exception catch (e, st) {
      log(
        'GeminiDataSource: error',
        name: 'GeminiDataSource',
        error: e,
        stackTrace: st,
      );
      throw app.AiException('AI processing failed: $e');
    }
  }

  Map<String, dynamic> _parseJson(String text) {
    return jsonDecode(text) as Map<String, dynamic>;
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
