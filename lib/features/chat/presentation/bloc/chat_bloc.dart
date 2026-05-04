import 'dart:developer';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/bank_brand.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/create_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:financo/features/bills/domain/usecases/pay_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_usecase.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:financo/features/chat/domain/usecases/transcribe_audio_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
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
/// text as a regular user message. Mirrors WhatsApp-style voice notes:
/// the user records, the transcript appears as the user bubble, the AI
/// confirms what it understood. There is no separate review step.
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
    this.shouldRefreshBills = false,
    this.shouldRefreshBudgets = false,
    this.isTranscribing = false,
  });

  final List<ChatMessageEntity> messages;
  final bool isTyping;
  final bool shouldRefreshTransactions;
  final bool shouldRefreshBills;
  final bool shouldRefreshBudgets;
  final bool isTranscribing;

  @override
  List<Object?> get props => [
    messages,
    isTyping,
    shouldRefreshTransactions,
    shouldRefreshBills,
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
    required CreateAccountUseCase createAccount,
    required GetAccountsUseCase getAccounts,
    required DeleteAccountUseCase deleteAccount,
    required CreateCategoryUseCase createCategory,
    required GetCategoriesUseCase getCategories,
    required DeleteCategoryUseCase deleteCategory,
    required CreateTransactionUseCase createTransaction,
    required CreateTransferUseCase createTransfer,
    required GetBillsUseCase getBills,
    required CreateBillUseCase createBill,
    required UpdateBillUseCase updateBill,
    required DeleteBillUseCase deleteBill,
    required PayBillUseCase payBill,
    required GetBudgetsUseCase getBudgets,
    required CreateBudgetUseCase createBudget,
    required UpdateBudgetUseCase updateBudget,
    required DeleteBudgetUseCase deleteBudget,
    required String userId,
  }) : _sendMessage = sendMessage,
       _getChatHistory = getChatHistory,
       _saveChatMessage = saveChatMessage,
       _transcribeAudio = transcribeAudio,
       _createAccount = createAccount,
       _getAccounts = getAccounts,
       _deleteAccount = deleteAccount,
       _createCategory = createCategory,
       _getCategories = getCategories,
       _deleteCategory = deleteCategory,
       _createTransaction = createTransaction,
       _createTransfer = createTransfer,
       _getBills = getBills,
       _createBill = createBill,
       _updateBill = updateBill,
       _deleteBill = deleteBill,
       _payBill = payBill,
       _getBudgets = getBudgets,
       _createBudget = createBudget,
       _updateBudget = updateBudget,
       _deleteBudget = deleteBudget,
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
  final CreateAccountUseCase _createAccount;
  final GetAccountsUseCase _getAccounts;
  final DeleteAccountUseCase _deleteAccount;
  final CreateCategoryUseCase _createCategory;
  final GetCategoriesUseCase _getCategories;
  final DeleteCategoryUseCase _deleteCategory;
  final CreateTransactionUseCase _createTransaction;
  final CreateTransferUseCase _createTransfer;
  final GetBillsUseCase _getBills;
  final CreateBillUseCase _createBill;
  final UpdateBillUseCase _updateBill;
  final DeleteBillUseCase _deleteBill;
  final PayBillUseCase _payBill;
  final GetBudgetsUseCase _getBudgets;
  final CreateBudgetUseCase _createBudget;
  final UpdateBudgetUseCase _updateBudget;
  final DeleteBudgetUseCase _deleteBudget;
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
    final hasImage = event.image != null;
    // When there's an image, the bubble renders a thumbnail above the text —
    // an empty caption renders as just the image, no placeholder needed.
    // The placeholder string only kicks in when an image somehow arrives
    // without thumbnail bytes (defensive — shouldn't happen in normal flow).
    final displayContent = event.content.trim().isNotEmpty
        ? event.content
        : hasImage && event.imageBytes == null
            ? '📷 Image attached.'
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
      image: event.image,
    );

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw StateError('left'));
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
      return;
    }

    final response = result.fold(
      (_) => throw StateError('right'),
      (r) => r,
    );
    _messages.add(response);

    // Preflight: validate the action against current data before showing
    // the card. Confirming a card and then seeing an error message breaks
    // the contract the card sets up — if the user got to Confirm, all
    // checks should already have passed.
    final actionType = response.metadata?['actionType'] as String?;
    if (actionType != null) {
      final preflightError = await _preflightAction(response.metadata!);
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
        _messages.add(rejection);
        try {
          await _saveChatMessage(rejection);
        } on Exception {
          // non-blocking — UI already shows the rejection bubble.
        }
      }
    }

    emit(ChatLoaded(messages: List.unmodifiable(_messages)));
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
      case 'transfer':
        resultText = await _handleTransferAction(meta);
      case 'bill':
        resultText = await _handleBillAction(meta);
      case 'budget':
        resultText = await _handleBudgetAction(meta);
      default:
        resultText = 'Unknown action type.';
    }

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

    _messages.add(sysMessage);
    try {
      await _saveChatMessage(sysMessage);
    } on Exception {
      // Persist failure is non-blocking — state is still emitted.
    }
    emit(
      ChatLoaded(
        messages: List.unmodifiable(_messages),
        shouldRefreshTransactions: actionType == 'transaction' ||
            actionType == 'transfer' ||
            actionType == 'bill',
        shouldRefreshBills: actionType == 'bill',
        shouldRefreshBudgets: actionType == 'budget',
      ),
    );
  }

  Future<void> _onAudioTranscriptionRequested(
    ChatAudioTranscriptionRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      ChatLoaded(
        messages: List.unmodifiable(_messages),
        isTranscribing: true,
      ),
    );

    final result = await _transcribeAudio(
      base64Data: event.base64Data,
      mimeType: event.mimeType,
    );

    final transcript = result.fold((_) => null, (t) => t.trim());
    if (transcript == null) {
      final failure = result.fold((f) => f, (_) => null)!;
      log(
        'ChatBloc: transcription failed — ${failure.message}',
        name: 'ChatBloc',
        error: failure,
      );
      emit(ChatLoaded(messages: List.unmodifiable(_messages)));
      return;
    }
    if (transcript.isEmpty) {
      // Nothing intelligible was captured — drop back to idle without
      // dispatching an empty user message that the AI would reject.
      emit(ChatLoaded(messages: List.unmodifiable(_messages)));
      return;
    }

    // Send the transcript as a regular user turn so the AI processes it
    // and confirms the action — same path as a typed message. We delegate
    // by invoking the message handler directly with the same emitter so
    // the user bubble appears immediately (an `add()` here would queue the
    // event behind the current handler completing).
    await _onMessageSent(ChatMessageSent(transcript), emit);
  }

  Future<String> _handleAccountAction(
    Map<String, dynamic> meta,
  ) async {
    final action = meta['action'] as String?;

    if (action == 'create') {
      final bankStr = meta['bank'] as String? ?? '';
      final bank = BankBrand.resolveAlias(bankStr) ?? BankType.others;
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
    final resolution = _resolveAccount(accounts, accountName);
    final account = resolution.account;
    if (account == null) {
      return resolution.error ?? 'Could not resolve account.';
    }

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

  // Validates action metadata against the user's current accounts /
  // categories BEFORE the action card is shown. The user shouldn't have to
  // tap Confirm only to discover the AI emitted a non-existent category or
  // an unresolvable account name — by then the card looks like a contract.
  // Returns a human-readable error string when the action would fail, or
  // null when it should proceed to the card.
  Future<String?> _preflightAction(Map<String, dynamic> meta) async {
    final actionType = meta['actionType'] as String?;
    switch (actionType) {
      case 'transaction':
        return _preflightTransaction(meta);
      case 'transfer':
        return _preflightTransfer(meta);
      case 'budget':
        return _preflightBudget(meta);
      default:
        return null;
    }
  }

  Future<String?> _preflightTransaction(Map<String, dynamic> meta) async {
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return 'Invalid amount.';

    final categoryName = (meta['category'] as String? ?? '').trim();
    if (categoryName.isEmpty) return 'Category is required.';

    final catResult = await _getCategories(userId: _userId);
    // If we can't reach the data, let the action through — better than a
    // false negative blocking a legitimate request.
    if (catResult.isLeft()) return null;
    final categories = catResult.getOrElse(() => []);
    final hasCategory = categories.any(
      (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
    );
    if (!hasCategory) {
      return 'Categoria "$categoryName" não existe. '
          'Se for uma transferência entre suas contas, peça '
          '"transferência" explicitamente; senão, crie a categoria primeiro.';
    }

    final accResult = await _getAccounts(userId: _userId);
    if (accResult.isLeft()) return null;
    final accounts = accResult.getOrElse(() => []);
    if (accounts.isEmpty) return 'Crie uma conta primeiro.';
    final accountName = (meta['account'] as String? ?? '').trim();
    final resolution = _resolveAccount(accounts, accountName);
    if (resolution.account == null) return resolution.error;
    return null;
  }

  Future<String?> _preflightTransfer(Map<String, dynamic> meta) async {
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return 'Invalid amount.';

    final fromName = (meta['from'] as String? ?? '').trim();
    final toName = (meta['to'] as String? ?? '').trim();
    if (fromName.isEmpty || toName.isEmpty) {
      return 'Transferência precisa de origem e destino.';
    }

    final accResult = await _getAccounts(userId: _userId);
    if (accResult.isLeft()) return null;
    final accounts = accResult.getOrElse(() => []);
    if (accounts.length < 2) {
      return 'Transferência requer ao menos duas contas.';
    }
    final fromR = _resolveAccount(accounts, fromName);
    if (fromR.account == null) return fromR.error;
    final toR = _resolveAccount(accounts, toName);
    if (toR.account == null) return toR.error;
    if (fromR.account!.id == toR.account!.id) {
      return 'Origem e destino devem ser contas diferentes.';
    }
    return null;
  }

  Future<String> _handleTransferAction(Map<String, dynamic> meta) async {
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return 'Invalid amount.';

    final fromName = (meta['from'] as String? ?? '').trim();
    final toName = (meta['to'] as String? ?? '').trim();
    if (fromName.isEmpty || toName.isEmpty) {
      return 'Transfer requires both source and destination accounts.';
    }

    final accResult = await _getAccounts(userId: _userId);
    if (accResult.isLeft()) return 'Failed to load accounts.';
    final accounts = accResult.getOrElse(() => []);
    if (accounts.length < 2) {
      return 'Transfer requires at least two accounts.';
    }

    final fromR = _resolveAccount(accounts, fromName);
    final fromAccount = fromR.account;
    if (fromAccount == null) {
      return fromR.error ?? 'Could not resolve source account.';
    }
    final toR = _resolveAccount(accounts, toName);
    final toAccount = toR.account;
    if (toAccount == null) {
      return toR.error ?? 'Could not resolve destination account.';
    }
    if (fromAccount.id == toAccount.id) {
      return 'Source and destination must be different accounts.';
    }

    final description = meta['description'] as String? ?? '';
    final dateStr = meta['date'] as String?;
    final date = dateStr != null
        ? DateTime.tryParse(dateStr) ?? DateTime.now()
        : DateTime.now();
    final now = DateTime.now();

    final expense = TransactionEntity(
      id: '',
      userId: _userId,
      accountId: fromAccount.id,
      categoryId: '',
      type: TransactionType.expense,
      amount: amount,
      description: description,
      date: date,
      createdAt: now,
      updatedAt: now,
    );
    final income = TransactionEntity(
      id: '',
      userId: _userId,
      accountId: toAccount.id,
      categoryId: '',
      type: TransactionType.income,
      amount: amount,
      description: description,
      date: date,
      createdAt: now,
      updatedAt: now,
    );

    final result = await _createTransfer(expense: expense, income: income);
    return result.fold(
      (f) => 'Failed to create transfer: ${f.message}',
      (_) =>
          'Transfer of R\$ ${amount.toStringAsFixed(2)} '
          'from "${fromAccount.name}" to "${toAccount.name}" '
          'created successfully!',
    );
  }

  Future<String> _handleBillAction(Map<String, dynamic> meta) async {
    final action = meta['action'] as String?;

    if (action == 'create') {
      final description = (meta['description'] as String? ?? '').trim();
      if (description.isEmpty) return 'Bill description is required.';
      final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
      if (amount <= 0) return 'Invalid bill amount.';
      final dueStr = meta['dueDate'] as String?;
      final dueDate = dueStr != null
          ? DateTime.tryParse(dueStr) ?? DateTime.now()
          : DateTime.now();
      final recurrenceStr = meta['recurrence'] as String? ?? 'oneShot';
      final recurrence = recurrenceStr == 'monthly'
          ? BillRecurrence.monthly
          : BillRecurrence.oneShot;
      final typeStr = meta['type'] as String?;
      final billType = typeStr == 'receivable'
          ? BillType.receivable
          : BillType.payable;

      String? categoryId;
      final categoryName = meta['category'] as String?;
      if (categoryName != null && categoryName.isNotEmpty) {
        final catResult = await _getCategories(userId: _userId);
        final categories = catResult.getOrElse(() => []);
        final match = categories
            .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
            .toList();
        if (match.isNotEmpty) categoryId = match.first.id;
      }

      final now = DateTime.now();
      final bill = BillEntity(
        id: '',
        userId: _userId,
        type: billType,
        description: description,
        amount: amount,
        dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
        status: BillStatus.pending,
        recurrence: recurrence,
        categoryId: categoryId,
        notes: meta['notes'] as String?,
        createdAt: now,
        updatedAt: now,
      );

      final result = await _createBill(bill);
      return result.fold(
        (f) => 'Failed to create bill: ${f.message}',
        (b) =>
            'Bill "${b.description}" of '
            'R\$ ${b.amount.toStringAsFixed(2)} scheduled for '
            '${_formatDateOnly(b.dueDate)}.',
      );
    }

    if (action == 'update') {
      final billId = meta['billId'] as String?;
      if (billId == null || billId.isEmpty) return 'Bill id required.';
      final billsResult = await _getBills(userId: _userId);
      final bills = billsResult.getOrElse(() => []);
      final existing = bills.where((b) => b.id == billId).toList();
      if (existing.isEmpty) return 'Bill not found.';
      final current = existing.first;
      if (current.status == BillStatus.paid) {
        return 'Bill is already paid and cannot be edited.';
      }

      final newAmount = (meta['amount'] as num?)?.toDouble() ?? current.amount;
      final newDueStr = meta['dueDate'] as String?;
      final newDue = newDueStr != null
          ? DateTime.tryParse(newDueStr) ?? current.dueDate
          : current.dueDate;
      final newDescription =
          (meta['description'] as String?)?.trim() ?? current.description;

      final updated = current.copyWith(
        description: newDescription,
        amount: newAmount,
        dueDate: DateTime(newDue.year, newDue.month, newDue.day),
        notes: meta['notes'] as String? ?? current.notes,
        updatedAt: DateTime.now(),
      );

      final result = await _updateBill(updated);
      return result.fold(
        (f) => 'Failed to update bill: ${f.message}',
        (b) => 'Bill "${b.description}" updated.',
      );
    }

    if (action == 'markPaid') {
      final billId = meta['billId'] as String?;
      if (billId == null || billId.isEmpty) return 'Bill id required.';
      final billsResult = await _getBills(userId: _userId);
      final bills = billsResult.getOrElse(() => []);
      final existing = bills.where((b) => b.id == billId).toList();
      if (existing.isEmpty) return 'Bill not found.';
      final bill = existing.first;
      if (bill.status == BillStatus.paid) return 'Bill is already paid.';

      // Default to first checking account + bill's category (or first expense
      // category) so the chat can mark-as-paid without follow-up dialogs. The
      // user can always edit the resulting transaction later.
      final accResult = await _getAccounts(userId: _userId);
      final accounts = accResult.getOrElse(() => []);
      final checking = accounts
          .where((a) => a.type == AccountType.checking)
          .toList();
      if (checking.isEmpty) {
        return 'No checking account available to register the payment.';
      }

      var categoryId = bill.categoryId;
      if (categoryId == null) {
        final catResult = await _getCategories(userId: _userId);
        final cats = catResult.getOrElse(() => []);
        final wantedType = bill.isReceivable
            ? CategoryType.income
            : CategoryType.expense;
        final matching = cats.where((c) => c.type == wantedType).toList();
        if (matching.isEmpty) {
          return bill.isReceivable
              ? 'No income category available to register the payment.'
              : 'No expense category available to register the payment.';
        }
        categoryId = matching.first.id;
      }

      final result = await _payBill(
        billId: bill.id,
        accountId: checking.first.id,
        categoryId: categoryId,
      );
      return result.fold(
        (f) => 'Failed to mark bill as paid: ${f.message}',
        (r) {
          final next = r.nextOccurrence;
          final base =
              'Bill "${r.paidBill.description}" paid — transaction created.';
          return next == null
              ? base
              : '$base Next occurrence scheduled for '
                    '${_formatDateOnly(next.dueDate)}.';
        },
      );
    }

    if (action == 'delete') {
      final billId = meta['billId'] as String?;
      if (billId == null || billId.isEmpty) return 'Bill id required.';
      final result = await _deleteBill(billId);
      return result.fold(
        (f) => 'Failed to delete bill: ${f.message}',
        (_) => 'Bill deleted.',
      );
    }

    return 'Unknown bill action.';
  }

  /// Validates a budget action against current categories + active budgets
  /// before showing the Confirm card. Mirrors `_preflightTransaction` —
  /// the user shouldn't tap Confirm on a card that's destined to fail.
  Future<String?> _preflightBudget(Map<String, dynamic> meta) async {
    final action = (meta['action'] as String?) ?? '';
    final categoryName = (meta['category'] as String? ?? '').trim();
    if (categoryName.isEmpty) {
      return 'Categoria é obrigatória para orçamento.';
    }

    final catResult = await _getCategories(userId: _userId);
    if (catResult.isLeft()) return null; // let it through; can't be sure
    final categories = catResult.getOrElse(() => []);
    final matched = categories
        .where(
          (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
        )
        .toList();
    if (matched.isEmpty) {
      return 'Categoria "$categoryName" não existe. Crie-a primeiro.';
    }
    final cat = matched.first;
    if (cat.type != CategoryType.expense) {
      return 'Orçamento só vale para categorias de despesa.';
    }
    if (cat.parentId != null) {
      return 'Orçamento só pode ser criado em categoria-pai. '
          'Use a categoria raiz "${categories.firstWhere(
            (c) => c.id == cat.parentId,
            orElse: () => cat,
          ).name}".';
    }

    if (action == 'create' || action == 'update' || action == 'delete') {
      final budgetsResult = await _getBudgets(userId: _userId);
      if (budgetsResult.isLeft()) return null;
      final budgets = budgetsResult.getOrElse(() => []);
      final existing = budgets
          .where((b) => b.categoryId == cat.id)
          .toList();
      if (action == 'create' && existing.isNotEmpty) {
        return 'Já existe um orçamento para "$categoryName". '
            'Use "atualizar" para mudar o valor.';
      }
      if ((action == 'update' || action == 'delete') && existing.isEmpty) {
        return 'Não existe orçamento para "$categoryName" ainda. '
            'Use "criar" para definir um.';
      }
    }

    if (action == 'create' || action == 'update') {
      final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
      if (amount <= 0) return 'Valor do orçamento deve ser maior que zero.';
    }
    return null;
  }

  Future<String> _handleBudgetAction(Map<String, dynamic> meta) async {
    final action = meta['action'] as String?;
    final categoryName = (meta['category'] as String? ?? '').trim();
    if (categoryName.isEmpty) return 'Categoria é obrigatória.';

    final catResult = await _getCategories(userId: _userId);
    if (catResult.isLeft()) return 'Não foi possível carregar categorias.';
    final categories = catResult.getOrElse(() => []);
    final cat = categories
        .where(
          (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
        )
        .firstOrNull;
    if (cat == null) {
      return 'Categoria "$categoryName" não encontrada.';
    }

    if (action == 'create') {
      final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
      if (amount <= 0) return 'Valor inválido.';
      final now = DateTime.now();
      final budget = BudgetEntity(
        id: '',
        userId: _userId,
        categoryId: cat.id,
        amount: amount,
        createdAt: now,
        updatedAt: now,
      );
      final result = await _createBudget(budget);
      return result.fold(
        (f) => 'Falha ao criar orçamento: ${f.message}',
        (b) =>
            'Orçamento de R\$ ${b.amount.toStringAsFixed(2)} '
            'em "${cat.name}" criado.',
      );
    }

    if (action == 'update') {
      final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
      if (amount <= 0) return 'Valor inválido.';
      final budgetsResult = await _getBudgets(userId: _userId);
      if (budgetsResult.isLeft()) {
        return 'Não foi possível carregar orçamentos.';
      }
      final budgets = budgetsResult.getOrElse(() => []);
      final existing = budgets.where((b) => b.categoryId == cat.id).firstOrNull;
      if (existing == null) {
        return 'Nenhum orçamento ativo para "${cat.name}".';
      }
      final updated = existing.copyWith(
        amount: amount,
        updatedAt: DateTime.now(),
      );
      final result = await _updateBudget(updated);
      return result.fold(
        (f) => 'Falha ao atualizar orçamento: ${f.message}',
        (b) =>
            'Orçamento de "${cat.name}" atualizado para '
            'R\$ ${b.amount.toStringAsFixed(2)}.',
      );
    }

    if (action == 'delete') {
      final budgetsResult = await _getBudgets(userId: _userId);
      if (budgetsResult.isLeft()) {
        return 'Não foi possível carregar orçamentos.';
      }
      final budgets = budgetsResult.getOrElse(() => []);
      final existing = budgets.where((b) => b.categoryId == cat.id).firstOrNull;
      if (existing == null) {
        return 'Nenhum orçamento ativo para "${cat.name}".';
      }
      final result = await _deleteBudget(existing.id);
      return result.fold(
        (f) => 'Falha ao remover orçamento: ${f.message}',
        (_) => 'Orçamento de "${cat.name}" removido.',
      );
    }

    return 'Ação de orçamento desconhecida.';
  }

  static String _formatDateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // Two-tier account resolution: exact case-insensitive, then word-set
  // match (every query word appears in the account name as a substring, or
  // vice versa). Word-set covers the common case where the user types
  // "cartão mila" and the registered account is "Cartão Nubank Mila" —
  // contiguous-substring would miss it because "nubank" sits between the
  // matching words. Returns an error message on zero or multiple matches —
  // never silently picks an arbitrary account, which would write the
  // transaction to the wrong card and still report success (chat spec §10).
  static ({AccountEntity? account, String? error}) _resolveAccount(
    List<AccountEntity> accounts,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return (
        account: null,
        error:
            'Which account should I use? Please tell me the account name.',
      );
    }

    final exact = accounts
        .where((a) => a.name.toLowerCase() == normalized)
        .toList();
    if (exact.isNotEmpty) return (account: exact.first, error: null);

    final fuzzy = accounts
        .where((a) => _wordsMatch(normalized, a.name.toLowerCase()))
        .toList();

    if (fuzzy.length == 1) return (account: fuzzy.first, error: null);
    if (fuzzy.isEmpty) {
      return (
        account: null,
        error:
            'Account "$query" not found. '
            'Please create it first or use the exact name.',
      );
    }
    final names = fuzzy.map((a) => '"${a.name}"').join(', ');
    return (
      account: null,
      error:
          'Multiple accounts match "$query": $names. '
          'Please be more specific.',
    );
  }

  static bool _wordsMatch(String query, String accountName) {
    final qWords = _tokens(query);
    final aWords = _tokens(accountName);
    if (qWords.isEmpty || aWords.isEmpty) return false;
    final qInA = qWords.every((w) => aWords.any((a) => a.contains(w)));
    final aInQ = aWords.every((a) => qWords.any((w) => w.contains(a)));
    return qInA || aInQ;
  }

  static List<String> _tokens(String s) =>
      s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
}
