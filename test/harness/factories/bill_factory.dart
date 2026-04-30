import 'package:financo/features/bills/domain/entities/bill_entity.dart';

class BillFactory {
  const BillFactory._();

  static BillEntity pending({
    String id = 'bill-1',
    String userId = 'user-1',
    BillType type = BillType.payable,
    String description = 'Internet',
    double amount = 120,
    DateTime? dueDate,
    BillRecurrence recurrence = BillRecurrence.oneShot,
    // Default to a non-null category so tests reflect the form-level rule
    // that bills must have one. Pass categoryId: null explicitly to model
    // legacy bills loaded from Firestore before the rule existed.
    String? categoryId = 'cat-1',
    String? notes,
    String? parentBillId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = createdAt ?? DateTime(2026, 4);
    return BillEntity(
      id: id,
      userId: userId,
      type: type,
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
    BillType type = BillType.payable,
    String description = 'Aluguel',
    double amount = 1500,
    DateTime? dueDate,
  }) {
    final today = DateTime.now();
    return pending(
      id: id,
      userId: userId,
      type: type,
      description: description,
      amount: amount,
      dueDate: dueDate ?? today.subtract(const Duration(days: 5)),
    );
  }

  static BillEntity paid({
    String id = 'bill-paid',
    String userId = 'user-1',
    BillType type = BillType.payable,
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
      type: type,
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
    BillType type = BillType.payable,
    String description = 'Internet',
    double amount = 120,
    DateTime? dueDate,
  }) {
    return pending(
      id: id,
      type: type,
      description: description,
      amount: amount,
      dueDate: dueDate,
      recurrence: BillRecurrence.monthly,
    );
  }

  static BillEntity receivable({
    String id = 'bill-receivable',
    String userId = 'user-1',
    String description = 'Salário',
    double amount = 5000,
    DateTime? dueDate,
    BillRecurrence recurrence = BillRecurrence.monthly,
    String? categoryId,
  }) {
    return pending(
      id: id,
      userId: userId,
      type: BillType.receivable,
      description: description,
      amount: amount,
      dueDate: dueDate ?? DateTime(2026, 4, 5),
      recurrence: recurrence,
      categoryId: categoryId,
    );
  }
}
