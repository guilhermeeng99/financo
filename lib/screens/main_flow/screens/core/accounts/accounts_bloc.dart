import 'dart:async';

import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/managers/account_balance_manager.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/managers/account_loader.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/managers/transaction_summary_manager.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_account.dart';

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
    ever(calendarFilterBloc.selected, (_) {
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

  double get totalEnabledAccountsBalance =>
      AccountBalanceManager.getTotalEnabledAccountsBalance(checkingAccounts);

  Set<int> get enabledAccountIds =>
      AccountBalanceManager.getEnabledAccountIds(checkingAccounts);

  Future<double> getTotalEnabledAccountsBalanceForDate(DateTime selectedDate) =>
      AccountBalanceManager.getTotalEnabledAccountsBalanceForDate(
        checkingAccounts,
        selectedDate,
      );

  Future<double> getAccountBalanceForDate(
    int accountId,
    DateTime selectedDate,
  ) => AccountBalanceManager.getAccountBalanceForDate(accountId, selectedDate);

  RxDouble get projectedTotalIncome =>
      _transactionSummaryManager.projectedTotalIncome;
  RxDouble get projectedTotalExpense =>
      _transactionSummaryManager.projectedTotalExpense;
  RxDouble get projectedTotalTransfersIn =>
      _transactionSummaryManager.projectedTotalTransfersIn;
  RxDouble get projectedTotalTransfersOut =>
      _transactionSummaryManager.projectedTotalTransfersOut;
  RxDouble get projectedTotalResult =>
      _transactionSummaryManager.projectedTotalResult;

  Future<void> _updateTransactionSummary() async {
    await _transactionSummaryManager.updateTransactionSummary(
      accountIds: enabledAccountIds,
    );
  }

  Future<void> updateTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _transactionSummaryManager.updateTransactionSummary(
      accountIds: enabledAccountIds,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
