import 'dart:developer';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/action_handlers/account_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/budget_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/category_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/transaction_chat_action_handler.dart';
import 'package:financo/features/chat/domain/action_handlers/transfer_chat_action_handler.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/transcribe_audio_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatLoadRequested extends ChatEvent {
  const ChatLoadRequested();
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.content, {this.image, this.imageBytes});

  final String content;
  final ChatImageAttachment? image;

  /// Original image bytes from the picker, kept alongside the base64-encoded
  /// [image] so the user-bubble can render the thumbnail without re-decoding
  /// base64 on every rebuild. Always non-null when [image] is non-null.
  final Uint8List? imageBytes;

  @override
  List<Object?> get props => [content, image, imageBytes];
}

final class ChatActionConfirmed extends ChatEvent {
  const ChatActionConfirmed({
    required this.actionMessageId,
    required this.metadata,
  });

  /// Id of the AI proposal message whose Confirm button was tapped. Saved
  /// onto the result message as `originActionId` so the timeline can render
  /// the proposal card as "Confirmed" persistently (survives chat reload).
  final String actionMessageId;
  final Map<String, dynamic> metadata;

  @override
  List<Object> get props => [actionMessageId, metadata];
}

/// Transcribes the recorded audio and immediately sends the resulting
/// text as a regular user message. The user records, the transcript
/// appears as the user bubble, the AI confirms what it understood.
/// There is no separate review step.
final class ChatAudioTranscriptionRequested extends ChatEvent {
  const ChatAudioTranscriptionRequested({
    required this.base64Data,
    required this.mimeType,
  });

  final String base64Data;
  final String mimeType;

  @override
  List<Object> get props => [base64Data, mimeType];
}

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.messages,
    this.isTyping = false,
    this.shouldRefreshTransactions = false,
    this.shouldRefreshBudgets = false,
    this.isTranscribing = false,
  });

  final List<ChatMessageEntity> messages;
  final bool isTyping;
  final bool shouldRefreshTransactions;
  final bool shouldRefreshBudgets;
  final bool isTranscribing;

  @override
  List<Object?> get props => [
    messages,
    isTyping,
    shouldRefreshTransactions,
    shouldRefreshBudgets,
    isTranscribing,
  ];
}

final class ChatError extends ChatState {
  const ChatError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required SendMessageUseCase sendMessage,
    required GetChatHistoryUseCase getChatHistory,
    required SaveChatMessageUseCase saveChatMessage,
    required TranscribeAudioUseCase transcribeAudio,
    required AccountChatActionHandler accountHandler,
    required CategoryChatActionHandler categoryHandler,
    required TransactionChatActionHandler transactionHandler,
    required TransferChatActionHandler transferHandler,
    required BudgetChatActionHandler budgetHandler,
    required String userId,
  }) : _sendMessage = sendMessage,
       _getChatHistory = getChatHistory,
       _saveChatMessage = saveChatMessage,
       _transcribeAudio = transcribeAudio,
       _handlers = {
         'account': accountHandler,
         'category': categoryHandler,
         'transaction': transactionHandler,
         'transfer': transferHandler,
         'budget': budgetHandler,
       },
       _userId = userId,
       super(const ChatInitial()) {
    on<ChatLoadRequested>(_onLoadRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatActionConfirmed>(_onActionConfirmed);
    on<ChatAudioTranscriptionRequested>(_onAudioTranscriptionRequested);
  }

  final SendMessageUseCase _sendMessage;
  final GetChatHistoryUseCase _getChatHistory;
  final SaveChatMessageUseCase _saveChatMessage;
  final TranscribeAudioUseCase _transcribeAudio;
  final Map<String, ChatActionHandler> _handlers;
  final String _userId;
  static const _uuid = Uuid();

  /// Snapshot of the loaded message list. Reading from state keeps the
  /// "single source of truth" invariant — no mutable buffer to drift out
  /// of sync with what the UI rendered.
  List<ChatMessageEntity> _currentMessages() {
    final current = state;
    return current is ChatLoaded ? current.messages : const [];
  }

  /// Picks the locale to use for handler-produced bubbles. The chat is
  /// bilingual — Gemini mirrors whatever language the user typed in — so
  /// action result/rejection messages must follow the **conversation**
  /// language, NOT the app's UI locale (which is what global `t` would
  /// return). Heuristic: scan the most recent AI reply for Portuguese-only
  /// diacritics and common stop-words; fall back to the latest user
  /// message; fall back to the active locale.
  AppLocale _chatLocale({String? hintText}) {
    final messages = _currentMessages();
    var sample = hintText ?? '';
    if (sample.isEmpty) {
      for (final m in messages.reversed) {
        if (m.role == ChatRole.assistant && m.content.isNotEmpty) {
          sample = m.content;
          break;
        }
      }
    }
    if (sample.isEmpty && messages.isNotEmpty) {
      sample = messages.last.content;
    }
    if (_looksLikePortuguese(sample)) {
      return AppLocale.ptBr;
    }
    return LocaleSettings.instance.currentLocale;
  }

  static final RegExp _ptDiacritics = RegExp('[ãõçáâéêíóôúÁÂÃÉÊÍÓÔÕÚÇ]');
  static final RegExp _ptStopWords = RegExp(
    r'\b(você|voce|não|nao|criar|criada|conta|gasto|despesa|receita|'
    'orçamento|orcamento|confirma|categoria|valor|qual|pago|'
    r'transferência|transferencia|para)\b',
    caseSensitive: false,
  );

  static bool _looksLikePortuguese(String text) {
    if (text.isEmpty) return false;
    if (_ptDiacritics.hasMatch(text)) return true;
    return _ptStopWords.hasMatch(text);
  }

  Future<void> _onLoadRequested(
    ChatLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    final result = await _getChatHistory(userId: _userId);
    result.fold(
      (failure) => emit(ChatError(failure)),
      (messages) => emit(ChatLoaded(messages: List.unmodifiable(messages))),
    );
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final hasImage = event.image != null;
    // Use the language of the user's typed content as the hint for the
    // placeholder caption — the AI hasn't replied yet, so the chat-history
    // heuristic would fall back to the previous turn (wrong if the user
    // switched languages mid-conversation).
    final inputLocale = _chatLocale(hintText: event.content);
    // When there's an image, the bubble renders a thumbnail above the text —
    // an empty caption renders as just the image, no placeholder needed.
    // The placeholder string only kicks in when an image somehow arrives
    // without thumbnail bytes (defensive — shouldn't happen in normal flow).
    final displayContent = event.content.trim().isNotEmpty
        ? event.content
        : hasImage && event.imageBytes == null
            ? inputLocale.translations.chat.handlers.imageAttached
            : event.content;

    // Flag the message as "had an image" so reloads can render a small
    // placeholder tile instead of an empty bubble — the original bytes are
    // never persisted (per spec), but this tag tells the UI there was one.
    final userMetadata = hasImage ? <String, dynamic>{'hadImage': true} : null;

    final userMessage = ChatMessageEntity(
      id: _uuid.v4(),
      userId: _userId,
      role: ChatRole.user,
      content: displayContent,
      createdAt: DateTime.now(),
      metadata: userMetadata,
      inlineImageBytes: event.imageBytes,
    );

    final afterUser = [..._currentMessages(), userMessage];
    emit(
      ChatLoaded(
        messages: List.unmodifiable(afterUser),
        isTyping: true,
      ),
    );

    await _saveMessageNonBlocking(userMessage);

    // Pass history WITHOUT the current user message to avoid duplicating
    // the user turn in Gemini's context (startChat + sendMessage).
    final historyBeforeCurrent = afterUser.sublist(0, afterUser.length - 1);

    final result = await _sendMessage(
      userId: _userId,
      content: event.content,
      history: historyBeforeCurrent,
      image: event.image,
    );

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => null)!;
      log(
        'ChatBloc: AI call failed — ${failure.message}',
        name: 'ChatBloc',
        error: failure,
      );
      final isQuota =
          failure.message.toLowerCase().contains('quota') ||
          failure.message.toLowerCase().contains('rate');
      // Use the user's typed content as the language hint — the AI's reply
      // didn't arrive (that's the whole reason we're in this branch), so
      // the chat-history heuristic would be a turn behind.
      final errorStrings = _chatLocale(hintText: event.content).translations;
      final errorText = isQuota
          ? errorStrings.chat.handlers.errorQuota
          : errorStrings.chat.handlers.errorGeneric;
      final errorMessage = ChatMessageEntity(
        id: _uuid.v4(),
        userId: _userId,
        role: ChatRole.assistant,
        content: errorText,
        createdAt: DateTime.now(),
      );
      emit(
        ChatLoaded(
          messages: List.unmodifiable([...afterUser, errorMessage]),
        ),
      );
      return;
    }

    final response = result.fold((_) => null, (r) => r)!;
    var afterResponse = [...afterUser, response];

    // Preflight: validate the action against current data before showing
    // the card. Confirming a card and then seeing an error message breaks
    // the contract the card sets up — if the user got to Confirm, all
    // checks should already have passed.
    final actionType = response.metadata?['actionType'] as String?;
    if (actionType != null) {
      final handler = _handlers[actionType];
      // Preflight uses the AI's reply language so rejection text matches
      // the surrounding conversation, even when the app UI is in en.
      final preflightLocale = _chatLocale(hintText: response.content);
      final preflightError = await handler?.preflight(
        userId: _userId,
        meta: response.metadata!,
        locale: preflightLocale,
      );
      if (preflightError != null) {
        final rejection = ChatMessageEntity(
          id: _uuid.v4(),
          userId: _userId,
          role: ChatRole.assistant,
          content: '⚠️ $preflightError',
          metadata: {
            'kind': 'actionRejected',
            'originActionId': response.id,
          },
          createdAt: DateTime.now(),
        );
        afterResponse = [...afterResponse, rejection];
        await _saveMessageNonBlocking(rejection);
      }
    }

    emit(ChatLoaded(messages: List.unmodifiable(afterResponse)));
  }

  Future<void> _onActionConfirmed(
    ChatActionConfirmed event,
    Emitter<ChatState> emit,
  ) async {
    final meta = event.metadata;
    final actionType = meta['actionType'] as String?;
    final handler = actionType == null ? null : _handlers[actionType];
    // The action card was rendered for an AI proposal — use that proposal's
    // language so the success/failure bubble reads in the same language as
    // the rest of the conversation.
    final locale = _chatLocale();
    final resultText = handler == null
        ? locale.translations.chat.handlers.unknownAction
        : await handler.handle(userId: _userId, meta: meta, locale: locale);

    // - `kind: 'actionResult'` so the data source strips this from the
    //   history sent to Gemini (otherwise the AI mimics the success pattern
    //   in future turns and skips the action block).
    // - `originActionId` lets the timeline find this result later and
    //   render the proposal card persistently as "Confirmed" — survives
    //   page reload, unlike page-level state.
    final sysMessage = ChatMessageEntity(
      id: _uuid.v4(),
      userId: _userId,
      role: ChatRole.assistant,
      content: resultText,
      metadata: {
        'kind': 'actionResult',
        'originActionId': event.actionMessageId,
      },
      createdAt: DateTime.now(),
    );

    final next = [..._currentMessages(), sysMessage];
    await _saveMessageNonBlocking(sysMessage);
    emit(
      ChatLoaded(
        messages: List.unmodifiable(next),
        shouldRefreshTransactions: actionType == 'transaction' ||
            actionType == 'transfer',
        shouldRefreshBudgets: actionType == 'budget',
      ),
    );
  }

  Future<void> _onAudioTranscriptionRequested(
    ChatAudioTranscriptionRequested event,
    Emitter<ChatState> emit,
  ) async {
    final messages = _currentMessages();
    emit(
      ChatLoaded(
        messages: List.unmodifiable(messages),
        isTranscribing: true,
      ),
    );

    final result = await _transcribeAudio(
      base64Data: event.base64Data,
      mimeType: event.mimeType,
    );

    final transcript = result.fold((_) => null, (s) => s.trim());
    if (transcript == null) {
      final failure = result.fold((f) => f, (_) => null)!;
      log(
        'ChatBloc: transcription failed — ${failure.message}',
        name: 'ChatBloc',
        error: failure,
      );
      emit(ChatLoaded(messages: List.unmodifiable(messages)));
      return;
    }
    if (transcript.isEmpty) {
      // Nothing intelligible was captured — drop back to idle without
      // dispatching an empty user message that the AI would reject.
      emit(ChatLoaded(messages: List.unmodifiable(messages)));
      return;
    }

    // Send the transcript as a regular user turn so the AI processes it
    // and confirms the action — same path as a typed message. We delegate
    // by invoking the message handler directly with the same emitter so
    // the user bubble appears immediately (an `add()` here would queue the
    // event behind the current handler completing).
    await _onMessageSent(ChatMessageSent(transcript), emit);
  }

  /// Wraps `_saveChatMessage` so its failure never propagates through the
  /// bloc handler. Persist errors are surfaced via `developer.log` so an
  /// outage stays visible in DevTools / Crashlytics rather than silently
  /// rotting the chat history.
  Future<void> _saveMessageNonBlocking(ChatMessageEntity message) async {
    try {
      await _saveChatMessage(message);
    } on Exception catch (e, st) {
      log(
        'ChatBloc: failed to persist chat message ${message.id}',
        name: 'ChatBloc',
        error: e,
        stackTrace: st,
      );
    }
  }
}
