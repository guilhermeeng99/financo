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

  void _initializeBloc() {
    loadCheckingAccounts();
    _setupCalendarListener();
  }

  void _setupCalendarListener() {
    ever(coreCalendarBloc.selected, (_) {
      updateFilteredBalances();
    });
  }

  Future<void> loadCheckingAccounts() async {
    final accounts = await AccountLoader.loadCheckingAccounts();
    checkingAccounts.assignAll(accounts);

    // Add listener for each account's isEnabled property
    for (final account in accounts) {
      ever(account.isEnabled, (_) {
        updateFilteredBalances();
      });
    }

    await updateFilteredBalances();
  }

  Future<void> updateFilteredBalances() async {
    // Update individual account balances for all accounts
    await AccountBalanceManager.updateFilteredBalances(checkingAccounts);
    // Update transaction summary only for enabled accounts
    await _updateTransactionSummary();
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

  RxDouble get totalAllAccountsBalance {
    final total = checkingAccounts.fold<double>(
      0,
      (sum, account) => sum + account.filteredBalance.value,
    );
    return total.obs;
  }

  RxDouble get totalAllAccountsProjectedBalance {
    final total = checkingAccounts.fold<double>(
      0,
      (sum, account) => sum + account.filteredProjectedBalance.value,
    );
    return total.obs;
  }

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
