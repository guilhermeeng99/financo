import 'package:app_database/app_database.dart';

/// Mixin containing balance operations for transaction usecase
mixin TransactionBalanceUsecaseOperations {
  ITransactionRepository get transactionRepository;

  Future<Either<Failure, double>> getAccountBalance(int accountId) async {
    return transactionRepository.getAccountBalanceById(accountId);
  }

  Future<Either<Failure, double>> getAccountBalanceForPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return transactionRepository.getAccountBalanceForPeriod(
      accountId,
      startDate,
      endDate,
    );
  }

  Future<Either<Failure, Map<int, double>>> getMultipleAccountsBalanceForPeriod(
    Set<int> accountIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return transactionRepository.getMultipleAccountsBalanceForPeriod(
      accountIds,
      startDate,
      endDate,
    );
  }
}
