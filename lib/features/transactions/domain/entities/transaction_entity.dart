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
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTransfer => linkedTransactionId != null;
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
    createdAt,
    updatedAt,
  ];
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);
