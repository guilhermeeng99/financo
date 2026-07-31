import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/accounts/domain/services/account_fx_converter.dart';
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
    required AccountFxConverter accountFxConverter,
  }) : _transactionRepo = transactionRepository,
       _accountRepo = accountRepository,
       _categoryRepo = categoryRepository,
       _institutionRepo = institutionRepository,
       _valuationReader = institutionValuationReader,
       _fxConverter = accountFxConverter;

  final TransactionRepository _transactionRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;
  final InstitutionRepository _institutionRepo;
  final InstitutionValuationReader _valuationReader;
  final AccountFxConverter _fxConverter;

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
    final accountsFailure = accountsResult.fold<Failure?>(
      (f) => f,
      (_) => null,
    );
    if (accountsFailure != null) return Left(accountsFailure);
    final accounts = accountsResult.getOrElse(() => const []);

    // Single query: all transactions up to end of selected month.
    final allTimeResult = await _transactionRepo.getTransactions(
      userId: userId,
      endDate: endOfMonth(month),
      forceRefresh: forceRefresh,
    );
    final txFailure = allTimeResult.fold<Failure?>((f) => f, (_) => null);
    if (txFailure != null) return Left(txFailure);
    final rawTransactions = allTimeResult.getOrElse(() => const []);

    final categoriesResult = await _categoryRepo.getCategories(
      userId: userId,
      forceRefresh: forceRefresh,
    );
    final catFailure = categoriesResult.fold<Failure?>((f) => f, (_) => null);
    if (catFailure != null) return Left(catFailure);
    final categories = categoriesResult.getOrElse(() => const []);

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

    // F9: current-FX rates to consolidate foreign accounts into a BRL estimate.
    final rates = await _fxConverter.ratesToBrl(
      accounts.map((a) => a.currency),
    );
    final currencyById = {for (final a in accounts) a.id: a.currency};

    double toBrl(double amount, Currency currency) {
      if (currency == Currency.brl) return amount;
      final rate = rates[currency];
      // No rate (offline + cold cache): fall back to a 1:1 estimate rather than
      // dropping the amount — the roll-up is explicitly an estimate (F9).
      return rate == null ? amount : amount * rate;
    }

    final allTransactions = rawTransactions.where((t) => t.isPaid).toList();
    final periodStart = startOfMonth(month);
    final period = allTransactions
        .where((t) => !t.date.isBefore(periodStart))
        .toList();

    // Balances stay native (per-account); the BRL estimate is derived alongside
    // so the UI can show each account in its own currency and one BRL total.
    final accountAdjustments = <String, double>{};
    for (final t in allTransactions) {
      final delta = t.type == TransactionType.income ? t.amount : -t.amount;
      accountAdjustments[t.accountId] =
          (accountAdjustments[t.accountId] ?? 0) + delta;
    }
    final adjustedAccounts = accounts.map((a) {
      final adj = accountAdjustments[a.id] ?? 0;
      return a.copyWith(initialBalance: a.initialBalance + adj);
    }).toList();

    final accountBrlById = <String, double>{
      for (final a in adjustedAccounts)
        a.id: toBrl(a.initialBalance, a.currency),
    };
    final totalBalance = accountBrlById.values.fold<double>(0, (s, v) => s + v);

    // Every combined figure (income/expenses, category breakdowns, 50/30/20) is
    // computed on period transactions consolidated to BRL. BRL-only users are
    // unaffected — toBrl is the identity at rate 1.
    final periodBrl = period.map((t) {
      final currency = currencyById[t.accountId] ?? Currency.brl;
      return t.copyWith(amount: toBrl(t.amount, currency));
    }).toList();

    final totalIncome = periodBrl
        .where(
          (t) =>
              t.type == TransactionType.income &&
              !t.isTransfer &&
              !t.isInvestmentCashFlow,
        )
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpenses = periodBrl
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              !t.isTransfer &&
              !t.isInvestmentCashFlow,
        )
        .fold<double>(0, (sum, t) => sum + t.amount);

    final categoryMap = <String, CategoryEntity>{
      for (final c in categories) c.id: c,
    };
    final expensesByCategory = _aggregateByCategory(
      periodBrl.where(
        (t) =>
            t.type == TransactionType.expense &&
            !t.isTransfer &&
            !t.isInvestmentCashFlow,
      ),
      categoryMap,
    );
    final incomeByCategory = _aggregateByCategory(
      periodBrl.where(
        (t) =>
            t.type == TransactionType.income &&
            !t.isTransfer &&
            !t.isInvestmentCashFlow,
      ),
      categoryMap,
    );

    final fiftyThirtyTwenty = compute50_30_20Overview(
      periodTransactions: periodBrl,
      categories: categories,
      accounts: adjustedAccounts,
      // An aporte lands on an institution, not on an account (F8) — this is
      // the join point where the dashboard already holds both.
      hasInvestmentDestination: institutions.isNotEmpty,
      targets: fiftyThirtyTwentyTargets,
    );

    return Right(
      DashboardSummary(
        totalBalance: totalBalance,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        netResult: totalIncome - totalExpenses,
        accounts: adjustedAccounts,
        accountBrlById: accountBrlById,
        investmentAccounts: investmentAccounts,
        expensesByCategory: expensesByCategory,
        incomeByCategory: incomeByCategory,
        fiftyThirtyTwenty: fiftyThirtyTwenty,
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
        nativeValue: valuation.marketValueNative.major,
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
