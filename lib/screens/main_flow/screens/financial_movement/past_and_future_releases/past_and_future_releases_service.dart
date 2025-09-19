import 'package:app_database/app_database.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/transaction_account_data.dart';

class PastAndFutureReleasesService {
  const PastAndFutureReleasesService(this.transactions);

  final List<TransactionI> transactions;

  PastAndFutureReleasesCalculationResults calculateResults() {
    final totalIncome = _calculateTotalIncome();
    final totalExpense = _calculateTotalExpense();
    final totalTransfersIn = _calculateTotalTransfersIn();
    final totalTransfersOut = _calculateTotalTransfersOut();

    final totalEntries = totalIncome + totalTransfersIn;
    final totalExits = -(totalExpense + totalTransfersOut);
    final totalResult = totalEntries + totalExits;

    return PastAndFutureReleasesCalculationResults(
      totalEntries: totalEntries,
      totalExits: totalExits,
      totalResult: totalResult,
    );
  }

  double calculateAccountBalance(List<TransactionI> accountTransactions) {
    return accountTransactions.fold<double>(0, (sum, transaction) {
      return sum + transaction.t.amount;
    });
  }

  double _calculateTotalIncome() {
    return transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == FinancialType.income,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalExpense() {
    return -transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == FinancialType.expense,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalTransfersIn() {
    return transactions
        .where(
          (transaction) =>
              transaction.t.transferId != null && transaction.t.amount > 0,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalTransfersOut() {
    return transactions
        .where(
          (transaction) =>
              transaction.t.transferId != null && transaction.t.amount < 0,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount.abs());
  }
}

class PastAndFutureReleasesCalculationResults {
  const PastAndFutureReleasesCalculationResults({
    required this.totalEntries,
    required this.totalExits,
    required this.totalResult,
  });

  final double totalEntries;
  final double totalExits;
  final double totalResult;
}

class PastAndFutureReleasesAccountCalculationResult {
  const PastAndFutureReleasesAccountCalculationResult({
    required this.account,
    required this.transactions,
    required this.calculatedBalance,
  });

  final TransactionsAccount account;
  final List<TransactionI> transactions;
  final double calculatedBalance;
}
