import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';

class BillModel extends BillEntity {
  const BillModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.description,
    required super.amount,
    required super.dueDate,
    required super.status,
    required super.recurrence,
    required super.createdAt,
    required super.updatedAt,
    super.categoryId,
    super.notes,
    super.paidAt,
    super.paidTransactionId,
    super.parentBillId,
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    return BillModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory BillModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    // Legacy bills stored before BillType existed default to payable.
    final rawType = data['type'] as String?;
    return BillModel(
      id: id,
      userId: data['userId'] as String,
      type: rawType == null
          ? BillType.payable
          : BillType.values.byName(rawType),
      description: data['description'] as String,
      amount: (data['amount'] as num).toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: BillStatus.values.byName(data['status'] as String),
      recurrence: BillRecurrence.values.byName(data['recurrence'] as String),
      categoryId: data['categoryId'] as String?,
      notes: data['notes'] as String?,
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      paidTransactionId: data['paidTransactionId'] as String?,
      parentBillId: data['parentBillId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory BillModel.fromEntity(BillEntity entity) {
    return BillModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      description: entity.description,
      amount: entity.amount,
      dueDate: entity.dueDate,
      status: entity.status,
      recurrence: entity.recurrence,
      categoryId: entity.categoryId,
      notes: entity.notes,
      paidAt: entity.paidAt,
      paidTransactionId: entity.paidTransactionId,
      parentBillId: entity.parentBillId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type.name,
      'description': description,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status.name,
      'recurrence': recurrence.name,
      'categoryId': categoryId,
      'notes': notes,
      'paidAt': paidAt == null ? null : Timestamp.fromDate(paidAt!),
      'paidTransactionId': paidTransactionId,
      'parentBillId': parentBillId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
