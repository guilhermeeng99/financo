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
    required super.createdAt,
    required super.updatedAt,
    super.notes,
    super.linkedTransactionId,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    return TransactionModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory TransactionModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return TransactionModel(
      id: id,
      userId: data['userId'] as String,
      accountId: data['accountId'] as String,
      categoryId: data['categoryId'] as String,
      type: TransactionType.values.byName(data['type'] as String),
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] as String,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      linkedTransactionId: data['linkedTransactionId'] as String?,
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
      linkedTransactionId: entity.linkedTransactionId,
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
      'linkedTransactionId': linkedTransactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
