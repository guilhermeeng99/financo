import 'package:equatable/equatable.dart';

/// Monthly cap on spending for a single root expense category. Spending is
/// derived from existing `transactions` records — budgets only carry the
/// cap and metadata, never the spend itself.
///
/// See `specs/budgets.md` for the business rules. Quick recap:
/// - One budget per `(userId, categoryId)`.
/// - `categoryId` must reference a root expense category.
/// - `amount` must be `> 0`.
/// - `categoryId` is immutable after creation.
class BudgetEntity extends Equatable {
  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetEntity copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    amount,
    createdAt,
    updatedAt,
  ];
}
