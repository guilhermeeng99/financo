import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

/// Pure compose of `FiftyThirtyTwentyOverview` from the data the dashboard
/// already fetches. Stateless, synchronous, no IO. The full algorithm
/// lives in `docs/specs/fifty_thirty_twenty.md` §4 — keep this implementation
/// aligned.
///
/// **Why a top-level function and not a use case**: every input is
/// already on hand inside `DashboardRepositoryImpl.getDashboardSummary`.
/// Wrapping this in a class + DI registration would only buy ceremony.
/// Tests exercise it directly with raw lists.
///
/// Example:
/// ```dart
/// final overview = compute50_30_20Overview(
///   periodTransactions: txs,
///   categories: cats,
///   accounts: accs,
/// );
/// final percent = (overview.needsPercent * 100).round();
/// ```
FiftyThirtyTwentyOverview compute50_30_20Overview({
  required List<TransactionEntity> periodTransactions,
  required List<CategoryEntity> categories,
  required List<AccountEntity> accounts,
  FiftyThirtyTwentyTargets targets = FiftyThirtyTwentyTargets.classic,
}) {
  final settledTransactions = periodTransactions
      .where((transaction) => transaction.isPaid)
      .toList();
  final categoriesById = <String, CategoryEntity>{
    for (final c in categories) c.id: c,
  };
  final accountTypeById = <String, AccountType>{
    for (final a in accounts) a.id: a.type,
  };

  final income = _sumIncome(settledTransactions, categoriesById);
  final expenseBuckets = _bucketExpenses(
    settledTransactions,
    categoriesById,
  );
  final savingsAmount = _netSavingsFlow(
    settledTransactions,
    accountTypeById,
  );
  final hasInvestmentAccount = accounts.any(
    (a) => a.type == AccountType.investment,
  );

  return FiftyThirtyTwentyOverview(
    income: income,
    needsSpent: expenseBuckets.needs,
    wantsSpent: expenseBuckets.wants,
    savingsAmount: savingsAmount,
    unclassifiedSpent: expenseBuckets.unclassifiedSpent,
    unclassifiedCount: _unclassifiedRootCount(categories),
    hasInvestmentAccount: hasInvestmentAccount,
    targets: targets,
  );
}

/// Count of **root expense categories** with no bucket assigned. Built
/// from the full categories list (not from period transactions) so the
/// "$N categorias sem classificação" CTA reflects the user's full
/// backlog, not just the categories that happened to spend this month.
/// Subcategories are excluded — they inherit (see specs rule 20).
int _unclassifiedRootCount(List<CategoryEntity> categories) {
  var count = 0;
  for (final c in categories) {
    if (c.type != CategoryType.expense) continue;
    if (c.parentId != null) continue;
    if (c.bucket != null) continue;
    count++;
  }
  return count;
}

double _sumIncome(
  List<TransactionEntity> txs,
  Map<String, CategoryEntity> categoriesById,
) {
  var total = 0.0;
  for (final t in txs) {
    if (t.type != TransactionType.income) continue;
    if (t.isTransfer) continue;
    // Income categories can opt out of feeding the 50/30/20 base —
    // useful for one-off receipts (reimbursements, gifts) that would
    // otherwise distort the monthly percentage breakdown.
    //
    // Sub-income categories inherit the flag from their parent
    // (docs/specs/categories.md rule 22); the persisted value on a sub is
    // always `true` (neutral), so we must resolve to the root here.
    final cat = categoriesById[t.categoryId];
    if (cat != null) {
      final root = cat.parentId == null
          ? cat
          : (categoriesById[cat.parentId] ?? cat);
      if (!root.countsIn50_30_20) continue;
    }
    total += t.amount;
  }
  return total;
}

/// Walks expenses once, binning by the transaction's category bucket.
/// Subcategories **inherit the parent's bucket** (see
/// `docs/specs/categories.md` rule 20) — the subcategory's own bucket field
/// is ignored. Orphans (deleted parent or deleted category) charge to
/// `unclassifiedSpent` so the bar still reflects the spend, even though
/// they can't be "classified" through the categories form.
({
  double needs,
  double wants,
  double unclassifiedSpent,
})
_bucketExpenses(
  List<TransactionEntity> txs,
  Map<String, CategoryEntity> categoriesById,
) {
  var needs = 0.0;
  var wants = 0.0;
  var unclassifiedSpent = 0.0;

  for (final t in txs) {
    if (t.type != TransactionType.expense) continue;
    if (t.isTransfer) continue;

    final cat = categoriesById[t.categoryId];
    if (cat == null) {
      // Orphan category (deleted on another device, etc.).
      unclassifiedSpent += t.amount;
      continue;
    }

    // Resolve to the root category. Subcategory.bucket is ignored by
    // design — the user classifies once, at the root.
    final rootCat = cat.parentId == null ? cat : categoriesById[cat.parentId];
    if (rootCat == null) {
      // Subcategory whose parent was deleted (orphan parent).
      unclassifiedSpent += t.amount;
      continue;
    }

    switch (rootCat.bucket) {
      case CategoryBucket.needs:
        needs += t.amount;
      case CategoryBucket.wants:
        wants += t.amount;
      case null:
        unclassifiedSpent += t.amount;
    }
  }

  return (
    needs: needs,
    wants: wants,
    unclassifiedSpent: unclassifiedSpent,
  );
}

/// Pairs transfer legs by `linkedTransactionId` and tallies the net flow
/// `checking → investment`. Every other source/destination combination
/// is ignored (see `docs/specs/fifty_thirty_twenty.md` §2 rule 4).
///
/// **Pairing detail**: the expense leg carries the source account; the
/// income leg carries the destination. The pair is established by
/// matching one leg's id with the other's `linkedTransactionId`. We
/// process each pair once by keying the lookup on the expense leg.
double _netSavingsFlow(
  List<TransactionEntity> txs,
  Map<String, AccountType> accountTypeById,
) {
  final byId = <String, TransactionEntity>{
    for (final t in txs) t.id: t,
  };

  var net = 0.0;
  for (final t in txs) {
    if (!t.isTransfer) continue;
    if (t.type != TransactionType.expense) continue;
    // Only walk one side of each pair. The expense leg is the canonical
    // entry point because it always carries the source account.
    final mate = byId[t.linkedTransactionId];
    if (mate == null) continue; // half-pair (other leg outside the window)
    final srcType = accountTypeById[t.accountId];
    final dstType = accountTypeById[mate.accountId];
    if (srcType == null || dstType == null) continue;

    if (srcType == AccountType.checking && dstType == AccountType.investment) {
      net += t.amount;
    } else if (srcType == AccountType.investment &&
        dstType == AccountType.checking) {
      net -= t.amount;
    }
    // checking ↔ checking, investment ↔ investment, anything with credit
    // card: not savings — ignored.
  }

  return net < 0 ? 0 : net;
}
