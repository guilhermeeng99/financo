import 'package:app_database/app_database.dart';

/// Mixin containing summary calculation operations for transaction usecase
mixin TransactionSummaryUsecaseOperations {
  ITransactionRepository get transactionRepository;

  Future<Either<Failure, TransactionSummary>> getTransactionSummary({
    required Set<int> accountIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await transactionRepository.getTransactionSummary(
      accountIds: accountIds,
      startDate: startDate,
      endDate: endDate,
    );

    return result.fold(
      Either.left,
      (summaryData) => Either.right(
        TransactionSummary(
          projectedTotalIncome: summaryData.projectedTotalIncome,
          projectedTotalExpense: summaryData.projectedTotalExpense,
          projectedTotalTransfers: summaryData.projectedTotalTransfers,
        ),
      ),
    );
  }
}
