import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/services/account_balance_service.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_account.dart';

class AccountBalanceManager {
  static Future<void> updateFilteredBalances(
    RxList<TransactionsAccount> checkingAccounts,
  ) async {
    final allAccountIds = checkingAccounts
        .map((account) => account.account.id)
        .toSet();

    if (allAccountIds.isEmpty) {
      _resetAccountBalances(checkingAccounts);
      return;
    }

    final balances = await _getAccountBalances(allAccountIds);
    final projectedBalances = await _getAccountBalances(
      allAccountIds,
      onlyPaid: false,
    );

    _updateAllAccountBalances(checkingAccounts, balances, projectedBalances);
  }

  static Set<int> _getEnabledAccountIds(RxList<TransactionsAccount> accounts) {
    return accounts
        .where((account) => account.isEnabled.value)
        .map((account) => account.account.id)
        .toSet();
  }

  static void _resetAccountBalances(RxList<TransactionsAccount> accounts) {
    for (final account in accounts) {
      account.filteredBalance.value = 0.0;
      account.filteredProjectedBalance.value = 0.0;
    }
  }

  static void _updateAllAccountBalances(
    RxList<TransactionsAccount> accounts,
    Map<int, double> balances,
    Map<int, double> projectedBalances,
  ) {
    for (final account in accounts) {
      account.filteredBalance.value = balances[account.account.id] ?? 0.0;
      account.filteredProjectedBalance.value =
          projectedBalances[account.account.id] ?? 0.0;
    }
  }

  static Future<Map<int, double>> _getAccountBalances(
    Set<int> accountIds, {
    bool onlyPaid = true,
  }) async {
    if (accountIds.isEmpty) return {};

    // For account balances, we want accumulated balance up to the end of selected period
    final startDate = DateTime(2000); // From beginning of time
    final endDate = calendarFilterBloc.endOfPeriod;

    return AccountBalanceService.getAccountBalances(
      accountIds: accountIds,
      startDate: startDate,
      endDate: endDate,
      onlyPaidTransactions: onlyPaid,
    );
  }

  static Future<double> getTotalEnabledAccountsBalanceForDate(
    RxList<TransactionsAccount> accounts,
    DateTime selectedDate,
  ) async {
    final enabledIds = _getEnabledAccountIds(accounts);

    if (enabledIds.isEmpty) return 0.0;

    final futures = enabledIds.map(
      (id) => AccountBalanceService.getAccountBalanceForDate(id, selectedDate),
    );
    final balances = await Future.wait(futures);

    return balances.fold<double>(0, (sum, balance) => sum + balance);
  }

  static Future<double> getAccountBalanceForDate(
    int accountId,
    DateTime selectedDate,
  ) async {
    return AccountBalanceService.getAccountBalanceForDate(
      accountId,
      selectedDate,
    );
  }

  static double getTotalEnabledAccountsBalance(
    RxList<TransactionsAccount> accounts,
  ) {
    return accounts
        .where((account) => account.isEnabled.value)
        .fold(0, (sum, account) => sum + account.filteredBalance.value);
  }

  static Set<int> getEnabledAccountIds(RxList<TransactionsAccount> accounts) {
    return accounts
        .where((account) => account.isEnabled.value)
        .map((account) => account.account.id)
        .toSet();
  }
}
