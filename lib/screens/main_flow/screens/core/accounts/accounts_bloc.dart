import 'dart:async';

import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/managers/account_balance_manager.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/managers/account_loader.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/managers/transaction_summary_manager.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/transaction_account_data.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';

CoreAccountsBloc get coreAccountsBloc => Modular.get<CoreAccountsBloc>();

class CoreAccountsBloc extends GetxController {
  CoreAccountsBloc() {
    _initializeBloc();
  }

  final RxList<TransactionsAccount> checkingAccounts =
      <TransactionsAccount>[].obs;

  final TransactionSummaryManager _transactionSummaryManager =
      TransactionSummaryManager();

  final RxDouble _totalAllAccountsBalance = 0.0.obs;
  final RxDouble _totalAllAccountsProjectedBalance = 0.0.obs;

  void _initializeBloc() {
    unawaited(loadCheckingAccounts());
    _setupCalendarListener();
  }

  void _setupCalendarListener() {
    ever(coreCalendarBloc.selected, (_) async {
      await updateFilteredBalances();
    });
  }

  Future<void> loadCheckingAccounts() async {
    final accounts = await AccountLoader.loadCheckingAccounts();
    checkingAccounts.assignAll(accounts);

    for (final account in accounts) {
      ever(account.isEnabled, (_) async {
        await updateFilteredBalances();
      });
    }

    await updateFilteredBalances();
  }

  Future<void> updateFilteredBalances() async {
    await AccountBalanceManager.updateFilteredBalances(checkingAccounts);
    await _updateTransactionSummary();
    _updateTotals();
  }

  void _updateTotals() {
    final enabledAccounts = checkingAccounts.where(
      (account) => account.isEnabled.value,
    );

    _totalAllAccountsBalance.value = enabledAccounts.fold<double>(
      0,
      (sum, account) => sum + account.filteredBalance.value,
    );

    _totalAllAccountsProjectedBalance.value = enabledAccounts.fold<double>(
      0,
      (sum, account) => sum + account.filteredProjectedBalance.value,
    );
  }

  RxDouble get totalFilteredBalance {
    final total = checkingAccounts
        .where((account) => account.isEnabled.value)
        .fold<double>(0, (sum, account) => sum + account.filteredBalance.value);
    return total.obs;
  }

  RxDouble get totalFilteredProjectedBalance {
    final total = checkingAccounts
        .where((account) => account.isEnabled.value)
        .fold<double>(
          0,
          (sum, account) => sum + account.filteredProjectedBalance.value,
        );
    return total.obs;
  }

  RxDouble get totalAllAccountsBalance => _totalAllAccountsBalance;

  RxDouble get totalAllAccountsProjectedBalance =>
      _totalAllAccountsProjectedBalance;

  Set<int> get enabledAccountIds =>
      AccountBalanceManager.getEnabledAccountIds(checkingAccounts);

  Future<void> _updateTransactionSummary() async {
    await _transactionSummaryManager.updateTransactionSummary(
      accountIds: enabledAccountIds,
    );
  }

  void enableAllAccounts() {
    for (final account in checkingAccounts) {
      account.isEnabled.value = true;
    }
  }
}
