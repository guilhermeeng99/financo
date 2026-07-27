import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

enum TransactionSettlementStatus { pending, paid }

enum TransactionRecurrence { single, installment, fixed }

enum TransactionSequenceScope { onlyThis, thisAndFollowing }

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.settlementStatus = TransactionSettlementStatus.paid,
    DateTime? dueDate,
    this.settledAt,
    this.recurrence = TransactionRecurrence.single,
    this.recurrenceGroupId,
    this.recurrenceIntervalMonths = 1,
    this.recurrenceIndex,
    this.recurrenceTotal,
    this.recurrenceBaseDescription,
    this.recurrenceEndDate,
    this.notes,
    this.linkedTransactionId,
    this.institutionId,
    this.linkedInvestmentTransactionId,
  }) : dueDate = dueDate ?? date;

  final String id;
  final String userId;
  final String accountId;
  final String categoryId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionSettlementStatus settlementStatus;
  final DateTime dueDate;
  final DateTime? settledAt;
  final TransactionRecurrence recurrence;
  final String? recurrenceGroupId;
  final int recurrenceIntervalMonths;
  final int? recurrenceIndex;
  final int? recurrenceTotal;
  final String? recurrenceBaseDescription;
  final DateTime? recurrenceEndDate;
  final String? notes;
  final String? linkedTransactionId;

  /// When set, this cash transaction is an investment aporte/resgate whose
  /// counterparty is an institution (not a second account). An expense marks
  /// money leaving a checking account into the broker (aporte); an income marks
  /// a payout back (resgate). Drives the 50/30/20 savings bucket after F8.
  /// See docs/specs/investing_account_unification.md.
  final String? institutionId;

  /// The `investment_transactions` doc (buy/sell) that generated this cash-flow
  /// row. Non-null only alongside [institutionId]; drives the linked lifecycle
  /// (edit/delete the investment transaction cascades to this row).
  final String? linkedInvestmentTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTransfer => linkedTransactionId != null;

  /// True when this is an investment aporte/resgate (cash ↔ institution).
  bool get isInvestmentCashFlow => institutionId != null;

  /// Recasts this transfer leg as a single-entry investment cash flow tagged to
  /// [institutionId]: the account↔account [linkedTransactionId] is cleared and
  /// [institutionId] is set. Used by the F8.5 migration when an investment
  /// account is folded into an institution — `copyWith` can't clear a nullable
  /// field, so this rebuilds the entity. See
  /// `docs/specs/investing_account_unification.md` §6.
  TransactionEntity asInstitutionCashFlow(String institutionId) {
    return TransactionEntity(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      description: description,
      date: date,
      settlementStatus: settlementStatus,
      dueDate: dueDate,
      settledAt: settledAt,
      recurrence: recurrence,
      recurrenceGroupId: recurrenceGroupId,
      recurrenceIntervalMonths: recurrenceIntervalMonths,
      recurrenceIndex: recurrenceIndex,
      recurrenceTotal: recurrenceTotal,
      recurrenceBaseDescription: recurrenceBaseDescription,
      recurrenceEndDate: recurrenceEndDate,
      notes: notes,
      institutionId: institutionId,
      linkedInvestmentTransactionId: linkedInvestmentTransactionId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  bool get isRecurring => recurrence != TransactionRecurrence.single;
  bool get isPending => settlementStatus == TransactionSettlementStatus.pending;
  bool get isPaid => settlementStatus == TransactionSettlementStatus.paid;
  bool get isPayable => type == TransactionType.expense;
  bool get isReceivable => type == TransactionType.income;

  bool get isOverdue {
    if (!isPending) return false;
    final today = _startOfDay(DateTime.now());
    return _startOfDay(dueDate).isBefore(today);
  }

  bool get isDueToday {
    if (!isPending) return false;
    final today = _startOfDay(DateTime.now());
    return _startOfDay(dueDate).isAtSameMomentAs(today);
  }

  TransactionEntity copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? date,
    TransactionSettlementStatus? settlementStatus,
    DateTime? dueDate,
    DateTime? settledAt,
    TransactionRecurrence? recurrence,
    String? recurrenceGroupId,
    int? recurrenceIntervalMonths,
    int? recurrenceIndex,
    int? recurrenceTotal,
    String? recurrenceBaseDescription,
    DateTime? recurrenceEndDate,
    String? notes,
    String? linkedTransactionId,
    String? institutionId,
    String? linkedInvestmentTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      dueDate: dueDate ?? this.dueDate,
      settledAt: settledAt ?? this.settledAt,
      recurrence: recurrence ?? this.recurrence,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      recurrenceIntervalMonths:
          recurrenceIntervalMonths ?? this.recurrenceIntervalMonths,
      recurrenceIndex: recurrenceIndex ?? this.recurrenceIndex,
      recurrenceTotal: recurrenceTotal ?? this.recurrenceTotal,
      recurrenceBaseDescription:
          recurrenceBaseDescription ?? this.recurrenceBaseDescription,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      notes: notes ?? this.notes,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
      institutionId: institutionId ?? this.institutionId,
      linkedInvestmentTransactionId:
          linkedInvestmentTransactionId ?? this.linkedInvestmentTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    accountId,
    categoryId,
    type,
    amount,
    description,
    date,
    settlementStatus,
    dueDate,
    settledAt,
    recurrence,
    recurrenceGroupId,
    recurrenceIntervalMonths,
    recurrenceIndex,
    recurrenceTotal,
    recurrenceBaseDescription,
    recurrenceEndDate,
    notes,
    linkedTransactionId,
    institutionId,
    linkedInvestmentTransactionId,
    createdAt,
    updatedAt,
  ];
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);
