import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../../../database/database_manager.dart';
import 'i_transaction_repository.dart';

/// Mixin containing balance calculation operations for transactions
mixin TransactionBalanceOperations {
  DatabaseManager get database;

  Future<Either<Failure, double>> getAccountBalanceById(int accountId) async {
    try {
      final totalQuery = database.selectOnly(database.transactions)
        ..addColumns([database.transactions.amount.sum()])
        ..where(
          database.transactions.accountId.equals(accountId) &
              database.transactions.paymentStatus.equals(
                TransactionPaymentStatus.paid.value,
              ),
        );

      final totalResult = await totalQuery.getSingle();
      final totalAmount =
          totalResult.read(database.transactions.amount.sum()) ?? 0.0;

      return Either.right(totalAmount);
    } catch (e) {
      return Either.left(DatabaseFailure('Error getting account balance: $e'));
    }
  }

  Future<Either<Failure, double>> getAccountBalanceForPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate, {
    bool onlyPaidTransactions = true,
  }) async {
    try {
      final accountQuery = database.select(database.accounts)
        ..where((tbl) => tbl.id.equals(accountId));

      final account = await accountQuery.getSingleOrNull();

      if (account == null) {
        return Either.left(const DatabaseFailure('Account not found'));
      }

      var transactionsQuery = database.select(database.transactions)
        ..where(
          (tbl) =>
              tbl.accountId.equals(accountId) &
              tbl.actualDate.isBetweenValues(startDate, endDate),
        );

      if (onlyPaidTransactions) {
        transactionsQuery = database.select(database.transactions)
          ..where(
            (tbl) =>
                tbl.accountId.equals(accountId) &
                tbl.actualDate.isBetweenValues(startDate, endDate) &
                tbl.paymentStatus.equals(TransactionPaymentStatus.paid.value),
          );
      }

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
    DateTime endDate, {
    bool onlyPaidTransactions = true,
  }) async {
    try {
      final balances = <int, double>{};

      // Get initial balances
      final accountsQuery = database.select(database.accounts)
        ..where((tbl) => tbl.id.isIn(accountIds));
      final accounts = await accountsQuery.get();

      for (final account in accounts) {
        balances[account.id] = account.initialBalance;
      }

      // Build query based on whether to include only paid transactions or all
      var transactionsQuery = database.select(database.transactions)
        ..where(
          (tbl) =>
              tbl.accountId.isIn(accountIds) &
              tbl.actualDate.isBetweenValues(startDate, endDate),
        );

      // Add payment status filter if only paid transactions should be included
      if (onlyPaidTransactions) {
        transactionsQuery = database.select(database.transactions)
          ..where(
            (tbl) =>
                tbl.accountId.isIn(accountIds) &
                tbl.actualDate.isBetweenValues(startDate, endDate) &
                tbl.paymentStatus.equals(TransactionPaymentStatus.paid.value),
          );
      }

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

  Future<Either<Failure, TransactionSummaryData>> getTransactionSummary({
    required Set<int> accountIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactionsQuery = database.select(database.transactions)
        ..where(
          (tbl) =>
              tbl.accountId.isIn(accountIds) &
              tbl.actualDate.isBetweenValues(startDate, endDate),
        );

      final transactions = await transactionsQuery.get();

      var projectedIncomeTotal = 0.0;
      var projectedExpenseTotal = 0.0;
      var projectedTransferTotal = 0.0;

      final projectedTransferIds = <String>{};

      for (final transaction in transactions) {
        final amount = transaction.amount.abs();
        final isTransfer = transaction.transferId != null;

        if (isTransfer) {
          final transferId = transaction.transferId!;

          if (!projectedTransferIds.contains(transferId)) {
            projectedTransferTotal += amount;
            projectedTransferIds.add(transferId);
          }
        } else if (transaction.transactionType == FinancialType.income) {
          projectedIncomeTotal += amount;
        } else if (transaction.transactionType == FinancialType.expense) {
          projectedExpenseTotal += amount;
        }
      }

      return Either.right(
        TransactionSummaryData(
          projectedTotalIncome: projectedIncomeTotal,
          projectedTotalExpense: projectedExpenseTotal,
          projectedTotalTransfers: projectedTransferTotal,
        ),
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error calculating transaction summary: $e'),
      );
    }
  }
}
