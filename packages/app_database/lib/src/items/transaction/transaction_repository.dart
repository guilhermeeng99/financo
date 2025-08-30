import 'package:drift/drift.dart';

import '../../core/either.dart';
import '../../core/failures.dart';
import '../../core/financial_type.dart';
import '../../database/database_manager.dart';
import 'transaction_domain.dart';

abstract class ITransactionRepository {
  Future<Either<Failure, TransactionData>> createTransaction(
    TransactionsCompanion transaction,
  );

  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<TransactionData>>> getTransactionsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<TransactionData>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<TransactionData>>> getTransactionsByPaymentStatus(
    TransactionPaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, TransactionData>> updateTransaction(
    int id,
    TransactionsCompanion transaction,
  );

  Future<Either<Failure, bool>> deleteTransaction(int id);

  Future<Either<Failure, double>> getAccountBalanceById(int accountId);

  Future<Either<Failure, double>> getCategoryTotal(
    int categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

class TransactionRepository implements ITransactionRepository {
  TransactionRepository(this._database);

  final DatabaseManager _database;

  @override
  Future<Either<Failure, TransactionData>> createTransaction(
    TransactionsCompanion transaction,
  ) async {
    try {
      final result = await _database
          .into(_database.transactions)
          .insertReturning(transaction);
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error creating transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _database.select(_database.transactions)
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

  @override
  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _database.select(_database.transactions)
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

  @override
  Future<Either<Failure, List<TransactionData>>> getTransactionsByCategory(
    int categoryId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _database.select(_database.transactions)
        ..where((tbl) => tbl.categoryId.equals(categoryId))
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
        DatabaseFailure('Error getting transactions by category: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<TransactionData>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _database.select(_database.transactions)
        ..where((tbl) => tbl.competenceDate.isBetweenValues(startDate, endDate))
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
        DatabaseFailure('Error getting transactions by date range: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<TransactionData>>> getTransactionsByPaymentStatus(
    TransactionPaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _database.select(_database.transactions)
        ..where((tbl) => tbl.paymentStatus.equals(paymentStatus.value))
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
        DatabaseFailure('Error getting transactions by payment status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, TransactionData>> updateTransaction(
    int id,
    TransactionsCompanion transaction,
  ) async {
    try {
      // Atualizar o campo updatedAt
      final updatedTransaction = transaction.copyWith(
        updatedAt: Value(DateTime.now()),
      );

      final result = await (_database.update(
        _database.transactions,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(updatedTransaction);

      if (result.isEmpty) {
        return Either.left(const DatabaseFailure('Transaction not found'));
      }

      return Either.right(result.first);
    } catch (e) {
      return Either.left(DatabaseFailure('Error updating transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id) async {
    try {
      final result = await (_database.delete(
        _database.transactions,
      )..where((tbl) => tbl.id.equals(id))).go();
      return Either.right(result > 0);
    } catch (e) {
      return Either.left(DatabaseFailure('Error deleting transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getAccountBalanceById(int accountId) async {
    try {
      final incomeQuery = _database.selectOnly(_database.transactions)
        ..addColumns([_database.transactions.amount.sum()])
        ..where(
          _database.transactions.accountId.equals(accountId) &
              _database.transactions.paymentStatus.equals(
                TransactionPaymentStatus.paid.value,
              ) &
              _database.transactions.transactionType.equals(
                FinancialType.income.value,
              ),
        );

      final incomeResult = await incomeQuery.getSingle();
      final totalIncome =
          incomeResult.read(_database.transactions.amount.sum()) ?? 0.0;

      final expenseQuery = _database.selectOnly(_database.transactions)
        ..addColumns([_database.transactions.amount.sum()])
        ..where(
          _database.transactions.accountId.equals(accountId) &
              _database.transactions.paymentStatus.equals(
                TransactionPaymentStatus.paid.value,
              ) &
              _database.transactions.transactionType.equals(
                FinancialType.expense.value,
              ),
        );

      final expenseResult = await expenseQuery.getSingle();
      final totalExpense =
          expenseResult.read(_database.transactions.amount.sum()) ?? 0.0;

      final balance = totalIncome - totalExpense;
      return Either.right(balance);
    } catch (e) {
      return Either.left(DatabaseFailure('Error getting account balance: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getCategoryTotal(
    int categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _database.selectOnly(_database.transactions)
        ..addColumns([_database.transactions.amount.sum()])
        ..where(
          _database.transactions.categoryId.equals(categoryId) &
              _database.transactions.paymentStatus.equals(
                TransactionPaymentStatus.paid.value,
              ),
        );

      if (startDate != null && endDate != null) {
        query = query
          ..where(
            _database.transactions.competenceDate.isBetweenValues(
              startDate,
              endDate,
            ),
          );
      }

      final result = await query.getSingle();
      final total = result.read(_database.transactions.amount.sum()) ?? 0.0;
      return Either.right(total);
    } catch (e) {
      return Either.left(DatabaseFailure('Error getting category total: $e'));
    }
  }
}
