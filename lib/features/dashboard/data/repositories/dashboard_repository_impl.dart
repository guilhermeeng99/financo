import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:financo/features/dashboard/domain/services/compute_fifty_thirty_twenty.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
  }) : _transactionRepo = transactionRepository,
       _accountRepo = accountRepository,
       _categoryRepo = categoryRepository;

  final TransactionRepository _transactionRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    required String userId,
    required DateTime month,
    bool forceRefresh = false,
    FiftyThirtyTwentyTargets fiftyThirtyTwentyTargets =
        FiftyThirtyTwentyTargets.classic,
  }) async {
    final accountsResult = await _accountRepo.getAccounts(
      userId: userId,
      forceRefresh: forceRefresh,
    );
    // Single query: all transactions up to end of selected month
    final allTimeResult = await _transactionRepo.getTransactions(
      userId: userId,
      endDate: endOfMonth(month),
      forceRefresh: forceRefresh,
    );
    final categoriesResult = await _categoryRepo.getCategories(
      userId: userId,
      forceRefresh: forceRefresh,
    );

    return accountsResult.fold(
      Left.new,
      (accounts) => allTimeResult.fold(
        Left.new,
        (allTransactions) => categoriesResult.fold(
          Left.new,
          (categories) {
            // Filter locally for period transactions
            final periodStart = startOfMonth(month);
            final transactions = allTransactions
                .where((t) => !t.date.isBefore(periodStart))
                .toList();

            // Cumulative: stored balance + all transactions up to month end
            final accountAdjustments = <String, double>{};
            for (final t in allTransactions) {
              final delta = t.type == TransactionType.income
                  ? t.amount
                  : -t.amount;
              accountAdjustments[t.accountId] =
                  (accountAdjustments[t.accountId] ?? 0) + delta;
            }

            final adjustedAccounts = accounts.map((a) {
              final adj = accountAdjustments[a.id] ?? 0;
              return a.copyWith(initialBalance: a.initialBalance + adj);
            }).toList();

            final totalBalance = adjustedAccounts.fold<double>(
              0,
              (sum, account) => sum + account.initialBalance,
            );

            final totalIncome = transactions
                .where(
                  (t) => t.type == TransactionType.income && !t.isTransfer,
                )
                .fold<double>(0, (sum, t) => sum + t.amount);

            final totalExpenses = transactions
                .where(
                  (t) => t.type == TransactionType.expense && !t.isTransfer,
                )
                .fold<double>(0, (sum, t) => sum + t.amount);

            final categoryMap = <String, CategoryEntity>{
              for (final c in categories) c.id: c,
            };

            final expensesByCategory = _aggregateByCategory(
              transactions.where(
                (t) => t.type == TransactionType.expense && !t.isTransfer,
              ),
              categoryMap,
            );

            final incomeByCategory = _aggregateByCategory(
              transactions.where(
                (t) => t.type == TransactionType.income && !t.isTransfer,
              ),
              categoryMap,
            );

            // 50/30/20 reuses the period transactions, categories and
            // accounts we already have on hand — no extra IO. See
            // docs/specs/fifty_thirty_twenty.md §3.
            final fiftyThirtyTwenty = compute50_30_20Overview(
              periodTransactions: transactions,
              categories: categories,
              accounts: adjustedAccounts,
              targets: fiftyThirtyTwentyTargets,
            );

            final summary = DashboardSummary(
              totalBalance: totalBalance,
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              netResult: totalIncome - totalExpenses,
              accounts: adjustedAccounts,
              expensesByCategory: expensesByCategory,
              incomeByCategory: incomeByCategory,
              fiftyThirtyTwenty: fiftyThirtyTwenty,
            );

            return Right(summary);
          },
        ),
      ),
    );
  }

  List<CategoryAmount> _aggregateByCategory(
    Iterable<TransactionEntity> transactions,
    Map<String, CategoryEntity> categoryMap,
  ) {
    final amounts = <String, double>{};
    for (final t in transactions) {
      final cat = categoryMap[t.categoryId];
      // Resolve to parent category if this is a subcategory
      final rootId = cat?.parentId ?? t.categoryId;
      amounts[rootId] = (amounts[rootId] ?? 0) + t.amount;
    }
    return amounts.entries.map((e) {
      final cat = categoryMap[e.key];
      return CategoryAmount(
        categoryId: e.key,
        categoryName: cat?.name ?? 'Sem categoria',
        categoryColor: cat?.color ?? 0xFF9E9E9E,
        amount: e.value,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
  }
}
