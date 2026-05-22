import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:financo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Deletes a category after moving its transactions to another category and
/// cascade-deleting any budgets bound to it. Centralises the multi-step
/// cascade that used to live in the add-category page so it is testable and
/// reusable (e.g. from chat actions).
///
/// Steps:
/// 1. Reassign transactions `from` → `to`. Must succeed — its failure is
///    returned so the UI can surface it and keep the category intact.
/// 2. Cascade-delete budgets bound to the category. Best-effort: failures are
///    logged but not fatal, since orphan budgets are tolerated by the overview
///    pipeline (see docs/specs/budgets.md rule 7-8).
/// 3. Delete the category itself.
///
/// Example:
/// ```dart
/// final result = await deleteCategoryWithReassignment(
///   userId: userId,
///   fromCategoryId: categoryId,
///   toCategoryId: targetId,
/// );
/// result.fold((f) => showError(f), (_) => Navigator.pop(context, true));
/// ```
class DeleteCategoryWithReassignmentUseCase {
  const DeleteCategoryWithReassignmentUseCase({
    required TransactionRepository transactionRepository,
    required GetBudgetsUseCase getBudgets,
    required DeleteBudgetUseCase deleteBudget,
    required DeleteCategoryUseCase deleteCategory,
  }) : _transactions = transactionRepository,
       _getBudgets = getBudgets,
       _deleteBudget = deleteBudget,
       _deleteCategory = deleteCategory;

  final TransactionRepository _transactions;
  final GetBudgetsUseCase _getBudgets;
  final DeleteBudgetUseCase _deleteBudget;
  final DeleteCategoryUseCase _deleteCategory;

  Future<Either<Failure, void>> call({
    required String userId,
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    final reassign = await _transactions.reassignTransactions(
      fromCategoryId: fromCategoryId,
      toCategoryId: toCategoryId,
    );
    if (reassign.isLeft()) return reassign;

    await _cascadeDeleteBudgets(userId: userId, categoryId: fromCategoryId);

    return _deleteCategory(fromCategoryId);
  }

  Future<void> _cascadeDeleteBudgets({
    required String userId,
    required String categoryId,
  }) async {
    final budgetsResult = await _getBudgets(userId: userId);
    final budgets = budgetsResult.fold<List<BudgetEntity>>((failure) {
      log(
        'Budget cascade lookup failed; orphan budgets may remain. '
        '${failure.message}',
        name: 'CategoryDelete',
      );
      return const [];
    }, (list) => list);

    for (final b in budgets) {
      if (b.categoryId != categoryId) continue;
      final result = await _deleteBudget(b.id);
      result.fold(
        (failure) => log(
          'Budget cascade delete failed for ${b.id}. ${failure.message}',
          name: 'CategoryDelete',
        ),
        (_) {},
      );
    }
  }
}
