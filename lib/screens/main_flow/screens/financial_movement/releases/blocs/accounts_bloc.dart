import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_account.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/services/account_balance_service.dart';

AccountsBloc get accountsBloc => Modular.get<AccountsBloc>();

class AccountsBloc extends GetxController {
  AccountsBloc() {
    loadCheckingAccounts();
  }

  final RxList<TransactionsAccount> checkingAccounts =
      <TransactionsAccount>[].obs;


  Future<void> loadCheckingAccounts() async {
    final accountUsecase = Modular.get<IAccountUsecase>();

    try {
      final result = await accountUsecase.getCheckingAccounts();

      result.fold(
        _handleLoadAccountsError,
        (checkingAccountsList) async =>
            _processLoadedAccounts(checkingAccountsList),
      );
    } catch (e) {
      logger.e('❌ Unexpected error loading checking accounts: $e');
      _showErrorMessage('Failed to load accounts');
    }
  }

  void _handleLoadAccountsError(Failure failure) {
    logger.e('Error loading checking accounts: ${failure.message}');
    CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
  }

  Future<void> _processLoadedAccounts(
    List<AccountData> checkingAccountsList,
  ) async {
    final accountsI = <TransactionsAccount>[];
    final accountIds = checkingAccountsList.map((a) => a.id).toSet();

    final balances = await _getAccountBalances(accountIds);
    final projectedBalances = await _getAccountBalances(
      accountIds,
      onlyPaid: false,
    );

    for (final account in checkingAccountsList) {
      final finalBalance = balances[account.id] ?? account.initialBalance;
      final finalProjectedBalance =
          projectedBalances[account.id] ?? account.initialBalance;

      final accountI = TransactionsAccount(
        account: account,
        finalBalance: finalBalance,
        finalProjectedBalance: finalProjectedBalance,
      );
      accountsI.add(accountI);
    }

    checkingAccounts.value = accountsI;


    logger.i('Checking accounts loaded from database');
  }

  Future<Map<int, double>> _getAccountBalances(
    Set<int> accountIds, {
    bool onlyPaid = true,
  }) async {
    return AccountBalanceService.getAccountBalances(
      accountIds: accountIds,
      startDate: DateTimeUtils.getHistoricalStart(),
      endDate: DateTime.now(),
      onlyPaidTransactions: onlyPaid,
    );
  }


  void _showErrorMessage(String message) {
    CWSnackBar.snackBar(title: message, type: SnackBarType.error);
  }

  double get totalEnabledAccountsBalance {
    return checkingAccounts
        .where((account) => account.isEnabled.value)
        .fold(0, (sum, account) => sum + account.finalBalance);
  }

  Set<int> get enabledAccountIds {
    return checkingAccounts
        .where((account) => account.isEnabled.value)
        .map((account) => account.account.id)
        .toSet();
  }

  Future<double> getTotalEnabledAccountsBalanceForDate(
    DateTime selectedDate,
  ) async {
    if (checkingAccounts.isEmpty) return 0.0;

    final enabledAccountIds = this.enabledAccountIds;
    if (enabledAccountIds.isEmpty) return 0.0;

    return AccountBalanceService.getTotalAccountsBalanceForDate(
      enabledAccountIds,
      selectedDate,
    );
  }

  Future<double> getAccountBalanceForDate(
    int accountId,
    DateTime selectedDate,
  ) async {
    return AccountBalanceService.getAccountBalanceForDate(
      accountId,
      selectedDate,
    );
  }

  @override
  void onClose() {
    for (final account in checkingAccounts) {
      account.dispose();
    }
    checkingAccounts.close();
    super.onClose();
  }
}
