import 'package:equatable/equatable.dart';
import 'package:financo/core/money/money.dart';

/// Which way a rebalance action moves money.
enum RebalanceDirection { buy, sell }

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
