import 'package:equatable/equatable.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

enum BillStatus { pending, paid }

enum BillRecurrence { oneShot, monthly }

class BillEntity extends Equatable {
  const BillEntity({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.recurrence,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.notes,
    this.paidAt,
    this.paidTransactionId,
    this.parentBillId,
  });

  final String id;
  final String userId;
  final String description;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;
  final BillRecurrence recurrence;
  final String? categoryId;
  final String? notes;
  final DateTime? paidAt;
  final String? paidTransactionId;
  final String? parentBillId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == BillStatus.pending;
  bool get isPaid => status == BillStatus.paid;

  bool get isOverdue {
    if (status != BillStatus.pending) return false;
    final today = _startOfDay(DateTime.now());
    return _startOfDay(dueDate).isBefore(today);
  }

  bool get isDueToday {
    if (status != BillStatus.pending) return false;
    final today = _startOfDay(DateTime.now());
    return _startOfDay(dueDate).isAtSameMomentAs(today);
  }

  BillEntity copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    DateTime? dueDate,
    BillStatus? status,
    BillRecurrence? recurrence,
    String? categoryId,
    String? notes,
    DateTime? paidAt,
    String? paidTransactionId,
    String? parentBillId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      recurrence: recurrence ?? this.recurrence,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      paidAt: paidAt ?? this.paidAt,
      paidTransactionId: paidTransactionId ?? this.paidTransactionId,
      parentBillId: parentBillId ?? this.parentBillId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    description,
    amount,
    dueDate,
    status,
    recurrence,
    categoryId,
    notes,
    paidAt,
    paidTransactionId,
    parentBillId,
    createdAt,
    updatedAt,
  ];
}

class BillPaymentResult extends Equatable {
  const BillPaymentResult({
    required this.paidBill,
    required this.transaction,
    this.nextOccurrence,
  });

  final BillEntity paidBill;
  final TransactionEntity transaction;
  final BillEntity? nextOccurrence;

  @override
  List<Object?> get props => [paidBill, transaction, nextOccurrence];
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
