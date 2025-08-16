import '../core/either.dart';
import '../core/failures.dart';
import '../database/database_manager.dart';
import '../domains/account_domain.dart';

abstract class IAccountRepository {
  Future<Either<Failure, AccountData>> createAccount(AccountsCompanion account);
  Future<Either<Failure, List<AccountData>>> getAllAccounts();
}

class AccountRepository implements IAccountRepository {
  AccountRepository(this._database);

  final DatabaseManager _database;

  @override
  Future<Either<Failure, AccountData>> createAccount(
    AccountsCompanion account,
  ) async {
    try {
      final result = await _database
          .into(_database.accounts)
          .insertReturning(account);
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error creating account: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AccountData>>> getAllAccounts() async {
    try {
      final result = await _database.select(_database.accounts).get();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching accounts: $e'));
    }
  }
}
