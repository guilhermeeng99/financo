import 'package:equatable/equatable.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

enum BillStatus { pending, paid }

enum BillRecurrence { oneShot, monthly }

/// Whether this bill represents money the user owes (`payable`,
/// e.g. internet bill) or money the user is expecting to receive
/// (`receivable`, e.g. salary). Immutable once the bill is created.
enum BillType { payable, receivable }

class BillEntity extends Equatable {
  const BillEntity({
    required this.id,
    required this.userId,
    required this.type,
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
    this.rejectedTransactionIds = const [],
  });

  final String id;
  final String userId;
  final BillType type;
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

  /// Transactions the user has explicitly said are NOT this bill via the
  /// match-suggestion flow. Used to silence already-rejected pairs on
  /// every subsequent scan. New monthly occurrences start with `[]`,
  /// so coincidences in future months prompt again.
  final List<String> rejectedTransactionIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == BillStatus.pending;
  bool get isPaid => status == BillStatus.paid;
  bool get isPayable => type == BillType.payable;
  bool get isReceivable => type == BillType.receivable;

  /// `true` when this entity is a not-yet-persisted projection (preview of
  /// a future monthly occurrence). The empty-string id is the project's
  /// canonical sentinel for "no Firestore document yet" — it's also used
  /// transiently at creation time before the remote insert returns.
  bool get isVirtual => id.isEmpty;

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
    BillType? type,
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
    List<String>? rejectedTransactionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
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
      rejectedTransactionIds:
          rejectedTransactionIds ?? this.rejectedTransactionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
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
    rejectedTransactionIds,
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
