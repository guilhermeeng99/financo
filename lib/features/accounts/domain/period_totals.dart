import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

/// Sums income vs. expense over a period's transactions.
///
/// Pure domain math so the statement cubit only orchestrates — mirrors how
/// running-balance lives in `applyTransactionsToAccounts` rather than in the
/// cubit. Each transaction counts by its own leg type, so a transfer's
/// expense leg adds to `expenses` and its income leg to `income` (matching
/// how the statement renders both sides).
///
/// Example:
/// ```dart
/// final totals = sumPeriodTotals(periodTransactions);
/// print(totals.income - totals.expenses); // net result
/// ```
({double income, double expenses}) sumPeriodTotals(
  Iterable<TransactionEntity> transactions,
) {
  var income = 0.0;
  var expenses = 0.0;
  for (final tx in transactions) {
    if (tx.type == TransactionType.income) {
      income += tx.amount;
    } else {
      expenses += tx.amount;
    }
  }
  return (income: income, expenses: expenses);
}
