import 'package:equatable/equatable.dart';

/// Direction of a rebalance suggestion — `buy` means the user should
/// move more money into the class (it is below target), `sell` means
/// the opposite. The UI maps these to "Comprar" / "Vender" verbs.
enum RebalanceDirection { buy, sell }

/// Aggregated, computed snapshot of a user's portfolio. Built by
/// `computeInvestmentOverview` in
/// `lib/features/investments/domain/services/compute_investment_overview.dart`
/// from the live account balances + asset classes + asset holdings.
///
/// Never persisted, always rebuilt. See `specs/investments.md` §1.
class InvestmentOverview extends Equatable {
  const InvestmentOverview({
    required this.totalInvested,
    required this.totalAllocated,
    required this.totalPending,
    required this.accountBreakdown,
    required this.classBreakdown,
    required this.rebalanceActions,
    required this.targetSumPercent,
    required this.orphanHoldingIds,
  });

  /// Sum of `effectiveBalance` across every `AccountType.investment`
  /// account. The "envelope" the holdings sit inside.
  final double totalInvested;

  /// Sum of every live `holding.amount` (orphans excluded).
  final double totalAllocated;

  /// `max(0, totalInvested - totalAllocated)`. Always ≥ 0; the
  /// per-account slice carries the per-account version of the same
  /// invariant.
  final double totalPending;

  final List<InvestmentAccountSlice> accountBreakdown;
  final List<InvestmentClassSlice> classBreakdown;
  final List<RebalanceAction> rebalanceActions;

  /// Sum of every class's `targetPercent`. The UI warns the user to
  /// adjust to 100 when this differs from 100 by more than 0.1 — see
  /// rule 7 in `specs/investments.md`.
  final double targetSumPercent;

  /// Holdings that point at a missing account or class. Surfaced in
  /// the "Manutenção" maintenance section of the page so the user can
  /// remove them.
  final List<String> orphanHoldingIds;

  bool get hasInvestments => totalInvested > 0;

  /// `true` whenever at least one account has `pending > 0`. Used to
  /// drive the dashboard banner (V1.1 follow-up) and the per-account
  /// pending list.
  bool get hasPending => totalPending > 0;

  /// Whether the user-defined targets are roughly balanced.
  bool get targetsBalanced => (targetSumPercent - 100).abs() <= 0.1;

  @override
  List<Object?> get props => [
    totalInvested,
    totalAllocated,
    totalPending,
    accountBreakdown,
    classBreakdown,
    rebalanceActions,
    targetSumPercent,
    orphanHoldingIds,
  ];
}

class InvestmentAccountSlice extends Equatable {
  const InvestmentAccountSlice({
    required this.accountId,
    required this.accountName,
    required this.balance,
    required this.allocated,
    required this.pending,
    required this.hasOverflow,
  });

  final String accountId;
  final String accountName;
  final double balance;
  final double allocated;
  final double pending;

  /// `true` when `allocated > balance` (within float tolerance). The
  /// form blocks this on write, but a withdrawal after a holding
  /// write can produce the state. UI surfaces a reconcile prompt.
  final bool hasOverflow;

  @override
  List<Object?> get props => [
    accountId,
    accountName,
    balance,
    allocated,
    pending,
    hasOverflow,
  ];
}

class InvestmentClassSlice extends Equatable {
  const InvestmentClassSlice({
    required this.classId,
    required this.name,
    required this.icon,
    required this.color,
    required this.currentAmount,
    required this.currentPercent,
    required this.targetPercent,
    required this.targetAmount,
    required this.deltaAmount,
    this.subclasses = const [],
  });

  final String classId;
  final String name;
  final int icon;
  final int color;

  /// Includes the root's own holdings PLUS every subclass holding —
  /// the root is the only level the rebalance algorithm reasons about.
  final double currentAmount;

  /// `currentAmount / totalInvested` in the `[0, 1]` range. 0 when
  /// `totalInvested == 0` (we never divide by zero).
  final double currentPercent;

  /// Mirror of the class's stored target (kept here so the UI can
  /// render a slice without holding a reference to the class entity).
  final double targetPercent;

  final double targetAmount;

  /// `targetAmount - currentAmount`. Positive ⇒ below target (need
  /// to buy more). Negative ⇒ above target (could sell).
  final double deltaAmount;

  /// Direct subclasses of this root, in stable name order. Empty when
  /// the class has no children. See `specs/investments.md` §1.
  final List<InvestmentSubclassSlice> subclasses;

  bool get isUnderTarget => deltaAmount > 0;
  bool get isOverTarget => deltaAmount < 0;
  bool get hasSubclasses => subclasses.isNotEmpty;

  @override
  List<Object?> get props => [
    classId,
    name,
    icon,
    color,
    currentAmount,
    currentPercent,
    targetPercent,
    targetAmount,
    deltaAmount,
    subclasses,
  ];
}

class InvestmentSubclassSlice extends Equatable {
  const InvestmentSubclassSlice({
    required this.subclassId,
    required this.name,
    required this.icon,
    required this.color,
    required this.currentAmount,
    required this.percentOfClass,
    required this.percentOfTotal,
    required this.targetPercent,
  });

  final String subclassId;
  final String name;
  final int icon;
  final int color;
  final double currentAmount;

  /// Share of the parent class's `currentAmount`. `[0, 1]`. Returns 0
  /// when the parent has no holdings (avoids division by zero).
  final double percentOfClass;

  /// Share of `totalInvested`. Useful for the donut overlay.
  final double percentOfTotal;

  /// User-declared target share of the parent class (`[0, 100]`).
  /// Sum across siblings should equal 100 — see
  /// `validateSiblingTargetSum`. 0 means "no target set yet".
  final double targetPercent;

  @override
  List<Object?> get props => [
    subclassId,
    name,
    icon,
    color,
    currentAmount,
    percentOfClass,
    percentOfTotal,
    targetPercent,
  ];
}

class RebalanceAction extends Equatable {
  const RebalanceAction({
    required this.classId,
    required this.className,
    required this.direction,
    required this.amount,
  });

  final String classId;
  final String className;
  final RebalanceDirection direction;

  /// Absolute R$ amount to move (always > 0). Direction tells the UI
  /// whether to render it as a buy or sell.
  final double amount;

  @override
  List<Object?> get props => [classId, className, direction, amount];
}
