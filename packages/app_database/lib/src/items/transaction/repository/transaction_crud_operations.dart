import 'package:app_database/src/core/financial_type.dart';
import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';

mixin TransactionCrudOperations {
  DatabaseManager get database;

  Future<Either<Failure, StandardTransaction>> createStandardTransaction(
    TransactionsCompanion transaction,
  ) async {
    try {
      final result = await database
          .into(database.transactions)
          .insertReturning(transaction);
      return Either.right(StandardTransaction.fromDataTransaction(result));
    } catch (e) {
      return Either.left(DatabaseFailure('Error creating transaction: $e'));
    }
  }

  Future<Either<Failure, StandardTransaction>> updateStandardTransaction(
    int id,
    TransactionsCompanion transaction,
  ) async {
    try {
      // Validate it's a standard transaction before updating
      final currentTransaction = await (database.select(
        database.transactions,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (currentTransaction == null) {
        return Either.left(const ValidationFailure('Transaction not found'));
      }

      if (currentTransaction.categoryId == null ||
          currentTransaction.targetAccountId != null ||
          currentTransaction.transferId != null) {
        return Either.left(
          const ValidationFailure('Transaction is not a standard transaction'),
        );
      }

      final result = await (database.update(
        database.transactions,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(transaction);

      if (result.isEmpty) {
        return Either.left(
          const ValidationFailure('Failed to update transaction'),
        );
      }

      return Either.right(
        StandardTransaction.fromDataTransaction(result.first),
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error updating standard transaction: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteStandardTransaction(int id) async {
    try {
      // Validate it's a standard transaction before deleting
      final currentTransaction = await (database.select(
        database.transactions,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (currentTransaction == null) {
        return Either.left(const ValidationFailure('Transaction not found'));
      }

      if (currentTransaction.categoryId == null ||
          currentTransaction.targetAccountId != null ||
          currentTransaction.transferId != null) {
        return Either.left(
          const ValidationFailure('Transaction is not a standard transaction'),
        );
      }

      final result = await (database.delete(
        database.transactions,
      )..where((tbl) => tbl.id.equals(id))).go();

      return Either.right(result > 0);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error deleting standard transaction: $e'),
      );
    }
  }

  Future<Either<Failure, List<DataTransaction>>> getAllTransactions({
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

  Future<Either<Failure, List<DataTransaction>>> getTransactionsByAccount(
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

  Future<Either<Failure, DataTransaction?>> getTransactionById(int id) async {
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

  Future<Either<Failure, List<TransferTransaction>>>
  createTransferBetweenAccounts({
    required int sourceAccountId,
    required int targetAccountId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    if (sourceAccountId == targetAccountId) {
      return Either.left(
        const ValidationFailure('Source and target accounts must differ'),
      );
    }
    if (amount <= 0) {
      return Either.left(
        const ValidationFailure('Amount must be greater than zero'),
      );
    }

    try {
      final transferId = 'trf_${DateTime.now().microsecondsSinceEpoch}';
      final competenceDate = date;

      return await database.transaction(() async {
        final sourceCompanion = TransactionsCompanion(
          transactionType: const Value(FinancialType.expense),
          actualDate: Value(date),
          competenceDate: Value(competenceDate),
          amount: Value(-amount.abs()),
          description: Value(description),
          paymentStatus: const Value(TransactionPaymentStatus.paid),
          recurrenceType: const Value(TransactionRecurrenceType.unique),
          accountId: Value(sourceAccountId),
          targetAccountId: Value(targetAccountId),
          transferId: Value(transferId),
        );

        final targetCompanion = TransactionsCompanion(
          transactionType: const Value(FinancialType.income),
          actualDate: Value(date),
          competenceDate: Value(competenceDate),
          amount: Value(amount.abs()),
          description: Value(description),
          paymentStatus: const Value(TransactionPaymentStatus.paid),
          recurrenceType: const Value(TransactionRecurrenceType.unique),
          accountId: Value(targetAccountId),
          targetAccountId: Value(targetAccountId),
          transferId: Value(transferId),
        );

        final sourceTx = await database
            .into(database.transactions)
            .insertReturning(sourceCompanion);
        final targetTx = await database
            .into(database.transactions)
            .insertReturning(targetCompanion);

        final transferTransactions = [
          sourceTx,
          targetTx,
        ].map(TransferTransaction.fromDataTransaction).toList();

        return Either.right(transferTransactions);
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error creating transfer between accounts: $e'),
      );
    }
  }

  Future<Either<Failure, List<TransferTransaction>>> updateTransferTransaction({
    required String transferId,
    DateTime? actualDate,
    DateTime? competenceDate,
    double? amount,
    String? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  }) async {
    try {
      return await database.transaction(() async {
        // Get both transactions of the transfer
        final transferTransactions = await (database.select(
          database.transactions,
        )..where((tbl) => tbl.transferId.equals(transferId))).get();

        if (transferTransactions.isEmpty) {
          return Either.left(const ValidationFailure('Transfer not found'));
        }

        if (transferTransactions.length != 2) {
          return Either.left(
            const ValidationFailure(
              'Invalid transfer: should have exactly 2 transactions',
            ),
          );
        }

        final updatedTransactions = <DataTransaction>[];

        for (final transaction in transferTransactions) {
          final companion = TransactionsCompanion(
            actualDate: actualDate != null
                ? Value(actualDate)
                : const Value.absent(),
            competenceDate: competenceDate != null
                ? Value(competenceDate)
                : const Value.absent(),
            amount: amount != null
                ? Value(
                    transaction.transactionType == FinancialType.expense
                        ? -amount.abs()
                        : amount.abs(),
                  )
                : const Value.absent(),
            description: description != null
                ? Value(description)
                : const Value.absent(),
            paymentStatus: paymentStatus != null
                ? Value(paymentStatus)
                : const Value.absent(),
            recurrenceType: recurrenceType != null
                ? Value(recurrenceType)
                : const Value.absent(),
            recurrenceFrequency: recurrenceFrequency != null
                ? Value(recurrenceFrequency)
                : const Value.absent(),
          );

          final updated =
              await (database.update(database.transactions)
                    ..where((tbl) => tbl.id.equals(transaction.id)))
                  .writeReturning(companion);

          if (updated.isNotEmpty) {
            updatedTransactions.add(updated.first);
          }
        }

        final transferTransactionsList = updatedTransactions
            .map(TransferTransaction.fromDataTransaction)
            .toList();

        return Either.right(transferTransactionsList);
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error updating transfer transaction: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteTransferTransaction(
    String transferId,
  ) async {
    try {
      return await database.transaction(() async {
        // Get both transactions of the transfer
        final transferTransactions = await (database.select(
          database.transactions,
        )..where((tbl) => tbl.transferId.equals(transferId))).get();

        if (transferTransactions.isEmpty) {
          return Either.left(const ValidationFailure('Transfer not found'));
        }

        // Delete both transactions
        final deletedCount = await (database.delete(
          database.transactions,
        )..where((tbl) => tbl.transferId.equals(transferId))).go();

        return Either.right(deletedCount == transferTransactions.length);
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error deleting transfer transaction: $e'),
      );
    }
  }
}
