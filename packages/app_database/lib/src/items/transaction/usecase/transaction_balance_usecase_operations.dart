import 'package:app_database/app_database.dart';

/// Mixin containing balance operations for transaction usecase
mixin TransactionBalanceUsecaseOperations {
  ITransactionRepository get repository;

  Future<Either<Failure, double>> getAccountBalance(int accountId) async {
    return repository.getAccountBalanceById(accountId);
  }

  Future<Either<Failure, double>> getAccountBalanceForPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return repository.getAccountBalanceForPeriod(accountId, startDate, endDate);
  }

  Future<Either<Failure, Map<int, double>>> getMultipleAccountsBalanceForPeriod(
    Set<int> accountIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return repository.getMultipleAccountsBalanceForPeriod(
      accountIds,
      startDate,
      endDate,
    );
  }
}
