import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';
import '../domain/account_table.dart';

mixin AccountCrudOperations {
  DatabaseManager get database;

  Future<Either<Failure, AccountData>> createAccount(
    AccountsCompanion account,
  ) async {
    try {
      final result = await database
          .into(database.accounts)
          .insertReturning(account);
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error creating account: $e'));
    }
  }

  Future<Either<Failure, AccountData>> updateAccount(
    int id,
    AccountsCompanion account,
  ) async {
    try {
      final updated = await (database.update(
        database.accounts,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(account);

      if (updated.isEmpty) {
        return Either.left(DatabaseFailure('Account with id $id not found'));
      }

      return Either.right(updated.first);
    } catch (e) {
      return Either.left(DatabaseFailure('Error updating account: $e'));
    }
  }

  Future<Either<Failure, bool>> deleteAccount(int id) async {
    try {
      final rowsAffected = await (database.delete(
        database.accounts,
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
