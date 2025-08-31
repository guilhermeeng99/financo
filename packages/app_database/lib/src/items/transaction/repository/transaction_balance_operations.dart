import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../../../database/database_manager.dart';

/// Mixin containing balance calculation operations for transactions
mixin TransactionBalanceOperations {
  DatabaseManager get database;

  Future<Either<Failure, double>> getAccountBalanceById(int accountId) async {
    try {
      // Get income total
      final incomeQuery = database.selectOnly(database.transactions)
        ..addColumns([database.transactions.amount.sum()])
        ..where(
          database.transactions.accountId.equals(accountId) &
              database.transactions.paymentStatus.equals(
                TransactionPaymentStatus.paid.value,
              ) &
              database.transactions.transactionType.equals(
                FinancialType.income.value,
              ),
        );

      final incomeResult = await incomeQuery.getSingle();
      final totalIncome =
          incomeResult.read(database.transactions.amount.sum()) ?? 0.0;

      // Get expense total
      final expenseQuery = database.selectOnly(database.transactions)
        ..addColumns([database.transactions.amount.sum()])
        ..where(
          database.transactions.accountId.equals(accountId) &
              database.transactions.paymentStatus.equals(
                TransactionPaymentStatus.paid.value,
              ) &
              database.transactions.transactionType.equals(
                FinancialType.expense.value,
              ),
        );

      final expenseResult = await expenseQuery.getSingle();
      final totalExpense =
          expenseResult.read(database.transactions.amount.sum()) ?? 0.0;

      return Either.right(totalIncome - totalExpense);
    } catch (e) {
      return Either.left(DatabaseFailure('Error getting account balance: $e'));
    }
  }

  Future<Either<Failure, double>> getAccountBalanceForPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get initial balance
      final accountQuery = database.select(database.accounts)
        ..where((tbl) => tbl.id.equals(accountId));

      final account = await accountQuery.getSingleOrNull();

      if (account == null) {
        return Either.left(const DatabaseFailure('Account not found'));
      }

      // Get only PAID transactions for the period
      final transactionsQuery = database.select(database.transactions)
        ..where(
          (tbl) =>
              tbl.accountId.equals(accountId) &
              tbl.actualDate.isBetweenValues(startDate, endDate) &
              tbl.paymentStatus.equals(TransactionPaymentStatus.paid.value),
        );

      final transactions = await transactionsQuery.get();

      final totalTransactions = transactions.fold<double>(
        0,
        (sum, transaction) => sum + transaction.amount,
      );

      return Either.right(account.initialBalance + totalTransactions);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error getting account balance for period: $e'),
      );
    }
  }

  Future<Either<Failure, Map<int, double>>> getMultipleAccountsBalanceForPeriod(
    Set<int> accountIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final balances = <int, double>{};

      // Get initial balances
      final accountsQuery = database.select(database.accounts)
        ..where((tbl) => tbl.id.isIn(accountIds));
      final accounts = await accountsQuery.get();

      for (final account in accounts) {
        balances[account.id] = account.initialBalance;
      }

      // Get only PAID transactions for the period
      final transactionsQuery = database.select(database.transactions)
        ..where(
          (tbl) =>
              tbl.accountId.isIn(accountIds) &
              tbl.actualDate.isBetweenValues(startDate, endDate) &
              tbl.paymentStatus.equals(TransactionPaymentStatus.paid.value),
        );

      final transactions = await transactionsQuery.get();

      // Sum transactions by account
      for (final transaction in transactions) {
        balances[transaction.accountId] =
            (balances[transaction.accountId] ?? 0) + transaction.amount;
      }

      return Either.right(balances);
    } catch (e) {
      return Either.left(
        DatabaseFailure(
          'Error getting multiple accounts balance for period: $e',
        ),
      );
    }
  }
}
