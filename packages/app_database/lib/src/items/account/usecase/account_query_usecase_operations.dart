import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../domain/index.dart';
import '../repository/i_account_repository.dart';

mixin AccountQueryUsecaseOperations {
  IAccountRepository get accountRepository;

  Future<Either<Failure, List<AccountData>>> getAllAccounts({
    bool onlyActive = true,
  }) async {
    return accountRepository.getAllAccounts(onlyActive: onlyActive);
  }

  Future<Either<Failure, List<AccountData>>> getCheckingAccounts({
    bool onlyActive = true,
  }) async {
    return accountRepository.getAccountsByType(
      AccountType.checking,
      onlyActive: onlyActive,
    );
  }

  Future<Either<Failure, AccountData?>> getAccountById(int id) async {
    try {
      return await accountRepository.getAccountById(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error fetching account by id: $e'),
      );
    }
  }

  Future<Either<Failure, Map<AccountType, List<AccountData>>>>
  getGroupedAccounts({bool onlyActive = true}) async {
    try {
      final grouped = <AccountType, List<AccountData>>{};

      for (final type in AccountType.values) {
        final accountsResult = await accountRepository.getAccountsByType(
          type,
          onlyActive: onlyActive,
        );

        final accounts = accountsResult.fold(
          (failure) => null,
          (accounts) => accounts,
        );

        if (accounts == null) {
          return accountsResult.fold(
            Either.left,
            (_) => throw StateError('This should never happen'),
          );
        }

        if (accounts.isNotEmpty) {
          grouped[type] = accounts;
        }
      }

      return Either.right(grouped);
    } catch (e) {
      return Either.left(DatabaseFailure('Error grouping accounts: $e'));
    }
  }
}
