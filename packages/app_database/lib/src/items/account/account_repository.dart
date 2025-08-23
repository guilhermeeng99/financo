import '../../core/either.dart';
import '../../core/failures.dart';
import '../../database/database_manager.dart';
import 'account_domain.dart';

abstract class IAccountRepository {
  Future<Either<Failure, AccountData>> createAccount(AccountsCompanion account);
  Future<Either<Failure, List<AccountData>>> getAllAccounts();
  Future<Either<Failure, List<AccountData>>> getAccountsByType(
    AccountType type,
  );
  Future<Either<Failure, AccountData?>> getAccountById(int id);
  Future<Either<Failure, AccountData>> updateAccount(
    int id,
    AccountsCompanion account,
  );
  Future<Either<Failure, bool>> deleteAccount(int id);
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

  @override
  Future<Either<Failure, List<AccountData>>> getAccountsByType(
    AccountType type,
  ) async {
    try {
      final result = await (_database.select(
        _database.accounts,
      )..where((tbl) => tbl.accountType.equals(type.value))).get();
      return Either.right(result);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error fetching accounts by type: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AccountData?>> getAccountById(int id) async {
    try {
      final result = await (_database.select(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching account by id: $e'));
    }
  }

  @override
  Future<Either<Failure, AccountData>> updateAccount(
    int id,
    AccountsCompanion account,
  ) async {
    try {
      final updated = await (_database.update(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(account);

      if (updated.isEmpty) {
        return Either.left(DatabaseFailure('Account with id $id not found'));
      }

      return Either.right(updated.first);
    } catch (e) {
      return Either.left(DatabaseFailure('Error updating account: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccount(int id) async {
    try {
      final rowsAffected = await (_database.delete(
        _database.accounts,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (rowsAffected == 0) {
        return Either.left(DatabaseFailure('Account with id $id not found'));
      }

      return Either.right(true);
    } catch (e) {
      return Either.left(DatabaseFailure('Error deleting account: $e'));
    }
  }
}
