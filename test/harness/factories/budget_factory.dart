import 'package:financo/features/budgets/domain/entities/budget_entity.dart';

class BudgetFactory {
  const BudgetFactory._();

  static BudgetEntity make({
    String id = 'budget-1',
    String userId = 'user-1',
    String categoryId = 'cat-1',
    double amount = 1500,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final ts = createdAt ?? DateTime(2026, 4);
    return BudgetEntity(
      id: id,
      userId: userId,
      categoryId: categoryId,
      amount: amount,
      createdAt: ts,
      updatedAt: updatedAt ?? ts,
    );
  }
}
