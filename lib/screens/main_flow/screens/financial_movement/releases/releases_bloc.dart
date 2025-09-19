import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';

ReleasesBloc get releasesBloc => Modular.get<ReleasesBloc>();

class ReleasesBloc extends GetxController {
  ReleasesBloc() {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Update transactions filter when accounts change
    ever(
      coreAccountsBloc.checkingAccounts,
      (_) => _updateTransactionsFilterBloc(),
    );
  }

  void _updateTransactionsFilterBloc() {
    transactionsFilterBloc.updateEnabledAccountIds(
      coreAccountsBloc.enabledAccountIds,
    );
  }

  // Delegated properties for backward compatibility
  RxList<TransactionsAccount> get checkingAccounts =>
      coreAccountsBloc.checkingAccounts;
  RxDouble get totalFilteredBalance => coreAccountsBloc.totalFilteredBalance;
  RxDouble get totalFilteredProjectedBalance =>
      coreAccountsBloc.totalFilteredProjectedBalance;

  // Transaction summary delegations
  RxDouble get projectedTotalIncome => coreAccountsBloc.projectedTotalIncome;
  RxDouble get projectedTotalExpense => coreAccountsBloc.projectedTotalExpense;
  RxDouble get projectedTotalTransfersIn =>
      coreAccountsBloc.projectedTotalTransfersIn;
  RxDouble get projectedTotalTransfersOut =>
      coreAccountsBloc.projectedTotalTransfersOut;
  RxDouble get projectedTotalResult => coreAccountsBloc.projectedTotalResult;

  // Delegated methods for backward compatibility
  Future<void> loadCheckingAccounts() =>
      coreAccountsBloc.loadCheckingAccounts();
  Future<void> updateFilteredBalances() =>
      coreAccountsBloc.updateFilteredBalances();

  double get totalEnabledAccountsBalance =>
      coreAccountsBloc.totalEnabledAccountsBalance;
  Set<int> get enabledAccountIds => coreAccountsBloc.enabledAccountIds;

  List<TransactionI> get filteredTransactions =>
      transactionsFilterBloc.getFilteredTransactions(enabledAccountIds);

  Future<double> getTotalEnabledAccountsBalanceForDate(DateTime selectedDate) =>
      coreAccountsBloc.getTotalEnabledAccountsBalanceForDate(selectedDate);

  Future<double> getAccountBalanceForDate(
    int accountId,
    DateTime selectedDate,
  ) => coreAccountsBloc.getAccountBalanceForDate(accountId, selectedDate);
}
