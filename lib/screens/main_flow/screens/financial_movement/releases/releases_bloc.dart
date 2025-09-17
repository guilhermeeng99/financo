import 'dart:async';

import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/blocs/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/blocs/balance_calculation_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/blocs/transaction_summary_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_account.dart';

ReleasesBloc get releasesBloc => Modular.get<ReleasesBloc>();

class ReleasesBloc extends GetxController {
  ReleasesBloc() {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Update transactions filter when accounts change
    ever(accountsBloc.checkingAccounts, (_) => _updateTransactionsFilterBloc());
  }

  void _updateTransactionsFilterBloc() {
    transactionsFilterBloc.updateEnabledAccountIds(
      accountsBloc.enabledAccountIds,
    );
  }

  // Delegated properties for backward compatibility
  RxList<TransactionsAccount> get checkingAccounts =>
      accountsBloc.checkingAccounts;
  RxDouble get totalFilteredBalance =>
      balanceCalculationBloc.totalFilteredBalance;
  RxDouble get totalFilteredProjectedBalance =>
      balanceCalculationBloc.totalFilteredProjectedBalance;
  RxDouble get projectedTotalIncome =>
      transactionSummaryBloc.projectedTotalIncome;
  RxDouble get projectedTotalExpense =>
      transactionSummaryBloc.projectedTotalExpense;
  RxDouble get projectedTotalTransfers =>
      transactionSummaryBloc.projectedTotalTransfers;

  // Delegated methods for backward compatibility
  Future<void> loadCheckingAccounts() => accountsBloc.loadCheckingAccounts();
  Future<void> updateFilteredBalances() =>
      balanceCalculationBloc.updateFilteredBalances();

  double get totalEnabledAccountsBalance =>
      accountsBloc.totalEnabledAccountsBalance;
  Set<int> get enabledAccountIds => accountsBloc.enabledAccountIds;
  double get projectedTotalResult =>
      transactionSummaryBloc.projectedTotalResult;

  Future<double> getTotalEnabledAccountsBalanceForDate(DateTime selectedDate) =>
      accountsBloc.getTotalEnabledAccountsBalanceForDate(selectedDate);

  Future<double> getAccountBalanceForDate(
    int accountId,
    DateTime selectedDate,
  ) => accountsBloc.getAccountBalanceForDate(accountId, selectedDate);
}
