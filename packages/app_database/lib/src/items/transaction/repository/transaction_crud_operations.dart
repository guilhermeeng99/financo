import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';

/// Mixin containing basic CRUD operations for transactions
mixin TransactionCrudOperations {
  DatabaseManager get database;

  Future<Either<Failure, TransactionData>> createTransaction(
    TransactionsCompanion transaction,
  ) async {
    try {
      final result = await database
          .into(database.transactions)
          .insertReturning(transaction);
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error creating transaction: $e'));
    }
  }

  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    try {
      var query = database.select(database.transactions)
        ..orderBy([
          (tbl) => OrderingTerm(
            expression: tbl.competenceDate,
            mode: OrderingMode.desc,
          ),
          (tbl) =>
              OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
        ]);

      if (limit != null) {
        query = query..limit(limit, offset: offset);
      }

      final result = await query.get();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error getting transactions: $e'));
    }
  }

  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = database.select(database.transactions)
        ..where((tbl) => tbl.accountId.equals(accountId))
        ..orderBy([
          (tbl) => OrderingTerm(
            expression: tbl.competenceDate,
            mode: OrderingMode.desc,
          ),
          (tbl) =>
              OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
        ]);

      if (limit != null) {
        query = query..limit(limit, offset: offset);
      }

      final result = await query.get();
      return Either.right(result);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error getting transactions by account: $e'),
      );
    }
  }

  Future<Either<Failure, TransactionData?>> getTransactionById(int id) async {
    try {
      final result = await (database.select(
        database.transactions,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      return Either.right(result);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error getting transaction by id: $e'),
      );
    }
  }

  Future<Either<Failure, TransactionData>> updateTransaction(
    int id,
    TransactionsCompanion transaction,
  ) async {
    try {
      final updatedTransaction = transaction.copyWith(
        updatedAt: Value(DateTime.now()),
      );

      final result = await (database.update(
        database.transactions,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(updatedTransaction);

      if (result.isEmpty) {
        return Either.left(const DatabaseFailure('Transaction not found'));
      }

      return Either.right(result.first);
    } catch (e) {
      return Either.left(DatabaseFailure('Error updating transaction: $e'));
    }
  }

  Future<Either<Failure, bool>> deleteTransaction(int id) async {
    try {
      final result = await (database.delete(
        database.transactions,
      )..where((tbl) => tbl.id.equals(id))).go();
      return Either.right(result > 0);
    } catch (e) {
      return Either.left(DatabaseFailure('Error deleting transaction: $e'));
    }
  }
}
