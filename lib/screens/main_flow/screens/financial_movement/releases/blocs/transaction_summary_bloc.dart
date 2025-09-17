import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/blocs/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/services/transaction_summary_service.dart';

TransactionSummaryBloc get transactionSummaryBloc =>
    Modular.get<TransactionSummaryBloc>();

class TransactionSummaryBloc extends GetxController {
  TransactionSummaryBloc() {
    _initializeListeners();
  }

  final RxDouble projectedTotalIncome = 0.0.obs;
  final RxDouble projectedTotalExpense = 0.0.obs;
  final RxDouble projectedTotalTransfers = 0.0.obs;

  void _initializeListeners() {
    ever(calendarFilterBloc.selected, (_) => _calculateTransactionSummary());
    ever(accountsBloc.checkingAccounts, (_) => _calculateTransactionSummary());
  }

  Future<void> _calculateTransactionSummary() async {
    final accountIds = accountsBloc.enabledAccountIds;

    if (accountIds.isEmpty) {
      _resetTransactionSummary();
      return;
    }

    try {
      final summary =
          await TransactionSummaryService.calculateTransactionSummary(
            accountIds: accountIds,
            startDate: calendarFilterBloc.startOfPeriod,
            endDate: calendarFilterBloc.endOfPeriod,
          );

      if (summary != null) {
        _updateTransactionSummary(summary);
      } else {
        _resetTransactionSummary();
      }
    } catch (e) {
      logger.e('❌ Unexpected error calculating transaction summary: $e');
      _resetTransactionSummary();
    }
  }

  void _resetTransactionSummary() {
    projectedTotalIncome.value = 0.0;
    projectedTotalExpense.value = 0.0;
    projectedTotalTransfers.value = 0.0;
  }

  void _updateTransactionSummary(TransactionSummary summary) {
    projectedTotalIncome.value = summary.projectedTotalIncome;
    projectedTotalExpense.value = summary.projectedTotalExpense;
    projectedTotalTransfers.value = summary.projectedTotalTransfers;
  }

  double get projectedTotalResult =>
      projectedTotalIncome.value - projectedTotalExpense.value;

  TransactionSummary get currentSummary => TransactionSummary(
    projectedTotalIncome: projectedTotalIncome.value,
    projectedTotalExpense: projectedTotalExpense.value,
    projectedTotalTransfers: projectedTotalTransfers.value,
  );

  @override
  void onClose() {
    projectedTotalIncome.close();
    projectedTotalExpense.close();
    projectedTotalTransfers.close();
    super.onClose();
  }
}
