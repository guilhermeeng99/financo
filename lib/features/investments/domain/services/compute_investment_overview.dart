import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';

/// Float tolerance for "allocated equals balance" / "delta is zero"
/// checks. R$0.005 — one tenth of a centavo — well below anything the
/// UI surfaces but enough to absorb cumulative floating-point noise
/// from successive percentage multiplications.
const double _floatTolerance = 0.005;

/// Minimum rebalance amount worth surfacing as an action. Suggestions
/// below R$1 are noise — the user does not care about cents.
const double _minRebalanceAmount = 1;

/// Composes a presentation-friendly snapshot of the user's portfolio
/// from the inputs the repositories already loaded. Pure / synchronous
/// / side-effect free so the unit tests can drive it directly with
/// hand-rolled fixtures.
///
/// Inputs:
///
/// * [accounts] — every account the user owns. The function filters
///   to `AccountType.investment` internally.
/// * [classes] — every asset class (root + subclasses) the user has
///   declared.
/// * [holdings] — every declared allocation. Orphans (those whose
///   `accountId` or `assetClassId` is missing, or whose subclass has
///   a missing parent) are filtered out of the totals and returned
///   separately in `orphanHoldingIds`.
///
/// Output: a fully-formed [InvestmentOverview]. See
/// `specs/investments.md` §4 for the algorithm reference.
InvestmentOverview computeInvestmentOverview({
  required List<AccountEntity> accounts,
  required List<AssetClassEntity> classes,
  required List<AssetHoldingEntity> holdings,
}) {
  final investmentAccounts = accounts
      .where((a) => a.type == AccountType.investment)
      .toList();
  final accountById = {for (final a in investmentAccounts) a.id: a};
  final classById = {for (final c in classes) c.id: c};

  // Roots = classes without a parent. Subclasses with a missing
  // parent are treated as orphans for total-allocation purposes
  // (their holdings count as unclassified).
  final roots = classes.where((c) => c.parentId == null).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  final subclassesByParent = <String, List<AssetClassEntity>>{};
  for (final c in classes) {
    final parentId = c.parentId;
    if (parentId == null) continue;
    if (!classById.containsKey(parentId)) continue; // orphan subclass
    (subclassesByParent[parentId] ??= []).add(c);
  }
  for (final list in subclassesByParent.values) {
    list.sort((a, b) => a.name.compareTo(b.name));
  }

  final liveHoldings = <AssetHoldingEntity>[];
  final orphanIds = <String>[];
  for (final h in holdings) {
    final accountLive = accountById.containsKey(h.accountId);
    final referencedClass = classById[h.assetClassId];
    // A holding is "live" when it has an investment account AND its
    // class exists AND — when the class is itself a subclass — its
    // parent is also resolvable.
    final classLive = referencedClass != null &&
        (referencedClass.parentId == null ||
            classById.containsKey(referencedClass.parentId));
    if (accountLive && classLive) {
      liveHoldings.add(h);
    } else {
      orphanIds.add(h.id);
    }
  }

  final totalInvested = investmentAccounts.fold<double>(
    0,
    (sum, a) => sum + a.effectiveBalance,
  );
  final totalAllocated = liveHoldings.fold<double>(0, (s, h) => s + h.amount);
  final totalPending = (totalInvested - totalAllocated).clamp(
    0.0,
    double.infinity,
  );

  final accountBreakdown = investmentAccounts.map((a) {
    final allocated = liveHoldings
        .where((h) => h.accountId == a.id)
        .fold<double>(0, (s, h) => s + h.amount);
    final pending = (a.effectiveBalance - allocated).clamp(
      0.0,
      double.infinity,
    );
    final hasOverflow = allocated - a.effectiveBalance > _floatTolerance;
    return InvestmentAccountSlice(
      accountId: a.id,
      accountName: a.name,
      balance: a.effectiveBalance,
      allocated: allocated,
      pending: pending,
      hasOverflow: hasOverflow,
    );
  }).toList();

  double amountForClass(String classId) => liveHoldings
      .where((h) => h.assetClassId == classId)
      .fold<double>(0, (s, h) => s + h.amount);

  final classBreakdown = roots.map((root) {
    final subs = subclassesByParent[root.id] ?? const [];
    final rootOwnAmount = amountForClass(root.id);
    final subAmounts = {
      for (final sub in subs) sub.id: amountForClass(sub.id),
    };
    final classTotal = rootOwnAmount +
        subAmounts.values.fold<double>(0, (s, v) => s + v);
    final currentPercent = totalInvested == 0
        ? 0.0
        : classTotal / totalInvested;
    final targetAmount = totalInvested * root.targetFraction;
    final deltaAmount = targetAmount - classTotal;
    final subSlices = subs.map((sub) {
      final subAmount = subAmounts[sub.id] ?? 0;
      return InvestmentSubclassSlice(
        subclassId: sub.id,
        name: sub.name,
        icon: sub.icon,
        color: sub.color,
        currentAmount: subAmount,
        percentOfClass:
            classTotal == 0 ? 0.0 : subAmount / classTotal,
        percentOfTotal:
            totalInvested == 0 ? 0.0 : subAmount / totalInvested,
        targetPercent: sub.targetPercent,
      );
    }).toList();
    return InvestmentClassSlice(
      classId: root.id,
      name: root.name,
      icon: root.icon,
      color: root.color,
      currentAmount: classTotal,
      currentPercent: currentPercent,
      targetPercent: root.targetPercent,
      targetAmount: targetAmount,
      deltaAmount: deltaAmount,
      subclasses: subSlices,
    );
  }).toList();

  final rebalanceActions =
      classBreakdown
          .where((slice) => slice.deltaAmount.abs() >= _minRebalanceAmount)
          .map(
            (slice) => RebalanceAction(
              classId: slice.classId,
              className: slice.name,
              direction: slice.deltaAmount > 0
                  ? RebalanceDirection.buy
                  : RebalanceDirection.sell,
              amount: slice.deltaAmount.abs(),
            ),
          )
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

  // Only roots carry user-defined targets — sum across roots is what
  // the UI compares to 100%.
  final targetSumPercent = roots.fold<double>(
    0,
    (s, c) => s + c.targetPercent,
  );

  return InvestmentOverview(
    totalInvested: totalInvested,
    totalAllocated: totalAllocated,
    totalPending: totalPending,
    accountBreakdown: accountBreakdown,
    classBreakdown: classBreakdown,
    rebalanceActions: rebalanceActions,
    targetSumPercent: targetSumPercent,
    orphanHoldingIds: orphanIds,
  );
}

/// Convenience for the holding form: how much room is left on
/// [account] given the already-declared holdings, excluding the
/// holding currently being edited (so editing it down/up doesn't
/// double-count its own current value). Returns 0 when the account
/// already has overflow.
double computeAvailableForAccount({
  required AccountEntity account,
  required List<AssetHoldingEntity> holdings,
  String? excludeHoldingId,
}) {
  final allocated = holdings
      .where(
        (h) => h.accountId == account.id && h.id != (excludeHoldingId ?? ''),
      )
      .fold<double>(0, (s, h) => s + h.amount);
  return (account.effectiveBalance - allocated).clamp(0.0, double.infinity);
}
