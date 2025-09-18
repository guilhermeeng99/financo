import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

class AccountBalanceService {
  static Future<Map<int, double>> getAccountBalances({
    required Set<int> accountIds,
    required DateTime startDate,
    required DateTime endDate,
    bool onlyPaidTransactions = true,
  }) async {
    final transactionUsecase = Modular.get<ITransactionUsecase>();

    final balancesResult = await transactionUsecase
        .getMultipleAccountsBalanceForPeriod(
          accountIds,
          startDate,
          endDate,
          onlyPaidTransactions: onlyPaidTransactions,
        );

    return balancesResult.fold((Failure failure) {
      logger.e(
        'Error getting account balances (onlyPaid: $onlyPaidTransactions): ${failure.message}',
      );
      return <int, double>{};
    }, (Map<int, double> balances) => balances);
  }

  static Future<double> getAccountBalanceForDate(
    int accountId,
    DateTime selectedDate,
  ) async {
    try {
      final endOfPeriod = DateTimeUtils.getEndOfMonth(selectedDate);
      final transactionUsecase = Modular.get<ITransactionUsecase>();

      final balanceResult = await transactionUsecase.getAccountBalanceForPeriod(
        accountId,
        DateTimeUtils.getHistoricalStart(),
        endOfPeriod,
      );

      return balanceResult.fold((Failure failure) {
        logger.e('Error getting account balance for date: ${failure.message}');
        return 0.0;
      }, (double balance) => balance);
    } catch (e) {
      logger.e('❌ Unexpected error getting account balance for date: $e');
      return 0.0;
    }
  }

  static Future<double> getTotalAccountsBalanceForDate(
    Set<int> accountIds,
    DateTime selectedDate,
  ) async {
    if (accountIds.isEmpty) return 0.0;

    try {
      final endOfPeriod = DateTimeUtils.getEndOfMonth(selectedDate);
      final transactionUsecase = Modular.get<ITransactionUsecase>();

      final balancesResult = await transactionUsecase
          .getMultipleAccountsBalanceForPeriod(
            accountIds,
            DateTimeUtils.getHistoricalStart(),
            endOfPeriod,
          );

      return balancesResult.fold(
        (Failure failure) {
          logger.e('Error getting total balance for date: ${failure.message}');
          return 0.0;
        },
        (Map<int, double> balances) => balances.values.fold<double>(
          0,
          (double sum, double balance) => sum + balance,
        ),
      );
    } catch (e) {
      logger.e('❌ Unexpected error getting total balance for date: $e');
      return 0.0;
    }
  }

  static Future<Map<int, double>> getFilteredBalances(
    Set<int> accountIds,
    DateTime endOfPeriod, {
    bool onlyPaid = true,
  }) async {
    final transactionUsecase = Modular.get<ITransactionUsecase>();

    final balancesResult = await transactionUsecase
        .getMultipleAccountsBalanceForPeriod(
          accountIds,
          DateTimeUtils.getHistoricalStart(),
          endOfPeriod,
          onlyPaidTransactions: onlyPaid,
        );

    return balancesResult.fold((Failure failure) {
      logger.e(
        'Error updating ${onlyPaid ? 'filtered' : 'projected'} balances: ${failure.message}',
      );
      return <int, double>{};
    }, (Map<int, double> balances) => balances);
  }
}

class DateTimeUtils {
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static DateTime getHistoricalStart() {
    return DateTime(1900);
  }
}
