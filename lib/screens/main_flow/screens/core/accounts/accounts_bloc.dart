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

  final RxList<TransactionsAccount> creditCardAccounts =
      <TransactionsAccount>[].obs;

  final TransactionSummaryManager _transactionSummaryManager =
      TransactionSummaryManager();

  final RxDouble _totalAllAccountsBalance = 0.0.obs;
  final RxDouble _totalAllAccountsProjectedBalance = 0.0.obs;

  void _initializeBloc() {
    unawaited(loadCheckingAccounts());
    unawaited(loadCreditCardAccounts());
    _setupCalendarListener();
  }

  void _setupCalendarListener() {
    ever(coreCalendarBloc.selected, (_) async {
      await updateFilteredBalances();
      await updateFilteredCreditCardBalances();
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

  Future<void> loadCreditCardAccounts() async {
    final accounts = await AccountLoader.loadCreditCardAccounts();
    creditCardAccounts.assignAll(accounts);

    for (final account in accounts) {
      ever(account.isEnabled, (_) async {
        await updateFilteredCreditCardBalances();
      });
    }

    await updateFilteredCreditCardBalances();
  }

  Future<void> updateFilteredBalances() async {
    await AccountBalanceManager.updateFilteredBalances(checkingAccounts);
    await _updateTransactionSummary();
    _updateTotals();
  }

  Future<void> updateFilteredCreditCardBalances() async {
    await AccountBalanceManager.updateFilteredBalances(creditCardAccounts);
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

  Set<int> get enabledCheckingAccountIds =>
      AccountBalanceManager.getEnabledAccountIds(checkingAccounts);

  Set<int> get enabledCreditCardAccountIds =>
      AccountBalanceManager.getEnabledAccountIds(creditCardAccounts);

  Future<void> _updateTransactionSummary() async {
    await _transactionSummaryManager.updateTransactionSummary(
      accountIds: enabledCheckingAccountIds,
    );
  }

  void enableAllAccounts() {
    for (final account in checkingAccounts) {
      account.isEnabled.value = true;
    }
    for (final account in creditCardAccounts) {
      account.isEnabled.value = true;
    }
  }
}
