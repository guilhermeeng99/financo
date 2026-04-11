import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
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
  const ChatMessageSent(this.content);

  final String content;

  @override
  List<Object> get props => [content];
}

final class ChatActionConfirmed extends ChatEvent {
  const ChatActionConfirmed(this.metadata);

  final Map<String, dynamic> metadata;

  @override
  List<Object> get props => [metadata];
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
  });

  final List<ChatMessageEntity> messages;
  final bool isTyping;

  @override
  List<Object> get props => [messages, isTyping];
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
    required ChatRepository chatRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required String userId,
  }) : _sendMessage = sendMessage,
       _getChatHistory = getChatHistory,
       _chatRepo = chatRepository,
       _accountRepo = accountRepository,
       _categoryRepo = categoryRepository,
       _userId = userId,
       super(const ChatInitial()) {
    on<ChatLoadRequested>(_onLoadRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatActionConfirmed>(_onActionConfirmed);
  }

  final SendMessageUseCase _sendMessage;
  final GetChatHistoryUseCase _getChatHistory;
  final ChatRepository _chatRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;
  final String _userId;
  static const _uuid = Uuid();

  final List<ChatMessageEntity> _messages = [];

  Future<void> _onLoadRequested(
    ChatLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await _getChatHistory(userId: _userId);
    result.fold(
      (failure) => emit(ChatError(failure)),
      (messages) {
        _messages
          ..clear()
          ..addAll(messages);
        emit(ChatLoaded(messages: List.unmodifiable(_messages)));
      },
    );
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final userMessage = ChatMessageEntity(
      id: _uuid.v4(),
      userId: _userId,
      role: ChatRole.user,
      content: event.content,
      createdAt: DateTime.now(),
    );

    _messages.add(userMessage);
    emit(
      ChatLoaded(
        messages: List.unmodifiable(_messages),
        isTyping: true,
      ),
    );

    try {
      await _chatRepo.saveChatMessage(userMessage);
    } on Exception {
      // Persist failure is non-blocking — continue with AI call.
    }

    // Pass history WITHOUT the current user message to avoid duplicating
    // the user turn in Gemini's context (startChat + sendMessage).
    final historyBeforeCurrent = _messages.sublist(0, _messages.length - 1);

    final result = await _sendMessage(
      userId: _userId,
      content: event.content,
      history: historyBeforeCurrent,
    );

    result.fold(
      (failure) {
        log(
          'ChatBloc: AI call failed — ${failure.message}',
          name: 'ChatBloc',
          error: failure,
        );
        final isQuota =
            failure.message.toLowerCase().contains('quota') ||
            failure.message.toLowerCase().contains('rate');
        final errorText = isQuota
            ? 'The AI service is temporarily unavailable due to rate limits. '
                  'Please wait a moment and try again.'
            : 'Sorry, I could not process your message. Please try again.';
        final errorMessage = ChatMessageEntity(
          id: _uuid.v4(),
          userId: _userId,
          role: ChatRole.assistant,
          content: errorText,
          createdAt: DateTime.now(),
        );
        _messages.add(errorMessage);
        emit(ChatLoaded(messages: List.unmodifiable(_messages)));
      },
      (response) {
        _messages.add(response);
        emit(ChatLoaded(messages: List.unmodifiable(_messages)));
      },
    );
  }

  Future<void> _onActionConfirmed(
    ChatActionConfirmed event,
    Emitter<ChatState> emit,
  ) async {
    final meta = event.metadata;
    final actionType = meta['actionType'] as String?;

    String resultText;

    switch (actionType) {
      case 'account':
        resultText = await _handleAccountAction(meta);
      case 'category':
        resultText = await _handleCategoryAction(meta);
      default:
        resultText = 'Unknown action type.';
    }

    final sysMessage = ChatMessageEntity(
      id: _uuid.v4(),
      userId: _userId,
      role: ChatRole.assistant,
      content: resultText,
      createdAt: DateTime.now(),
    );

    _messages.add(sysMessage);
    await _chatRepo.saveChatMessage(sysMessage);
    emit(ChatLoaded(messages: List.unmodifiable(_messages)));
  }

  Future<String> _handleAccountAction(
    Map<String, dynamic> meta,
  ) async {
    final action = meta['action'] as String?;

    if (action == 'create') {
      final account = AccountEntity(
        id: '',
        userId: _userId,
        name: meta['name'] as String? ?? 'Account',
        type: (meta['type'] as String?) == 'creditCard'
            ? AccountType.creditCard
            : AccountType.checking,
        bank: meta['bank'] as String? ?? '',
        balance: (meta['balance'] as num?)?.toDouble() ?? 0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final result = await _accountRepo.createAccount(account);
      return result.fold(
        (f) => 'Failed to create account: ${f.message}',
        (a) => 'Account "${a.name}" created successfully!',
      );
    }

    if (action == 'delete') {
      final name = meta['name'] as String? ?? '';
      final listResult = await _accountRepo.getAccounts(
        userId: _userId,
      );
      if (listResult.isLeft()) {
        return 'Failed to find account: '
            '${listResult.fold((f) => f.message, (_) => '')}';
      }
      final accounts = listResult.getOrElse(() => []);
      final match = accounts
          .where((a) => a.name.toLowerCase() == name.toLowerCase())
          .toList();
      if (match.isEmpty) {
        return 'No account named "$name" found.';
      }
      final delResult = await _accountRepo.deleteAccount(match.first.id);
      return delResult.fold(
        (f) => 'Failed to delete account: ${f.message}',
        (_) => 'Account "$name" deleted successfully!',
      );
    }

    return 'Unknown account action.';
  }

  Future<String> _handleCategoryAction(
    Map<String, dynamic> meta,
  ) async {
    final action = meta['action'] as String?;

    if (action == 'create') {
      final typeStr = meta['type'] as String? ?? 'expense';
      final type = switch (typeStr) {
        'income' => CategoryType.income,
        'both' => CategoryType.both,
        _ => CategoryType.expense,
      };

      final category = CategoryEntity(
        id: '',
        userId: _userId,
        name: meta['name'] as String? ?? 'Category',
        icon: meta['icon'] as int? ?? 58332,
        color: meta['color'] as int? ?? 4280391411,
        type: type,
        isDefault: false,
        sortOrder: 99,
      );

      final result = await _categoryRepo.createCategory(category);
      return result.fold(
        (f) => 'Failed to create category: ${f.message}',
        (c) => 'Category "${c.name}" created successfully!',
      );
    }

    if (action == 'delete') {
      final name = meta['name'] as String? ?? '';
      final listResult = await _categoryRepo.getCategories(
        userId: _userId,
      );
      if (listResult.isLeft()) {
        return 'Failed to find category: '
            '${listResult.fold((f) => f.message, (_) => '')}';
      }
      final categories = listResult.getOrElse(() => []);
      final match = categories
          .where((c) => c.name.toLowerCase() == name.toLowerCase())
          .toList();
      if (match.isEmpty) {
        return 'No category named "$name" found.';
      }
      if (match.first.isDefault) {
        return 'Cannot delete default category "$name".';
      }
      final delResult = await _categoryRepo.deleteCategory(match.first.id);
      return delResult.fold(
        (f) => 'Failed to delete category: ${f.message}',
        (_) => 'Category "$name" deleted successfully!',
      );
    }

    return 'Unknown category action.';
  }
}
