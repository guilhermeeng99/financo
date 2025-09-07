import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';
import '../domain/account_enums.dart';
import '../domain/account_table.dart';

mixin AccountQueryOperations {
  DatabaseManager get database;

  Future<Either<Failure, AccountData?>> getAccountById(int id) async {
    try {
      final query = database.select(database.accounts)
        ..where((tbl) => tbl.id.equals(id));

      final result = await query.getSingleOrNull();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching account by id: $e'));
    }
  }

  Future<Either<Failure, List<AccountData>>> getAllAccounts({
    bool onlyActive = true,
  }) async {
    try {
      var query = database.select(database.accounts);

      if (onlyActive) {
        query = query..where((tbl) => tbl.isActive.equals(true));
      }

      query = query..orderBy([(t) => OrderingTerm(expression: t.name)]);

      final result = await query.get();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching all accounts: $e'));
    }
  }

  Future<Either<Failure, List<AccountData>>> getAccountsByType(
    AccountType type, {
    bool onlyActive = true,
  }) async {
    try {
      var query = database.select(database.accounts)
        ..where((tbl) => tbl.accountType.equals(type.value));

      if (onlyActive) {
        query = query..where((tbl) => tbl.isActive.equals(true));
      }

      query = query..orderBy([(t) => OrderingTerm(expression: t.name)]);

      final result = await query.get();
      return Either.right(result);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error fetching accounts by type: $e'),
      );
    }
  }

  Future<Either<Failure, AccountData?>> getAccountByName(String name) async {
    try {
      final query = database.select(database.accounts)
        ..where((tbl) => tbl.name.equals(name.trim()));

      final result = await query.getSingleOrNull();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching account by name: $e'));
    }
  }
}
