import 'package:financo/features/bills/domain/entities/bill_entity.dart';

class BillFactory {
  const BillFactory._();

  static BillEntity pending({
    String id = 'bill-1',
    String userId = 'user-1',
    String description = 'Internet',
    double amount = 120,
    DateTime? dueDate,
    BillRecurrence recurrence = BillRecurrence.oneShot,
    String? categoryId,
    String? notes,
    String? parentBillId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = createdAt ?? DateTime(2026, 4);
    return BillEntity(
      id: id,
      userId: userId,
      description: description,
      amount: amount,
      dueDate: dueDate ?? DateTime(2026, 4, 30),
      status: BillStatus.pending,
      recurrence: recurrence,
      categoryId: categoryId,
      notes: notes,
      parentBillId: parentBillId,
      createdAt: now,
      updatedAt: updatedAt ?? now,
    );
  }

  static BillEntity overdue({
    String id = 'bill-overdue',
    String userId = 'user-1',
    String description = 'Aluguel',
    double amount = 1500,
    DateTime? dueDate,
  }) {
    final today = DateTime.now();
    return pending(
      id: id,
      userId: userId,
      description: description,
      amount: amount,
      dueDate: dueDate ?? today.subtract(const Duration(days: 5)),
    );
  }

  static BillEntity paid({
    String id = 'bill-paid',
    String userId = 'user-1',
    String description = 'Luz',
    double amount = 200,
    DateTime? dueDate,
    String paidTransactionId = 'tx-paid-1',
    BillRecurrence recurrence = BillRecurrence.oneShot,
  }) {
    final now = DateTime(2026, 4);
    return BillEntity(
      id: id,
      userId: userId,
      description: description,
      amount: amount,
      dueDate: dueDate ?? DateTime(2026, 4),
      status: BillStatus.paid,
      recurrence: recurrence,
      paidAt: DateTime(2026, 4, 2, 10, 30),
      paidTransactionId: paidTransactionId,
      createdAt: now,
      updatedAt: DateTime(2026, 4, 2, 10, 30),
    );
  }

  static BillEntity monthly({
    String id = 'bill-monthly',
    String description = 'Internet',
    double amount = 120,
    DateTime? dueDate,
  }) {
    return pending(
      id: id,
      description: description,
      amount: amount,
      dueDate: dueDate,
      recurrence: BillRecurrence.monthly,
    );
  }
}
