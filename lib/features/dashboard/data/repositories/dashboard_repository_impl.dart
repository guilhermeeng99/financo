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
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';
import 'package:financo/features/investing/domain/services/institution_valuation_reader.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required InstitutionRepository institutionRepository,
    required InstitutionValuationReader institutionValuationReader,
  }) : _transactionRepo = transactionRepository,
       _accountRepo = accountRepository,
       _categoryRepo = categoryRepository,
       _institutionRepo = institutionRepository,
       _valuationReader = institutionValuationReader;

  final TransactionRepository _transactionRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;
  final InstitutionRepository _institutionRepo;
  final InstitutionValuationReader _valuationReader;

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

    // Investing side (F8.2): the investment "accounts" are institutions,
    // valued at market. Loaded best-effort — a failure here degrades the
    // Dashboard to its cash-only view rather than erroring the whole page.
    final institutionsResult = await _institutionRepo.getInstitutions(
      userId: userId,
      forceRefresh: forceRefresh,
    );
    final institutions = institutionsResult.getOrElse(() => const []);
    final institutionValuations = await _valuationReader.read(userId);
    final investmentAccounts = _buildInvestmentAccounts(
      institutions,
      institutionValuations,
    );

    return accountsResult.fold(
      Left.new,
      (accounts) => allTimeResult.fold(
        Left.new,
        (rawTransactions) => categoriesResult.fold(
          Left.new,
          (categories) {
            final allTransactions = rawTransactions
                .where((t) => t.isPaid)
                .toList();
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
              investmentAccounts: investmentAccounts,
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

  /// Maps each institution to a market-valued Dashboard row. Institutions with
  /// no holdings surface as zero (so the user still sees their brokers), and
  /// the list is sorted by market value, descending.
  List<InvestmentAccountRow> _buildInvestmentAccounts(
    List<Institution> institutions,
    Map<String, InstitutionValuation> valuations,
  ) {
    final rows = institutions.map((institution) {
      final valuation =
          valuations[institution.id] ?? const InstitutionValuation.zero();
      return InvestmentAccountRow(
        institutionId: institution.id,
        name: institution.name,
        marketValue: valuation.marketValue.major,
        invested: valuation.invested.major,
        bank: institution.bank,
        color: institution.color,
        currencyCode: institution.currency.code,
        priceStale: valuation.priceStale,
      );
    }).toList()..sort((a, b) => b.marketValue.compareTo(a.marketValue));
    return rows;
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
