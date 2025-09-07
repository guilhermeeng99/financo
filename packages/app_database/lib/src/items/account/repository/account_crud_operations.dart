import 'package:sqlite3/sqlite3.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';
import '../domain/account_table.dart';
import 'account_query_operations.dart';

mixin AccountCrudOperations on AccountQueryOperations {
  @override
  DatabaseManager get database;

  Future<Either<Failure, AccountData>> createAccount(
    AccountsCompanion account,
  ) async {
    if (account.name.present) {
      final duplicateFailure = await _checkForDuplicateName(account.name.value);
      if (duplicateFailure != null) return duplicateFailure;
    }

    try {
      final result = await database
          .into(database.accounts)
          .insertReturning(account);
      return Either.right(result);
    } on SqliteException catch (e) {
      return Either.left(_handleSqliteException(e));
    } catch (e) {
      return Either.left(_handleGenericException(e, 'creating'));
    }
  }

  Future<Either<Failure, AccountData>> updateAccount(
    int id,
    AccountsCompanion account,
  ) async {
    if (account.name.present) {
      final duplicateFailure = await _checkForDuplicateNameOnUpdate(
        account.name.value,
        id,
      );
      if (duplicateFailure != null) return duplicateFailure;
    }

    try {
      final updated = await (database.update(
        database.accounts,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(account);

      if (updated.isEmpty) {
        return Either.left(DatabaseFailure('Account with id $id not found'));
      }

      return Either.right(updated.first);
    } on SqliteException catch (e) {
      return Either.left(_handleSqliteException(e));
    } catch (e) {
      return Either.left(_handleGenericException(e, 'updating'));
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

  Future<Either<Failure, AccountData>?> _checkForDuplicateName(
    String name,
  ) async {
    final existingCheck = await getAccountByName(name);
    return existingCheck.fold(
      (failure) => null,
      (accountData) => accountData != null
          ? Either.left(
              const DuplicateEntryFailure('Account name already exists'),
            )
          : null,
    );
  }

  Future<Either<Failure, AccountData>?> _checkForDuplicateNameOnUpdate(
    String name,
    int excludeId,
  ) async {
    final existingCheck = await getAccountByName(name);
    return existingCheck.fold(
      (failure) => null,
      (accountData) => accountData != null && accountData.id != excludeId
          ? Either.left(
              const DuplicateEntryFailure('Account name already exists'),
            )
          : null,
    );
  }

  Failure _handleSqliteException(SqliteException e) {
    if (e.extendedResultCode == 2067 ||
        e.message.toLowerCase().contains('unique')) {
      return const DuplicateEntryFailure('Account name already exists');
    }
    return DatabaseFailure('SQLite error: ${e.message}');
  }

  Failure _handleGenericException(Object e, String operation) {
    final errorMessage = e.toString().toLowerCase();
    if (errorMessage.contains('unique') ||
        errorMessage.contains('constraint') ||
        errorMessage.contains('duplicate')) {
      return const DuplicateEntryFailure('Account name already exists');
    }
    return DatabaseFailure('Error $operation account: $e');
  }
}
