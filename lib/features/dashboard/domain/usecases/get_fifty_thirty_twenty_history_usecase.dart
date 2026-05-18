import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/accounts/domain/repositories/account_repository.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_history_entry.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/domain/services/compute_fifty_thirty_twenty.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Composes the user's 50/30/20 overview for each of the last `monthCount`
/// months (current month inclusive), in chronological order. Single
/// network/cache read for the whole window — transactions are fetched
/// once and bucketed locally per month, avoiding N round-trips.
///
/// Accounts and categories are not period-scoped, so they're fetched
/// once and reused across all months.
///
/// Example: with `monthCount: 3` on 2026-05-17 the use case returns
/// `[March 2026, April 2026, May 2026]`.
class GetFiftyThirtyTwentyHistoryUseCase {
  const GetFiftyThirtyTwentyHistoryUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
  }) : _transactionRepo = transactionRepository,
       _accountRepo = accountRepository,
       _categoryRepo = categoryRepository;

  final TransactionRepository _transactionRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;

  Future<Either<Failure, List<FiftyThirtyTwentyHistoryEntry>>> call({
    required String userId,
    required DateTime referenceMonth,
    int monthCount = 3,
    FiftyThirtyTwentyTargets targets = FiftyThirtyTwentyTargets.classic,
    bool forceRefresh = false,
  }) async {
    assert(monthCount >= 1, 'monthCount must be >= 1');

    final months = _buildMonthList(referenceMonth, monthCount);
    final windowStart = startOfMonth(months.first);
    final windowEnd = endOfMonth(months.last);

    final accountsResult = await _accountRepo.getAccounts(
      userId: userId,
      forceRefresh: forceRefresh,
    );
    final txResult = await _transactionRepo.getTransactions(
      userId: userId,
      startDate: windowStart,
      endDate: windowEnd,
      forceRefresh: forceRefresh,
    );
    final categoriesResult = await _categoryRepo.getCategories(
      userId: userId,
      forceRefresh: forceRefresh,
    );

    return accountsResult.fold(
      Left.new,
      (accounts) => txResult.fold(
        Left.new,
        (transactions) => categoriesResult.fold(Left.new, (categories) {
          final entries = months.map((month) {
            final periodStart = startOfMonth(month);
            final periodEnd = endOfMonth(month);
            final monthTxs = transactions
                .where(
                  (t) =>
                      !t.date.isBefore(periodStart) &&
                      !t.date.isAfter(periodEnd),
                )
                .toList();
            final overview = compute50_30_20Overview(
              periodTransactions: monthTxs,
              categories: categories,
              accounts: accounts,
              targets: targets,
            );
            return FiftyThirtyTwentyHistoryEntry(
              month: periodStart,
              overview: overview,
            );
          }).toList();
          return Right(entries);
        }),
      ),
    );
  }

  /// Builds `monthCount` ordered DateTimes ending at [reference]'s month,
  /// stepping backwards. E.g. reference = 2026-05-17, count = 3 →
  /// `[2026-03-01, 2026-04-01, 2026-05-01]`.
  List<DateTime> _buildMonthList(DateTime reference, int count) {
    final base = startOfMonth(reference);
    return List<DateTime>.generate(
      count,
      (i) => DateTime(base.year, base.month - (count - 1 - i)),
    );
  }
}
