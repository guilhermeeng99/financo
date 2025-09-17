import 'dart:async';

import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/blocs/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/services/account_balance_service.dart';

BalanceCalculationBloc get balanceCalculationBloc =>
    Modular.get<BalanceCalculationBloc>();

class BalanceCalculationBloc extends GetxController {
  BalanceCalculationBloc() {
    _initializeListeners();
  }

  final RxDouble totalFilteredBalance = 0.0.obs;
  final RxDouble totalFilteredProjectedBalance = 0.0.obs;

  void _initializeListeners() {
    ever(calendarFilterBloc.selected, (_) => updateFilteredBalances());
    ever(accountsBloc.checkingAccounts, (_) => updateFilteredBalances());
    ever(
      accountsBloc.checkingAccounts,
      (_) => _updateTotalFromFilteredBalances(),
    );
  }

  Future<void> updateFilteredBalances() async {
    if (accountsBloc.checkingAccounts.isEmpty) return;

    try {
      final endOfPeriod = calendarFilterBloc.endOfPeriod;
      final accountIds = accountsBloc.checkingAccounts
          .map((account) => account.account.id)
          .toSet();

      final balances = await AccountBalanceService.getFilteredBalances(
        accountIds,
        endOfPeriod,
      );
      final projectedBalances = await AccountBalanceService.getFilteredBalances(
        accountIds,
        endOfPeriod,
        onlyPaid: false,
      );

      _updateAccountBalances(balances, projectedBalances);
      _updateTotalFromFilteredBalances();
    } catch (e) {
      logger.e('❌ Unexpected error updating filtered balances: $e');
      _showErrorMessage('Failed to update balances');
    }
  }

  void _updateAccountBalances(
    Map<int, double> balances,
    Map<int, double> projectedBalances,
  ) {
    for (final account in accountsBloc.checkingAccounts) {
      final filteredBalance =
          balances[account.account.id] ?? account.account.initialBalance;
      final filteredProjectedBalance =
          projectedBalances[account.account.id] ??
          account.account.initialBalance;

      account.updateFilteredBalances(
        newFilteredBalance: filteredBalance,
        newFilteredProjectedBalance: filteredProjectedBalance,
      );
    }
  }

  void _updateTotalFromFilteredBalances() {
    double total = 0;
    double totalProjected = 0;
    for (final account in accountsBloc.checkingAccounts) {
      if (account.isEnabled.value) {
        total += account.filteredBalance.value;
        totalProjected += account.filteredProjectedBalance.value;
      }
    }
    totalFilteredBalance.value = total;
    totalFilteredProjectedBalance.value = totalProjected;
  }

  void _showErrorMessage(String message) {
    CWSnackBar.snackBar(title: message, type: SnackBarType.error);
  }

  @override
  void onClose() {
    totalFilteredBalance.close();
    totalFilteredProjectedBalance.close();
    super.onClose();
  }
}
