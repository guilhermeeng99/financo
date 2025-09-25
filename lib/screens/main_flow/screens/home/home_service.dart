import 'package:app_database/app_database.dart';

class HomeCalculationsService {
  static double calculateTotalIncome(List<TransactionI> transactions) {
    return transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == FinancialType.income,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount);
  }

  static double calculateTotalExpense(List<TransactionI> transactions) {
    return transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == FinancialType.expense,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.t.amount);
  }

  static double getTotalByType(
    FinancialType financialType,
    List<TransactionI> transactions,
  ) {
    switch (financialType) {
      case FinancialType.income:
        return calculateTotalIncome(transactions);
      case FinancialType.expense:
        return calculateTotalExpense(transactions);
    }
  }

  static Map<String, double> getTransactionsByCategory(
    FinancialType financialType,
    List<TransactionI> transactions,
  ) {
    final filteredTransactions = transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == financialType &&
              !transaction.t.isTransfer,
        )
        .toList();

    final transactionsByCategory = <String, double>{};

    for (final transaction in filteredTransactions) {
      final categoryName = transaction.categoryName ?? 'No Category';
      final amount = transaction.t.amount;

      if (transactionsByCategory.containsKey(categoryName)) {
        transactionsByCategory[categoryName] =
            transactionsByCategory[categoryName]! + amount;
      } else {
        transactionsByCategory[categoryName] = amount;
      }
    }

    return transactionsByCategory;
  }

  static List<MapEntry<String, double>> getSortedTransactionsByCategory(
    FinancialType financialType,
    List<TransactionI> transactions,
  ) {
    final transactionsByCategory = getTransactionsByCategory(
      financialType,
      transactions,
    );
    final sortedEntries = transactionsByCategory.entries.toList();

    if (financialType == FinancialType.expense) {
      sortedEntries.sort((a, b) => a.value.compareTo(b.value));
    } else {
      sortedEntries.sort((a, b) => b.value.compareTo(a.value));
    }

    return sortedEntries;
  }
}
