import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../transaction/repository/i_transaction_repository.dart';
import 'account_query_usecase_operations.dart';

mixin AccountBalanceUsecaseOperations on AccountQueryUsecaseOperations {
  ITransactionRepository get transactionRepository;

  Future<Either<Failure, double>> getAccountFinalBalance(int accountId) async {
    try {
      final accountResult = await getAccountById(accountId);

      return accountResult.fold(Either.left, (account) async {
        if (account == null) {
          return Either.left(const DatabaseFailure('Account not found'));
        }

        final transactionBalanceResult = await transactionRepository
            .getAccountBalanceById(accountId);

        return transactionBalanceResult.fold(Either.left, (
          double transactionBalance,
        ) {
          final finalBalance = account.initialBalance + transactionBalance;
          return Either.right(finalBalance);
        });
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error calculating account final balance: $e'),
      );
    }
  }
}
