import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.amount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    return BudgetModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory BudgetModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return BudgetModel(
      id: id,
      userId: data['userId'] as String,
      categoryId: data['categoryId'] as String,
      amount: (data['amount'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
