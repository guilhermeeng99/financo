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
///   hasInvestmentDestination: institutions.isNotEmpty,
/// );
/// final percent = (overview.needsPercent * 100).round();
/// ```
///
/// [hasInvestmentDestination] — whether the user has anywhere to send an
/// aporte. Passed in rather than derived here because the destination is an
/// **institution** after F8, and this dashboard service deliberately stays
/// free of investing types (the two features join in
/// `DashboardRepositoryImpl`). Callers that only need the numbers — the
/// history chart — can leave it false; it drives advice copy only.
FiftyThirtyTwentyOverview compute50_30_20Overview({
  required List<TransactionEntity> periodTransactions,
  required List<CategoryEntity> categories,
  bool hasInvestmentDestination = false,
  FiftyThirtyTwentyTargets targets = FiftyThirtyTwentyTargets.classic,
}) {
  final settledTransactions = periodTransactions
      .where((transaction) => transaction.isPaid)
      .toList();
  final categoriesById = <String, CategoryEntity>{
    for (final c in categories) c.id: c,
  };

  final income = _sumIncome(settledTransactions, categoriesById);
  final expenseBuckets = _bucketExpenses(
    settledTransactions,
    categoriesById,
  );
  final savingsAmount = _netSavingsFlow(settledTransactions);
  return FiftyThirtyTwentyOverview(
    income: income,
    needsSpent: expenseBuckets.needs,
    wantsSpent: expenseBuckets.wants,
    savingsAmount: savingsAmount,
    unclassifiedSpent: expenseBuckets.unclassifiedSpent,
    unclassifiedCount: _unclassifiedRootCount(categories),
    hasInvestmentDestination: hasInvestmentDestination,
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
    // An investment resgate (cash back from an institution) is a savings
    // withdrawal, not income — it's handled by _netSavingsFlow (F8.3).
    if (t.isInvestmentCashFlow) continue;
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
    // An investment aporte (cash into an institution) is savings, not a
    // needs/wants expense — counted by _netSavingsFlow (F8.3).
    if (t.isInvestmentCashFlow) continue;

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

/// Tallies the net flow into the user's carteira: investment cash flows
/// tagged with an `institutionId` (a single-entry aporte/resgate, not an
/// account↔account transfer). An aporte — an expense leaving a checking
/// account into an institution — adds to savings; a resgate coming back
/// subtracts. See `docs/specs/investing_account_unification.md` §4 rule 7.
///
/// The pre-F8 path — pairing transfer legs and counting `checking →
/// investment` — was dropped with `AccountType.investment` in F8.6. Brokers
/// are institutions now, so no account pair can express savings and the
/// branch was unreachable.
double _netSavingsFlow(List<TransactionEntity> txs) {
  var net = 0.0;
  for (final t in txs) {
    if (!t.isInvestmentCashFlow) continue;
    if (t.type == TransactionType.expense) {
      net += t.amount;
    } else {
      net -= t.amount;
    }
  }

  return net < 0 ? 0 : net;
}
