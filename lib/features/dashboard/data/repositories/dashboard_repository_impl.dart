import 'package:dartz/dartz.dart';
import 'package:financo/core/cache/app_data_cache.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required AppDataCache cache,
  }) : _transactionRepo = transactionRepository,
       _accountRepo = accountRepository,
       _cache = cache;

  final TransactionRepository _transactionRepo;
  final AccountRepository _accountRepo;
  final AppDataCache _cache;

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary({
    required String userId,
    required DateTime month,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.dashboardSummary != null) {
      return Right(_cache.dashboardSummary!);
    }

    final accountsResult = await _accountRepo.getAccounts(userId: userId);
    final transactionsResult = await _transactionRepo.getTransactions(
      userId: userId,
      startDate: startOfMonth(month),
      endDate: endOfMonth(month),
    );

    return accountsResult.fold(
      Left.new,
      (accounts) => transactionsResult.fold(
        Left.new,
        (transactions) {
          final totalBalance = accounts.fold<double>(
            0,
            (sum, account) => sum + account.balance,
          );

          final totalIncome = transactions
              .where((t) => t.type == TransactionType.income)
              .fold<double>(0, (sum, t) => sum + t.amount);

          final totalExpenses = transactions
              .where((t) => t.type == TransactionType.expense)
              .fold<double>(0, (sum, t) => sum + t.amount);

          final summary = DashboardSummary(
            totalBalance: totalBalance,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            netResult: totalIncome - totalExpenses,
          );

          _cache.dashboardSummary = summary;
          return Right(summary);
        },
      ),
    );
  }
}
