import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit({
    required CreateTransactionUseCase createTransaction,
    required UpdateTransactionUseCase updateTransaction,
    required CreateTransferUseCase createTransfer,
    required GetTransactionUseCase getTransaction,
    required String userId,
    TransactionEntity? existingTransaction,
    String? prefillAccountId,
  }) : _createTransaction = createTransaction,
       _updateTransaction = updateTransaction,
       _createTransfer = createTransfer,
       _getTransaction = getTransaction,
       super(
         TransactionFormState.initial(
           userId: userId,
           existing: existingTransaction,
           prefillAccountId: prefillAccountId,
         ),
       ) {
    // Editing a transfer: only the tapped leg arrives. Fetch the linked
    // leg so the form can show both source and destination accounts —
    // and so submit can update *both* legs (see `_updateTransfer`).
    if (existingTransaction != null && existingTransaction.isTransfer) {
      unawaited(_resolveTransferCounterpart(existingTransaction));
    }
  }

  final CreateTransactionUseCase _createTransaction;
  final UpdateTransactionUseCase _updateTransaction;
  final CreateTransferUseCase _createTransfer;
  final GetTransactionUseCase _getTransaction;

  void updateType(TransactionType type) => emit(state.copyWith(type: type));

  void updateAmount(String value) {
    // Accept both BR (`421,95`) and EN (`421.95`) decimal styles. Negative
    // values flow through and are caught by `isValid` (amount must be > 0)
    // — silently `.abs()`'ing them would mask user typos.
    final amount = parseDecimalAmount(value) ?? 0;
    emit(state.copyWith(amount: amount));
  }

  void updateDescription(String value) =>
      emit(state.copyWith(description: value));

  void updateDate(DateTime date) => emit(state.copyWith(date: date));

  void updateAccountId(String id) => emit(state.copyWith(accountId: id));

  void updateCategoryId(String id) => emit(state.copyWith(categoryId: id));

  void updateDestinationAccountId(String id) =>
      emit(state.copyWith(destinationAccountId: id));

  void updateNotes(String value) => emit(state.copyWith(notes: value));

  void setTransferMode({required bool enabled}) =>
      emit(state.copyWith(isTransfer: enabled));

  /// Submits the form. When [continueAfterSave] is true, the resulting
  /// `success` state carries the same flag so the page can keep the user
  /// on the form (with all fields preserved) instead of popping the
  /// route. Used by the "+ create another" affordance for fast batch
  /// entry of similar transactions.
  Future<void> submit({bool continueAfterSave = false}) async {
    if (!state.isValid) return;
    emit(
      state.copyWith(
        status: FormStatus.submitting,
        continueAfterSave: continueAfterSave,
      ),
    );

    if (state.isTransfer) {
      await (state.isEditing ? _updateTransfer() : _submitTransfer());
    } else {
      await _submitTransaction();
    }
  }

  /// Fetches the linked leg of a transfer being edited and fills in the
  /// account that the tapped leg didn't carry. `accountId` always ends up
  /// holding the source (expense leg) account and `destinationAccountId`
  /// the destination (income leg) account — regardless of which leg the
  /// user tapped. On fetch failure the unknown account stays empty so the
  /// form remains invalid rather than guessing.
  Future<void> _resolveTransferCounterpart(TransactionEntity tapped) async {
    final counterpartId = tapped.linkedTransactionId;
    if (counterpartId == null) return;
    final result = await _getTransaction(counterpartId);
    if (isClosed) return;
    result.fold((_) {}, (counterpart) {
      final isExpenseLeg = counterpart.type == TransactionType.expense;
      emit(
        state.copyWith(
          accountId: isExpenseLeg ? counterpart.accountId : null,
          destinationAccountId: isExpenseLeg ? null : counterpart.accountId,
          originalCreatedAt: isExpenseLeg ? counterpart.createdAt : null,
          destinationCreatedAt: isExpenseLeg ? null : counterpart.createdAt,
        ),
      );
    });
  }

  /// Drops the transient post-submit flags (`status`, `savedTransactionId`,
  /// `continueAfterSave`, `failure`) while keeping every user-entered field
  /// in place, so the form is immediately ready to submit another similar
  /// transaction. Called by the page after handling a `success` state
  /// produced by `submit(continueAfterSave: true)`.
  void prepareForNext() {
    emit(
      TransactionFormState(
        userId: state.userId,
        type: state.type,
        amount: state.amount,
        description: state.description,
        date: state.date,
        accountId: state.accountId,
        categoryId: state.categoryId,
        destinationAccountId: state.destinationAccountId,
        notes: state.notes,
        status: FormStatus.initial,
        isTransfer: state.isTransfer,
        existingId: state.existingId,
        linkedTransactionId: state.linkedTransactionId,
      ),
    );
  }

  Future<void> _submitTransaction() async {
    final now = DateTime.now();
    final transaction = TransactionEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      accountId: state.accountId,
      categoryId: state.categoryId,
      type: state.type,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      linkedTransactionId: state.linkedTransactionId,
      // Preserve original createdAt on edit — overwriting with `now`
      // would corrupt the audit trail in Firestore.
      createdAt: state.originalCreatedAt ?? now,
      updatedAt: now,
    );

    (state.isEditing
            ? await _updateTransaction(transaction)
            : await _createTransaction(transaction))
        .fold(
          (failure) => emit(
            state.copyWith(
              status: FormStatus.failure,
              failure: failure,
            ),
          ),
          // Surface the saved id so listeners (e.g. the bill-settlement
          // flow) can chain follow-up work like linking the bill to
          // this transaction. For updates it's just `existingId`.
          (saved) => emit(
            state.copyWith(
              status: FormStatus.success,
              savedTransactionId: saved.id,
            ),
          ),
        );
  }

  Future<void> _submitTransfer() async {
    final now = DateTime.now();
    final expense = TransactionEntity(
      id: '',
      userId: state.userId,
      accountId: state.accountId,
      categoryId: '',
      type: TransactionType.expense,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      createdAt: now,
      updatedAt: now,
    );
    final income = TransactionEntity(
      id: '',
      userId: state.userId,
      accountId: state.destinationAccountId,
      categoryId: '',
      type: TransactionType.income,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      createdAt: now,
      updatedAt: now,
    );

    (await _createTransfer(expense: expense, income: income)).fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.failure, failure: failure),
      ),
      (_) => emit(state.copyWith(status: FormStatus.success)),
    );
  }

  /// Edits an existing transfer by updating *both* legs. `existingId` is the
  /// expense (source) leg, `linkedTransactionId` the income (destination)
  /// leg — normalized at form open by [_resolveTransferCounterpart]. Each
  /// leg keeps its own `createdAt` so the audit trail isn't corrupted.
  ///
  /// The two writes aren't atomic: a failure between them can leave the
  /// legs divergent. Mirrors the existing non-batched create path; a proper
  /// fix needs a repository-level transfer update.
  Future<void> _updateTransfer() async {
    final now = DateTime.now();
    final expense = TransactionEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      accountId: state.accountId,
      categoryId: '',
      type: TransactionType.expense,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      linkedTransactionId: state.linkedTransactionId,
      createdAt: state.originalCreatedAt ?? now,
      updatedAt: now,
    );
    final income = TransactionEntity(
      id: state.linkedTransactionId ?? '',
      userId: state.userId,
      accountId: state.destinationAccountId,
      categoryId: '',
      type: TransactionType.income,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      linkedTransactionId: state.existingId,
      createdAt: state.destinationCreatedAt ?? now,
      updatedAt: now,
    );

    final expenseResult = await _updateTransaction(expense);
    final expenseFailure = expenseResult.fold((f) => f, (_) => null);
    if (expenseFailure != null) {
      emit(state.copyWith(status: FormStatus.failure, failure: expenseFailure));
      return;
    }
    (await _updateTransaction(income)).fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.failure, failure: failure),
      ),
      (_) => emit(state.copyWith(status: FormStatus.success)),
    );
  }
}

class TransactionFormState extends Equatable {
  const TransactionFormState({
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.accountId,
    required this.categoryId,
    required this.notes,
    required this.status,
    required this.isTransfer,
    this.destinationAccountId = '',
    this.existingId,
    this.linkedTransactionId,
    this.originalCreatedAt,
    this.destinationCreatedAt,
    this.savedTransactionId,
    this.continueAfterSave = false,
    this.failure,
  });

  factory TransactionFormState.initial({
    required String userId,
    TransactionEntity? existing,
    String? prefillAccountId,
  }) {
    if (existing != null && existing.isTransfer) {
      return TransactionFormState._forTransferEdit(
        userId: userId,
        tapped: existing,
      );
    }
    return TransactionFormState(
      userId: userId,
      type: existing?.type ?? TransactionType.expense,
      amount: existing?.amount ?? 0,
      description: existing?.description ?? '',
      date: existing?.date ?? DateTime.now(),
      // Prefill only matters in create mode — when editing, the existing
      // accountId always wins so we never silently rewrite it.
      accountId: existing?.accountId ?? prefillAccountId ?? '',
      categoryId: existing?.categoryId ?? '',
      notes: existing?.notes ?? '',
      status: FormStatus.initial,
      isTransfer: false,
      existingId: existing?.id,
      linkedTransactionId: existing?.linkedTransactionId,
      originalCreatedAt: existing?.createdAt,
    );
  }

  /// Seeds the form from one leg of a transfer being edited. A transfer is
  /// a pair: the expense leg holds the source account, the income leg the
  /// destination. Only the tapped leg is known here, but its
  /// `linkedTransactionId` already identifies the other leg — so both
  /// transaction ids are known up front and `existingId`/`linkedTransactionId`
  /// are normalized to expense/income respectively. The counterpart leg's
  /// *account* is filled in later by `_resolveTransferCounterpart`.
  factory TransactionFormState._forTransferEdit({
    required String userId,
    required TransactionEntity tapped,
  }) {
    final tappedIsExpense = tapped.type == TransactionType.expense;
    return TransactionFormState(
      userId: userId,
      type: tapped.type,
      amount: tapped.amount,
      description: tapped.description,
      date: tapped.date,
      accountId: tappedIsExpense ? tapped.accountId : '',
      destinationAccountId: tappedIsExpense ? '' : tapped.accountId,
      categoryId: '',
      notes: tapped.notes ?? '',
      status: FormStatus.initial,
      isTransfer: true,
      existingId: tappedIsExpense ? tapped.id : tapped.linkedTransactionId,
      linkedTransactionId: tappedIsExpense
          ? tapped.linkedTransactionId
          : tapped.id,
      originalCreatedAt: tappedIsExpense ? tapped.createdAt : null,
      destinationCreatedAt: tappedIsExpense ? null : tapped.createdAt,
    );
  }

  final String userId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final String accountId;
  final String categoryId;
  final String notes;
  final FormStatus status;
  final bool isTransfer;
  final String destinationAccountId;
  final String? existingId;
  final String? linkedTransactionId;

  /// Captured at form open time on edit so `_submitTransaction` /
  /// `_updateTransfer` can preserve the (expense leg, when a transfer)
  /// transaction's original `createdAt`. `null` in create mode — submit
  /// falls back to `DateTime.now()`.
  final DateTime? originalCreatedAt;

  /// The income (destination) leg's original `createdAt`, captured when
  /// editing a transfer so `_updateTransfer` preserves its audit trail.
  /// `null` outside transfer edits.
  final DateTime? destinationCreatedAt;

  /// Set on `FormStatus.success` to the id of the row written by the
  /// last submit (created or updated). Lets callers — e.g. the bill
  /// settlement flow — chain follow-ups without re-fetching.
  final String? savedTransactionId;

  /// Mirrors the flag passed to `submit()` so the page can tell, on
  /// `FormStatus.success`, whether to navigate away (false) or keep the
  /// user on the form with prefilled fields (true) for fast back-to-back
  /// entry. Reset to false by `prepareForNext()`.
  final bool continueAfterSave;
  final Failure? failure;

  bool get isEditing => existingId != null;

  bool get _isDateValid {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return !date.isAfter(endOfToday);
  }

  bool get isValid {
    if (amount <= 0 || !_isDateValid || accountId.isEmpty) return false;

    if (isTransfer) {
      return destinationAccountId.isNotEmpty &&
          accountId != destinationAccountId;
    }

    return categoryId.isNotEmpty;
  }

  TransactionFormState copyWith({
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    String? accountId,
    String? categoryId,
    String? destinationAccountId,
    String? notes,
    FormStatus? status,
    bool? isTransfer,
    DateTime? originalCreatedAt,
    DateTime? destinationCreatedAt,
    String? savedTransactionId,
    bool? continueAfterSave,
    Failure? failure,
  }) {
    return TransactionFormState(
      userId: userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      isTransfer: isTransfer ?? this.isTransfer,
      existingId: existingId,
      linkedTransactionId: linkedTransactionId,
      // These are only ever assigned (filling in the counterpart leg on
      // transfer edit), never cleared — so `?? this.` is correct.
      originalCreatedAt: originalCreatedAt ?? this.originalCreatedAt,
      destinationCreatedAt: destinationCreatedAt ?? this.destinationCreatedAt,
      savedTransactionId: savedTransactionId ?? this.savedTransactionId,
      continueAfterSave: continueAfterSave ?? this.continueAfterSave,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    type,
    amount,
    description,
    date,
    accountId,
    categoryId,
    destinationAccountId,
    notes,
    status,
    isTransfer,
    existingId,
    linkedTransactionId,
    originalCreatedAt,
    destinationCreatedAt,
    savedTransactionId,
    continueAfterSave,
    failure,
  ];
}
