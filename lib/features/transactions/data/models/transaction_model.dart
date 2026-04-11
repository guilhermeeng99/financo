import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.accountId,
    required super.categoryId,
    required super.type,
    required super.amount,
    required super.description,
    required super.date,
    required super.isReconciled,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] as String,
      accountId: data['accountId'] as String,
      categoryId: data['categoryId'] as String,
      type: TransactionType.values.byName(data['type'] as String),
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] as String,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      isReconciled: data['isReconciled'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      type: entity.type,
      amount: entity.amount,
      description: entity.description,
      date: entity.date,
      notes: entity.notes,
      isReconciled: entity.isReconciled,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accountId': accountId,
      'categoryId': categoryId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'isReconciled': isReconciled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
