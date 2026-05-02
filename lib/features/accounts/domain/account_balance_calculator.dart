import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

/// Returns a copy of [accounts] with `currentBalance` populated from the
/// running effect of [transactions].
///
/// Sign convention per account type:
/// - **Checking**: `seed + Σincome - Σexpense` — positive means money in
///   the account.
/// - **Credit card**: `seed + Σexpense - Σincome` — positive means the
///   amount currently owed. Spending on the card raises the bill;
///   payments (transfers from a checking account, refunds) reduce it.
///
/// Transactions whose `accountId` does not match any of [accounts] are
/// ignored so the function is safe to call before all accounts have
/// been fetched.
List<AccountEntity> applyTransactionsToAccounts(
  List<AccountEntity> accounts,
  List<TransactionEntity> transactions,
) {
  if (accounts.isEmpty) return accounts;
  final byId = {for (final a in accounts) a.id: a};
  final deltas = <String, double>{};
  for (final tx in transactions) {
    final account = byId[tx.accountId];
    if (account == null) continue;
    deltas[tx.accountId] =
        (deltas[tx.accountId] ?? 0) + _delta(account.type, tx);
  }
  return accounts
      .map(
        (a) => a.copyWith(
          currentBalance: a.initialBalance + (deltas[a.id] ?? 0),
        ),
      )
      .toList();
}

double _delta(AccountType type, TransactionEntity tx) {
  switch (type) {
    case AccountType.checking:
      return tx.type == TransactionType.income ? tx.amount : -tx.amount;
    case AccountType.creditCard:
      return tx.type == TransactionType.expense ? tx.amount : -tx.amount;
  }
}
