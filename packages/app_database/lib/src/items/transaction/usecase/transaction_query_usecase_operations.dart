import 'package:app_database/app_database.dart';

/// Mixin containing query operations for transaction usecase
mixin TransactionQueryUsecaseOperations {
  ITransactionRepository get transactionRepository;

  Future<Either<Failure, List<DataTransaction>>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    try {
      return await transactionRepository.getAllTransactions(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error getting transactions: $e'),
      );
    }
  }

  Future<Either<Failure, List<DataTransaction>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  }) async {
    try {
      return await transactionRepository.getTransactionsByAccount(
        accountId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error getting transactions by account: $e'),
      );
    }
  }

  Future<Either<Failure, DataTransaction?>> getTransactionById(int id) async {
    try {
      return await transactionRepository.getTransactionById(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error getting transaction by id: $e'),
      );
    }
  }

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
