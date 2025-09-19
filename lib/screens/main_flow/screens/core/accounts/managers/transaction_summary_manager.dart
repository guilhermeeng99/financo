import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/services/transaction_summary_service.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';

class TransactionSummaryManager {
  final RxDouble _projectedTotalIncome = 0.0.obs;
  final RxDouble _projectedTotalExpense = 0.0.obs;
  final RxDouble _projectedTotalTransfersIn = 0.0.obs;
  final RxDouble _projectedTotalTransfersOut = 0.0.obs;

  // Getters
  RxDouble get projectedTotalIncome => _projectedTotalIncome;
  RxDouble get projectedTotalExpense => _projectedTotalExpense;
  RxDouble get projectedTotalTransfersIn => _projectedTotalTransfersIn;
  RxDouble get projectedTotalTransfersOut => _projectedTotalTransfersOut;

  RxDouble get projectedTotalResult {
    final result = _projectedTotalIncome.value - _projectedTotalExpense.value;
    return result.obs;
  }

  Future<void> updateTransactionSummary({
    required Set<int> accountIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (accountIds.isEmpty) {
      resetTransactionSummary();
      return;
    }

    final finalStartDate = startDate ?? coreCalendarBloc.startOfPeriod;
    final finalEndDate = endDate ?? coreCalendarBloc.endOfPeriod;

    final summary = await TransactionSummaryService.calculateTransactionSummary(
      accountIds: accountIds,
      startDate: finalStartDate,
      endDate: finalEndDate,
    );

    _updateSummaryValues(summary);
  }

  void resetTransactionSummary() {
    _projectedTotalIncome.value = 0.0;
    _projectedTotalExpense.value = 0.0;
    _projectedTotalTransfersIn.value = 0.0;
    _projectedTotalTransfersOut.value = 0.0;
  }

  void _updateSummaryValues(TransactionSummary? summary) {
    if (summary != null) {
      _projectedTotalIncome.value = summary.projectedTotalIncome;
      _projectedTotalExpense.value = summary.projectedTotalExpense;
      _projectedTotalTransfersIn.value = summary.projectedTotalTransfersIn;
      _projectedTotalTransfersOut.value = summary.projectedTotalTransfersOut;
    } else {
      resetTransactionSummary();
    }
  }
}
