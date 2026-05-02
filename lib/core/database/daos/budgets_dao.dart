import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/budgets_table.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [LocalBudgets])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.attachedDatabase);

  Future<void> insertAllBudgets(List<BudgetEntity> budgets) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localBudgets,
        budgets.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertBudget(BudgetEntity budget) =>
      into(localBudgets).insertOnConflictUpdate(_toCompanion(budget));

  Future<List<BudgetEntity>> getBudgets({required String userId}) async {
    final query = select(localBudgets)
      ..where((b) => b.userId.equals(userId))
      ..orderBy([(b) => OrderingTerm.asc(b.createdAt)]);
    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  Future<BudgetEntity?> getBudgetById(String id) async {
    final row = await (select(
      localBudgets,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> deleteBudget(String id) =>
      (delete(localBudgets)..where((b) => b.id.equals(id))).go();

  Future<void> deleteAllBudgets() => delete(localBudgets).go();

  LocalBudgetsCompanion _toCompanion(BudgetEntity e) =>
      LocalBudgetsCompanion.insert(
        id: e.id,
        userId: e.userId,
        categoryId: e.categoryId,
        amount: e.amount,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  BudgetEntity _toEntity(LocalBudget row) => BudgetEntity(
    id: row.id,
    userId: row.userId,
    categoryId: row.categoryId,
    amount: row.amount,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
