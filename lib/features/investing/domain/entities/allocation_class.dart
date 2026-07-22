import 'package:equatable/equatable.dart';

/// An allocation bucket (target weight in the portfolio). An investing-owned
/// view of the surviving `asset_classes` collection, kept decoupled from the
/// V1 `investments` feature so removing it (F7) only swaps the mapping at the
/// repository/cubit boundary, not this entity or the pure service over it.
///
/// `icon` is a Material code point (int) and `color` an ARGB int — carried
/// through verbatim from the existing rows. `targetPercent` is 0–100 (a root's
/// share of the whole portfolio; a subclass's share is not used for the
/// class-level rebalance signal).
class AllocationClass extends Equatable {
  const AllocationClass({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetPercent,
    this.parentId,
  });

  final String id;
  final String name;
  final int icon;
  final int color;
  final double targetPercent;
  final String? parentId;

  /// Root buckets weigh the whole portfolio; subclasses roll up into a root.
  bool get isRoot => parentId == null;

  /// `targetPercent` as a 0–1 fraction.
  double get targetFraction => targetPercent / 100;

  @override
  List<Object?> get props => [id, name, icon, color, targetPercent, parentId];
}
