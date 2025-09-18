import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

class TransactionSummaryService {
  static Future<TransactionSummary?> calculateTransactionSummary({
    required Set<int> accountIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (accountIds.isEmpty) return null;

    try {
      final transactionUsecase = Modular.get<ITransactionUsecase>();
      final result = await transactionUsecase.getTransactionSummary(
        accountIds: accountIds,
        startDate: startDate,
        endDate: endDate,
      );

      return result.fold((Failure failure) {
        logger.e('Error calculating transaction summary: ${failure.message}');
        return null;
      }, (TransactionSummary summary) => summary);
    } catch (e) {
      logger.e('❌ Unexpected error calculating transaction summary: $e');
      return null;
    }
  }

  static TransactionSummary getEmptySummary() {
    return const TransactionSummary(
      projectedTotalIncome: 0,
      projectedTotalExpense: 0,
      projectedTotalTransfersIn: 0,
      projectedTotalTransfersOut: 0,
    );
  }

  static double calculateProjectedResult(TransactionSummary summary) {
    return summary.projectedTotalIncome - summary.projectedTotalExpense;
  }
}
