import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/services/recurring_transaction_builder.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_sequence_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit({
    required CreateTransactionUseCase createTransaction,
    required UpdateTransactionUseCase updateTransaction,
    required CreateTransferUseCase createTransfer,
    required GetTransactionUseCase getTransaction,
    required String userId,
    CreateTransactionsUseCase? createTransactions,
    UpdateTransactionSequenceUseCase? updateTransactionSequence,
    TransactionEntity? existingTransaction,
    String? prefillAccountId,
  }) : _createTransaction = createTransaction,
       _createTransactions = createTransactions,
       _updateTransaction = updateTransaction,
       _updateTransactionSequence = updateTransactionSequence,
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
  final CreateTransactionsUseCase? _createTransactions;
  final UpdateTransactionUseCase _updateTransaction;
  final UpdateTransactionSequenceUseCase? _updateTransactionSequence;
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

  void updateDate(DateTime date) {
    final settlementStatus = !state.isTransfer && _isAfterToday(date)
        ? TransactionSettlementStatus.pending
        : state.settlementStatus;
    emit(
      state.copyWith(
        date: date,
        settlementStatus: settlementStatus,
      ),
    );
  }

  void updateSettlementStatus(TransactionSettlementStatus settlementStatus) {
    final nextDate =
        settlementStatus == TransactionSettlementStatus.paid &&
            _isAfterToday(state.date)
        ? DateTime.now()
        : state.date;
    emit(
      state.copyWith(
        date: nextDate,
        settlementStatus: settlementStatus,
      ),
    );
  }

  void updateAccountId(String id) => emit(state.copyWith(accountId: id));

  void updateCategoryId(String id) => emit(state.copyWith(categoryId: id));

  void updateRecurrence(TransactionRecurrence recurrence) => emit(
    state.copyWith(
      recurrence: recurrence,
      recurrenceIntervalMonths: recurrence == TransactionRecurrence.single
          ? 1
          : state.recurrenceIntervalMonths,
      installmentCount: recurrence == TransactionRecurrence.installment
          ? state.installmentCount
          : 2,
    ),
  );

  void updateRecurrenceIntervalMonths(String value) {
    final parsed = int.tryParse(value) ?? 1;
    final interval = _clampInt(parsed, 1, kMaxRecurringWindowMonths);
    final maxInstallments = maxInstallmentsForInterval(interval);
    emit(
      state.copyWith(
        recurrenceIntervalMonths: interval,
        installmentCount: _clampInt(
          state.installmentCount,
          2,
          maxInstallments,
        ),
      ),
    );
  }

  void updateInstallmentCount(String value) {
    final parsed = int.tryParse(value) ?? 2;
    final maxInstallments = maxInstallmentsForInterval(
      state.recurrenceIntervalMonths,
    );
    emit(
      state.copyWith(
        installmentCount: _clampInt(parsed, 2, maxInstallments),
      ),
    );
  }

  void updateDestinationAccountId(String id) =>
      emit(state.copyWith(destinationAccountId: id));

  void updateNotes(String value) => emit(state.copyWith(notes: value));

  void setTransferMode({required bool enabled}) => emit(
    state.copyWith(
      isTransfer: enabled,
      settlementStatus: enabled
          ? TransactionSettlementStatus.paid
          : state.settlementStatus,
      recurrence: enabled ? TransactionRecurrence.single : state.recurrence,
    ),
  );

  /// Submits the form. When [continueAfterSave] is true, the resulting
  /// `success` state carries the same flag so the page can keep the user
  /// on the form (with all fields preserved) instead of popping the
  /// route. Used by the "+ create another" affordance for fast batch
  /// entry of similar transactions.
  Future<void> submit({
    bool continueAfterSave = false,
    TransactionSequenceScope sequenceScope = TransactionSequenceScope.onlyThis,
  }) async {
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
      await _submitTransaction(sequenceScope: sequenceScope);
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
        settlementStatus: state.settlementStatus,
        recurrence: state.recurrence,
        recurrenceGroupId: state.recurrenceGroupId,
        recurrenceIntervalMonths: state.recurrenceIntervalMonths,
        recurrenceIndex: state.recurrenceIndex,
        recurrenceTotal: state.recurrenceTotal,
        recurrenceBaseDescription: state.recurrenceBaseDescription,
        recurrenceEndDate: state.recurrenceEndDate,
        installmentCount: state.installmentCount,
        originalDueDate: state.originalDueDate,
        originalTransaction: state.originalTransaction,
      ),
    );
  }

  Future<void> _submitTransaction({
    required TransactionSequenceScope sequenceScope,
  }) async {
    final now = DateTime.now();
    final isPaid = state.settlementStatus == TransactionSettlementStatus.paid;
    final isRecurring = state.recurrence != TransactionRecurrence.single;
    final transaction = TransactionEntity(
      id: state.existingId ?? '',
      userId: state.userId,
      accountId: state.accountId,
      categoryId: state.categoryId,
      type: state.type,
      amount: state.amount,
      description: state.description,
      date: state.date,
      settlementStatus: state.settlementStatus,
      dueDate: state.date,
      settledAt: isPaid ? state.date : null,
      recurrence: state.recurrence,
      recurrenceGroupId: isRecurring ? state.recurrenceGroupId : null,
      recurrenceIntervalMonths: state.recurrenceIntervalMonths,
      recurrenceIndex: isRecurring ? state.recurrenceIndex : null,
      recurrenceTotal: isRecurring ? state.recurrenceTotal : null,
      recurrenceBaseDescription: isRecurring
          ? state.recurrenceBaseDescription ?? state.description
          : null,
      recurrenceEndDate: isRecurring ? state.recurrenceEndDate : null,
      notes: state.notes,
      linkedTransactionId: state.linkedTransactionId,
      // Preserve original createdAt on edit — overwriting with `now`
      // would corrupt the audit trail in Firestore.
      createdAt: state.originalCreatedAt ?? now,
      updatedAt: now,
    );

    final result = state.isEditing
        ? await _updateSavedTransaction(
            original: state.originalTransaction,
            transaction: transaction,
            sequenceScope: sequenceScope,
          )
        : await _createSavedTransaction(transaction, now);

    final nextState = result.fold(
      (failure) => state.copyWith(
        status: FormStatus.failure,
        failure: failure,
      ),
      // Surface the saved id so listeners (e.g. the bill-settlement
      // flow) can chain follow-up work like linking the bill to
      // this transaction. For updates it's just `existingId`.
      (saved) => state.copyWith(
        status: FormStatus.success,
        savedTransactionId: saved.id,
      ),
    );
    emit(nextState);
  }

  Future<Either<Failure, TransactionEntity>> _createSavedTransaction(
    TransactionEntity transaction,
    DateTime now,
  ) async {
    if (transaction.recurrence == TransactionRecurrence.single) {
      return _createTransaction(transaction);
    }

    final createTransactions = _createTransactions;
    if (createTransactions == null) return _createTransaction(transaction);

    final transactions = buildRecurringTransactions(
      template: transaction,
      now: now,
      installmentCount: state.installmentCount,
    );
    return (await createTransactions(transactions)).map(
      (created) => created.first,
    );
  }

  Future<Either<Failure, TransactionEntity>> _updateSavedTransaction({
    required TransactionEntity? original,
    required TransactionEntity transaction,
    required TransactionSequenceScope sequenceScope,
  }) async {
    final updateSequence = _updateTransactionSequence;
    if (original == null ||
        updateSequence == null ||
        sequenceScope == TransactionSequenceScope.onlyThis ||
        !original.isRecurring) {
      return _updateTransaction(_withOccurrenceDescription(transaction));
    }

    return (await updateSequence(
      original: original,
      updated: transaction,
      scope: sequenceScope,
    )).map((updated) => updated.isEmpty ? transaction : updated.first);
  }

  TransactionEntity _withOccurrenceDescription(TransactionEntity transaction) {
    if (transaction.recurrence != TransactionRecurrence.installment) {
      return transaction;
    }
    return transaction.copyWith(
      description: installmentDescription(
        baseDescription:
            transaction.recurrenceBaseDescription ?? transaction.description,
        index: transaction.recurrenceIndex ?? 1,
        total: transaction.recurrenceTotal ?? state.installmentCount,
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
      dueDate: state.date,
      settledAt: state.date,
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
      dueDate: state.date,
      settledAt: state.date,
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
      dueDate: state.date,
      settledAt: state.date,
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
      dueDate: state.date,
      settledAt: state.date,
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
    this.settlementStatus = TransactionSettlementStatus.paid,
    this.recurrence = TransactionRecurrence.single,
    this.recurrenceIntervalMonths = 1,
    this.installmentCount = 2,
    this.destinationAccountId = '',
    this.existingId,
    this.linkedTransactionId,
    this.recurrenceGroupId,
    this.recurrenceIndex,
    this.recurrenceTotal,
    this.recurrenceBaseDescription,
    this.recurrenceEndDate,
    this.originalDueDate,
    this.originalTransaction,
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
      description:
          existing?.recurrenceBaseDescription ?? existing?.description ?? '',
      date: existing?.dueDate ?? existing?.date ?? DateTime.now(),
      // Prefill only matters in create mode — when editing, the existing
      // accountId always wins so we never silently rewrite it.
      accountId: existing?.accountId ?? prefillAccountId ?? '',
      categoryId: existing?.categoryId ?? '',
      notes: existing?.notes ?? '',
      status: FormStatus.initial,
      isTransfer: false,
      settlementStatus:
          existing?.settlementStatus ?? TransactionSettlementStatus.paid,
      recurrence: existing?.recurrence ?? TransactionRecurrence.single,
      recurrenceGroupId: existing?.recurrenceGroupId,
      recurrenceIntervalMonths: existing?.recurrenceIntervalMonths ?? 1,
      recurrenceIndex: existing?.recurrenceIndex,
      recurrenceTotal: existing?.recurrenceTotal,
      recurrenceBaseDescription: existing?.recurrenceBaseDescription,
      recurrenceEndDate: existing?.recurrenceEndDate,
      installmentCount: existing?.recurrenceTotal ?? 2,
      originalDueDate: existing?.dueDate,
      originalTransaction: existing,
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
  final TransactionSettlementStatus settlementStatus;
  final TransactionRecurrence recurrence;
  final String? recurrenceGroupId;
  final int recurrenceIntervalMonths;
  final int? recurrenceIndex;
  final int? recurrenceTotal;
  final String? recurrenceBaseDescription;
  final DateTime? recurrenceEndDate;
  final int installmentCount;
  final String destinationAccountId;
  final String? existingId;
  final String? linkedTransactionId;
  final DateTime? originalDueDate;
  final TransactionEntity? originalTransaction;

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
  bool get isSequenceMember =>
      originalTransaction?.isRecurring ??
      recurrence != TransactionRecurrence.single;

  bool get _isDateValid {
    if (!isTransfer &&
        settlementStatus == TransactionSettlementStatus.pending) {
      return true;
    }
    return !_isAfterToday(date);
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
    TransactionSettlementStatus? settlementStatus,
    TransactionRecurrence? recurrence,
    String? recurrenceGroupId,
    int? recurrenceIntervalMonths,
    int? recurrenceIndex,
    int? recurrenceTotal,
    String? recurrenceBaseDescription,
    DateTime? recurrenceEndDate,
    int? installmentCount,
    DateTime? originalDueDate,
    TransactionEntity? originalTransaction,
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
      settlementStatus: settlementStatus ?? this.settlementStatus,
      recurrence: recurrence ?? this.recurrence,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      recurrenceIntervalMonths:
          recurrenceIntervalMonths ?? this.recurrenceIntervalMonths,
      recurrenceIndex: recurrenceIndex ?? this.recurrenceIndex,
      recurrenceTotal: recurrenceTotal ?? this.recurrenceTotal,
      recurrenceBaseDescription:
          recurrenceBaseDescription ?? this.recurrenceBaseDescription,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      installmentCount: installmentCount ?? this.installmentCount,
      existingId: existingId,
      linkedTransactionId: linkedTransactionId,
      originalDueDate: originalDueDate ?? this.originalDueDate,
      originalTransaction: originalTransaction ?? this.originalTransaction,
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
    settlementStatus,
    recurrence,
    recurrenceGroupId,
    recurrenceIntervalMonths,
    recurrenceIndex,
    recurrenceTotal,
    recurrenceBaseDescription,
    recurrenceEndDate,
    installmentCount,
    existingId,
    linkedTransactionId,
    originalDueDate,
    originalTransaction,
    originalCreatedAt,
    destinationCreatedAt,
    savedTransactionId,
    continueAfterSave,
    failure,
  ];
}

bool _isAfterToday(DateTime date) {
  final now = DateTime.now();
  final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return date.isAfter(endOfToday);
}

int _clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}
