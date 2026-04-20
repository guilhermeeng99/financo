import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
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
    this.shouldRefreshTransactions = false,
  });

  final List<ChatMessageEntity> messages;
  final bool isTyping;
  final bool shouldRefreshTransactions;

  @override
  List<Object> get props => [messages, isTyping, shouldRefreshTransactions];
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
    required CreateAccountUseCase createAccount,
    required GetAccountsUseCase getAccounts,
    required DeleteAccountUseCase deleteAccount,
    required CreateCategoryUseCase createCategory,
    required GetCategoriesUseCase getCategories,
    required DeleteCategoryUseCase deleteCategory,
    required CreateTransactionUseCase createTransaction,
    required String userId,
  }) : _sendMessage = sendMessage,
       _getChatHistory = getChatHistory,
       _saveChatMessage = saveChatMessage,
       _createAccount = createAccount,
       _getAccounts = getAccounts,
       _deleteAccount = deleteAccount,
       _createCategory = createCategory,
       _getCategories = getCategories,
       _deleteCategory = deleteCategory,
       _createTransaction = createTransaction,
       _userId = userId,
       super(const ChatInitial()) {
    on<ChatLoadRequested>(_onLoadRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatActionConfirmed>(_onActionConfirmed);
  }

  final SendMessageUseCase _sendMessage;
  final GetChatHistoryUseCase _getChatHistory;
  final SaveChatMessageUseCase _saveChatMessage;
  final CreateAccountUseCase _createAccount;
  final GetAccountsUseCase _getAccounts;
  final DeleteAccountUseCase _deleteAccount;
  final CreateCategoryUseCase _createCategory;
  final GetCategoriesUseCase _getCategories;
  final DeleteCategoryUseCase _deleteCategory;
  final CreateTransactionUseCase _createTransaction;
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
      await _saveChatMessage(userMessage);
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
      case 'transaction':
        resultText = await _handleTransactionAction(meta);
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
    try {
      await _saveChatMessage(sysMessage);
    } on Exception {
      // Persist failure is non-blocking — state is still emitted.
    }
    emit(
      ChatLoaded(
        messages: List.unmodifiable(_messages),
        shouldRefreshTransactions: actionType == 'transaction',
      ),
    );
  }

  Future<String> _handleAccountAction(
    Map<String, dynamic> meta,
  ) async {
    final action = meta['action'] as String?;

    if (action == 'create') {
      final bankStr = (meta['bank'] as String?)?.toLowerCase() ?? 'others';
      final bank = bankStr == 'nubank' ? BankType.nubank : BankType.others;
      final type = (meta['type'] as String?) == 'creditCard'
          ? AccountType.creditCard
          : AccountType.checking;

      String? linkedAccountId;
      if (type == AccountType.creditCard && meta['linkedAccountName'] != null) {
        final linkedName = meta['linkedAccountName'] as String;
        final accResult = await _getAccounts(userId: _userId);
        if (accResult.isRight()) {
          final accounts = accResult.getOrElse(() => []);
          final linked = accounts
              .where(
                (a) => a.name.toLowerCase() == linkedName.toLowerCase(),
              )
              .toList();
          if (linked.isNotEmpty) {
            linkedAccountId = linked.first.id;
          }
        }
      }

      final account = AccountEntity(
        id: '',
        userId: _userId,
        name: meta['name'] as String? ?? 'Account',
        type: type,
        bank: bank,
        initialBalance: (meta['balance'] as num?)?.toDouble() ?? 0,
        creditLimit: (meta['creditLimit'] as num?)?.toDouble(),
        closingDay: meta['closingDay'] as int?,
        dueDay: meta['dueDay'] as int?,
        linkedAccountId: linkedAccountId,
        createdAt: DateTime.now(),
      );

      final result = await _createAccount(account);
      return result.fold(
        (f) => 'Failed to create account: ${f.message}',
        (a) => 'Account "${a.name}" created successfully!',
      );
    }

    if (action == 'delete') {
      final name = meta['name'] as String? ?? '';
      final listResult = await _getAccounts(
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
      final delResult = await _deleteAccount(match.first.id);
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
        _ => CategoryType.expense,
      };

      final existingResult = await _getCategories(userId: _userId);
      final existingCount = existingResult.fold(
        (_) => 0,
        (categories) => categories.length,
      );

      final category = CategoryEntity(
        id: '',
        userId: _userId,
        name: meta['name'] as String? ?? 'Category',
        icon: meta['icon'] as int? ?? 58332,
        color: CategoryColors.forIndex(existingCount),
        type: type,
      );

      final result = await _createCategory(category);
      return result.fold(
        (f) => 'Failed to create category: ${f.message}',
        (c) => 'Category "${c.name}" created successfully!',
      );
    }

    if (action == 'delete') {
      final name = meta['name'] as String? ?? '';
      final listResult = await _getCategories(
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
      final delResult = await _deleteCategory(match.first.id);
      return delResult.fold(
        (f) => 'Failed to delete category: ${f.message}',
        (_) => 'Category "$name" deleted successfully!',
      );
    }

    return 'Unknown category action.';
  }

  Future<String> _handleTransactionAction(
    Map<String, dynamic> meta,
  ) async {
    final typeStr = meta['type'] as String? ?? 'expense';
    final txType = typeStr == 'income'
        ? TransactionType.income
        : TransactionType.expense;

    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return 'Invalid amount.';

    final description = meta['description'] as String? ?? '';
    final dateStr = meta['date'] as String?;
    final date = dateStr != null
        ? DateTime.tryParse(dateStr) ?? DateTime.now()
        : DateTime.now();

    // Find category by name
    final categoryName = meta['category'] as String? ?? '';
    final catResult = await _getCategories(userId: _userId);
    if (catResult.isLeft()) {
      return 'Failed to load categories.';
    }
    final categories = catResult.getOrElse(() => []);
    final matchedCat = categories
        .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
        .toList();
    if (matchedCat.isEmpty) {
      return 'Category "$categoryName" not found. '
          'Please create it first.';
    }

    // Find account by name
    final accountName = meta['account'] as String? ?? '';
    final accResult = await _getAccounts(userId: _userId);
    if (accResult.isLeft()) {
      return 'Failed to load accounts.';
    }
    final accounts = accResult.getOrElse(() => []);
    if (accounts.isEmpty) {
      return 'No accounts found. Please create an account first.';
    }
    final matchedAccounts = accountName.isNotEmpty
        ? accounts
              .where((a) => a.name.toLowerCase() == accountName.toLowerCase())
              .toList()
        : <AccountEntity>[];
    final account = matchedAccounts.isNotEmpty
        ? matchedAccounts.first
        : accounts.first;

    final transaction = TransactionEntity(
      id: '',
      userId: _userId,
      accountId: account.id,
      categoryId: matchedCat.first.id,
      type: txType,
      amount: amount,
      description: description,
      date: date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _createTransaction(transaction);
    return result.fold(
      (f) => 'Failed to create transaction: ${f.message}',
      (t) =>
          'Transaction "${t.description}" of '
          'R\$ ${t.amount.toStringAsFixed(2)} created successfully!',
    );
  }
}
