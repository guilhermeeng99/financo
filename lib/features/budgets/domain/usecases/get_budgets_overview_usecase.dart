import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/entities/budget_overview.dart';
import 'package:financo/features/budgets/domain/repositories/budget_repository.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Composes budgets + categories + period transactions into a list of
/// `BudgetOverview` ready for the UI. Mirrors the composition pattern used
/// by `DashboardRepositoryImpl.getDashboardSummary` — three sequential
/// fetches, fold short-circuits on first failure.
///
/// Spending semantics (per `docs/specs/budgets.md` rule 5):
/// - Filter to `type == expense`, exclude transfers, scope to `[start, end]`
///   of the requested month.
/// - Sub-category transactions roll up into their parent's total.
/// - Orphan budgets (whose category was deleted) are silently skipped.
class GetBudgetsOverviewUseCase {
  const GetBudgetsOverviewUseCase({
    required BudgetRepository budgetRepository,
    required CategoryRepository categoryRepository,
    required TransactionRepository transactionRepository,
  }) : _budgetRepo = budgetRepository,
       _categoryRepo = categoryRepository,
       _transactionRepo = transactionRepository;

  final BudgetRepository _budgetRepo;
  final CategoryRepository _categoryRepo;
  final TransactionRepository _transactionRepo;

  Future<Either<Failure, List<BudgetOverview>>> call({
    required String userId,
    required DateTime month,
    bool forceRefresh = false,
  }) async {
    final budgetsResult = await _budgetRepo.getBudgets(
      userId: userId,
      forceRefresh: forceRefresh,
    );
    final categoriesResult = await _categoryRepo.getCategories(
      userId: userId,
      forceRefresh: forceRefresh,
    );
    final txResult = await _transactionRepo.getTransactions(
      userId: userId,
      startDate: startOfMonth(month),
      endDate: endOfMonth(month),
      forceRefresh: forceRefresh,
    );

    return budgetsResult.fold(
      Left.new,
      (budgets) => categoriesResult.fold(
        Left.new,
        (categories) => txResult.fold(Left.new, (transactions) {
          return Right(_compose(budgets, categories, transactions));
        }),
      ),
    );
  }

  List<BudgetOverview> _compose(
    List<BudgetEntity> budgets,
    List<CategoryEntity> categories,
    List<TransactionEntity> transactions,
  ) {
    final byId = <String, CategoryEntity>{
      for (final c in categories) c.id: c,
    };

    // Walk transactions once and bucket spend by *root* category id. A
    // transaction booked on a subcategory contributes to its parent so a
    // single lookup covers both rule-5 paths (root and child).
    final spentByRoot = <String, double>{};
    for (final t in transactions) {
      if (!t.isPaid) continue;
      if (t.type != TransactionType.expense) continue;
      if (t.isTransfer) continue;
      final cat = byId[t.categoryId];
      // If the category resolves, route to its root; otherwise the
      // transaction is on an orphan category — no budget can match it
      // anyway, so we drop it from the spend buckets.
      if (cat == null) continue;
      final rootId = cat.parentId ?? cat.id;
      spentByRoot[rootId] = (spentByRoot[rootId] ?? 0) + t.amount;
    }

    final overviews = <BudgetOverview>[];
    for (final b in budgets) {
      final cat = byId[b.categoryId];
      // Orphan tolerance — see spec rule 8. Skip silently so the user's
      // dashboard doesn't show a row that can't be acted on.
      if (cat == null) continue;
      // The repo already enforces "root expense" at write-time, but
      // defensive: skip if the referenced category drifted to a child or
      // was retyped by an external write.
      if (cat.parentId != null) continue;
      overviews.add(
        BudgetOverview(
          budget: b,
          categoryName: cat.name,
          categoryIcon: cat.icon,
          categoryColor: cat.color,
          spent: spentByRoot[b.categoryId] ?? 0,
        ),
      );
    }

    // Sort by category name to match the rest of the categories UX.
    overviews.sort(
      (a, b) =>
          a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()),
    );
    return overviews;
  }
}
