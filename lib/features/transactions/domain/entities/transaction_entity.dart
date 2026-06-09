import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

enum TransactionSettlementStatus { pending, paid }

enum TransactionRecurrence { oneShot, monthly }

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
    this.recurrence = TransactionRecurrence.oneShot,
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
  final String? notes;
  final String? linkedTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTransfer => linkedTransactionId != null;
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
    notes,
    linkedTransactionId,
    createdAt,
    updatedAt,
  ];
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);
