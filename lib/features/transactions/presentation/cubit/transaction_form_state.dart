import 'package:equatable/equatable.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

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
  /// last submit (created or updated). Lets callers chain follow-ups without
  /// re-fetching.
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
    return !isAfterEndOfToday(date);
  }

  bool get isValid {
    if (amount <= 0 || !_isDateValid || accountId.isEmpty) return false;

    if (isTransfer) {
      return destinationAccountId.isNotEmpty &&
          accountId != destinationAccountId;
    }

    return categoryId.isNotEmpty;
  }

  /// Copy of this state ready for the next back-to-back entry: every
  /// user-entered field stays in place while the transient post-submit
  /// flags (`status`, `savedTransactionId`, `continueAfterSave`,
  /// `failure`) reset to their defaults. Reconstructed instead of
  /// `copyWith` because `copyWith` can never clear nullable fields.
  TransactionFormState clearedForNextEntry() {
    return TransactionFormState(
      userId: userId,
      type: type,
      amount: amount,
      description: description,
      date: date,
      accountId: accountId,
      categoryId: categoryId,
      destinationAccountId: destinationAccountId,
      notes: notes,
      status: FormStatus.initial,
      isTransfer: isTransfer,
      existingId: existingId,
      linkedTransactionId: linkedTransactionId,
      settlementStatus: settlementStatus,
      recurrence: recurrence,
      recurrenceGroupId: recurrenceGroupId,
      recurrenceIntervalMonths: recurrenceIntervalMonths,
      recurrenceIndex: recurrenceIndex,
      recurrenceTotal: recurrenceTotal,
      recurrenceBaseDescription: recurrenceBaseDescription,
      recurrenceEndDate: recurrenceEndDate,
      installmentCount: installmentCount,
      originalDueDate: originalDueDate,
      originalTransaction: originalTransaction,
    );
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

/// True when [date] falls strictly after the end of today (local time).
/// Shared by the form state's date validation and the cubit, which
/// auto-marks future-dated rows as pending settlement.
bool isAfterEndOfToday(DateTime date) {
  final now = DateTime.now();
  final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return date.isAfter(endOfToday);
}
