import 'dart:async';

import 'package:dartz/dartz.dart';
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
import 'package:financo/features/transactions/presentation/cubit/transaction_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:financo/features/transactions/presentation/cubit/transaction_form_state.dart';

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
    final settlementStatus = !state.isTransfer && isAfterEndOfToday(date)
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
            isAfterEndOfToday(state.date)
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
  void prepareForNext() => emit(state.clearedForNextEntry());

  Future<void> _submitTransaction({
    required TransactionSequenceScope sequenceScope,
  }) async {
    final now = DateTime.now();
    final transaction = _assembleSubmittedTransaction(now);

    final result = state.isEditing
        ? await _updateSavedTransaction(
            original: state.originalTransaction,
            transaction: transaction,
            sequenceScope: sequenceScope,
          )
        : await _createSavedTransaction(transaction, now);

    emit(_stateAfterSave(result));
  }

  /// Builds the entity persisted by a normal (non-transfer) submit from
  /// the current form state.
  TransactionEntity _assembleSubmittedTransaction(DateTime now) {
    final isPaid = state.settlementStatus == TransactionSettlementStatus.paid;
    return TransactionEntity(
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
      recurrenceGroupId: _recurrenceOnly(state.recurrenceGroupId),
      recurrenceIntervalMonths: state.recurrenceIntervalMonths,
      recurrenceIndex: _recurrenceOnly(state.recurrenceIndex),
      recurrenceTotal: _recurrenceOnly(state.recurrenceTotal),
      recurrenceBaseDescription: _recurrenceOnly(
        state.recurrenceBaseDescription ?? state.description,
      ),
      recurrenceEndDate: _recurrenceOnly(state.recurrenceEndDate),
      notes: state.notes,
      linkedTransactionId: state.linkedTransactionId,
      // Preserve original createdAt on edit — overwriting with `now`
      // would corrupt the audit trail in Firestore.
      createdAt: state.originalCreatedAt ?? now,
      updatedAt: now,
    );
  }

  /// Sequence metadata is only persisted for recurring rows; single
  /// transactions store `null` so stale values never survive an edit.
  T? _recurrenceOnly<T>(T? value) =>
      state.recurrence == TransactionRecurrence.single ? null : value;

  TransactionFormState _stateAfterSave(
    Either<Failure, TransactionEntity> result,
  ) {
    return result.fold(
      (failure) => state.copyWith(
        status: FormStatus.failure,
        failure: failure,
      ),
      // Surface the saved id so listeners can chain follow-up work without
      // re-fetching. For updates it's just `existingId`.
      (saved) => state.copyWith(
        status: FormStatus.success,
        savedTransactionId: saved.id,
      ),
    );
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
    final expense = _assembleTransferLeg(
      type: TransactionType.expense,
      accountId: state.accountId,
      now: now,
    );
    final income = _assembleTransferLeg(
      type: TransactionType.income,
      accountId: state.destinationAccountId,
      now: now,
    );

    (await _createTransfer(expense: expense, income: income)).fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.failure, failure: failure),
      ),
      (_) => emit(state.copyWith(status: FormStatus.success)),
    );
  }

  /// Builds one leg of a transfer pair from the shared form fields.
  /// Transfer legs carry no category and are always settled on the form
  /// date. [createdAt] preserves the leg's original audit timestamp when
  /// editing; `null` (create mode) falls back to [now].
  TransactionEntity _assembleTransferLeg({
    required TransactionType type,
    required String accountId,
    required DateTime now,
    String id = '',
    String? linkedTransactionId,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id,
      userId: state.userId,
      accountId: accountId,
      categoryId: '',
      type: type,
      amount: state.amount,
      description: state.description,
      date: state.date,
      notes: state.notes,
      linkedTransactionId: linkedTransactionId,
      dueDate: state.date,
      settledAt: state.date,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }

  /// Edits an existing transfer by updating *both* legs. `existingId` is the
  /// expense (source) leg, `linkedTransactionId` the income (destination)
  /// leg — normalized at form open by [_resolveTransferCounterpart]. Each
  /// leg keeps its own `createdAt` so the audit trail isn't corrupted.
  Future<void> _updateTransfer() async {
    final now = DateTime.now();
    final expense = _assembleTransferLeg(
      type: TransactionType.expense,
      accountId: state.accountId,
      now: now,
      id: state.existingId ?? '',
      linkedTransactionId: state.linkedTransactionId,
      createdAt: state.originalCreatedAt,
    );
    final income = _assembleTransferLeg(
      type: TransactionType.income,
      accountId: state.destinationAccountId,
      now: now,
      id: state.linkedTransactionId ?? '',
      linkedTransactionId: state.existingId,
      createdAt: state.destinationCreatedAt,
    );
    await _updateTransferLegs(expense: expense, income: income);
  }

  /// The two writes aren't atomic: a failure between them can leave the
  /// legs divergent. Mirrors the existing non-batched create path; a proper
  /// fix needs a repository-level transfer update.
  Future<void> _updateTransferLegs({
    required TransactionEntity expense,
    required TransactionEntity income,
  }) async {
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

int _clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}
