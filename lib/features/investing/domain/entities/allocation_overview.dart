import 'package:equatable/equatable.dart';
import 'package:financo/core/money/money.dart';

/// Which way a rebalance action moves money.
enum RebalanceDirection { buy, sell }

/// One asset inside a class, priced against its within-class target. Drives the
/// class-detail page's per-asset "add/trim to reach the target" suggestions
/// (ported from Investanco's subclass slice). All money is in the base currency
/// except [suggestedDeltaNative]. See `docs/specs/allocation.md`.
class AllocationAssetSlice extends Equatable {
  const AllocationAssetSlice({
    required this.assetId,
    required this.ticker,
    required this.currentValue,
    required this.percentOfClass,
    required this.percentOfTotal,
    required this.targetPercent,
    required this.suggestedValue,
    required this.suggestedDelta,
    required this.suggestedDeltaNative,
  });

  final String assetId;
  final String ticker;

  /// Current market value (base).
  final Money currentValue;

  /// Share of its class (0–1).
  final double percentOfClass;

  /// Share of the whole portfolio (0–1).
  ///
  /// Computed and covered by `allocation_service_test.dart` per rule 47 of
  /// `docs/specs/allocation.md`, but nothing renders it yet — the class-detail
  /// page shows [percentOfClass]. Kept because it is a contracted output of
  /// the service, not an accident.
  final double percentOfTotal;

  /// Target share **within its class** (0–100).
  final double targetPercent;

  /// Ideal value = class target value × [targetPercent] / 100 (base).
  ///
  /// Like [percentOfTotal], spec'd and tested but not yet rendered — the UI
  /// shows the derived [suggestedDelta] instead.
  final Money suggestedValue;

  /// `suggestedValue − currentValue` (base). Positive → add (aporte),
  /// negative → trim.
  final Money suggestedDelta;

  /// [suggestedDelta] expressed in the asset's native currency, derived from
  /// the holding's own base↔native ratio. Null for base-currency assets or when
  /// the ratio can't be derived (no current value).
  final Money? suggestedDeltaNative;

  @override
  List<Object?> get props => [
    assetId,
    ticker,
    currentValue,
    percentOfClass,
    percentOfTotal,
    targetPercent,
    suggestedValue,
    suggestedDelta,
    suggestedDeltaNative,
  ];
}

/// A root allocation bucket priced against its target. All money is in the
/// portfolio base currency. See `docs/specs/allocation.md`.
class AllocationClassSlice extends Equatable {
  const AllocationClassSlice({
    required this.classId,
    required this.name,
    required this.icon,
    required this.color,
    required this.currentValue,
    required this.currentPercent,
    required this.targetPercent,
    required this.targetValue,
    required this.delta,
    this.assets = const [],
  });

  final String classId;
  final String name;
  final int icon;
  final int color;

  /// Rolled-up market value of this root and its subclasses (base).
  final Money currentValue;

  /// [currentValue] as a 0–1 fraction of the portfolio total.
  final double currentPercent;

  /// The target weight as a 0–1 fraction.
  final double targetPercent;

  /// Target market value = portfolio total × [targetPercent] (base).
  final Money targetValue;

  /// `targetValue − currentValue` (base). Positive → under target (buy),
  /// negative → over target (sell).
  final Money delta;

  /// The assets linked directly to this class, largest value first. Populated
  /// for the class-detail view; empty in the roll-up.
  final List<AllocationAssetSlice> assets;

  bool get isUnderTarget => delta.minorUnits > 0;
  bool get isOverTarget => delta.minorUnits < 0;

  @override
  List<Object?> get props => [
    classId,
    name,
    icon,
    color,
    currentValue,
    currentPercent,
    targetPercent,
    targetValue,
    delta,
    assets,
  ];
}

/// A single "buy X of class Y" / "sell X of class Y" suggestion.
class RebalanceAction extends Equatable {
  const RebalanceAction({
    required this.classId,
    required this.name,
    required this.direction,
    required this.amount,
  });

  final String classId;
  final String name;
  final RebalanceDirection direction;

  /// Absolute size of the move (base), always positive.
  final Money amount;

  @override
  List<Object?> get props => [classId, name, direction, amount];
}

/// The whole allocation picture: current vs target per bucket, the rebalance
/// moves to close the gaps, and how much value isn't assigned to any bucket.
class AllocationOverview extends Equatable {
  const AllocationOverview({
    required this.totalValue,
    required this.allocatedValue,
    required this.unallocatedValue,
    required this.slices,
    required this.rebalanceActions,
    required this.targetSumPercent,
  });

  /// An empty overview in [base] currency.
  factory AllocationOverview.empty(Money base) {
    final zero = Money.zero(base.currency);
    return AllocationOverview(
      totalValue: zero,
      allocatedValue: zero,
      unallocatedValue: zero,
      slices: const [],
      rebalanceActions: const [],
      targetSumPercent: 0,
    );
  }

  /// Portfolio market value (base), excluding fx-missing holdings.
  final Money totalValue;

  /// Value assigned to a known bucket (base).
  final Money allocatedValue;

  /// Value not assigned to any known bucket (base).
  final Money unallocatedValue;

  /// Root buckets, sorted by current value descending.
  final List<AllocationClassSlice> slices;

  /// Suggested moves to reach targets, largest first.
  final List<RebalanceAction> rebalanceActions;

  /// Sum of root target percentages (0–100), for the "targets ≠ 100%" hint.
  final double targetSumPercent;

  /// Whether root targets sum to ~100% (±0.1).
  bool get targetsBalanced => (targetSumPercent - 100).abs() <= 0.1;

  /// Whether any value is unassigned.
  bool get hasUnallocated => !unallocatedValue.isZero;

  @override
  List<Object?> get props => [
    totalValue,
    allocatedValue,
    unallocatedValue,
    slices,
    rebalanceActions,
    targetSumPercent,
  ];
}
