import 'package:app_database/app_database.dart';

/// Mixin containing query operations for transaction usecase
mixin TransactionQueryUsecaseOperations {
  ITransactionRepository get transactionRepository;

  Future<Either<Failure, List<TransactionI>>> getTransactionsWithDetails({
    Set<int>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return transactionRepository.getTransactionsWithDetails(
      accountIds: accountIds,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }
}
