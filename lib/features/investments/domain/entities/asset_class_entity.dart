import 'package:equatable/equatable.dart';

/// A user-defined bucket inside an investment portfolio — e.g. "Real
/// Estate", "Bitcoin", "Renda Fixa". The user picks the name, icon
/// and colour, and sets the **target allocation** they want for it
/// (`targetPercent`, 0–100). The investments overview compares the
/// realised allocation (Σ holdings of this class) against the target
/// and surfaces rebalance suggestions.
///
/// May be a **subclass** when `parentId != null`. Subclasses sit under
/// a root class (e.g. "Apple" under "Stocks"), inherit the parent's
/// `icon` + `color` at write time, and persist `targetPercent: 0` —
/// the root carries the group's target. See
/// `specs/investments.md` §1 subclass rules.
class AssetClassEntity extends Equatable {
  const AssetClassEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetPercent,
    required this.createdAt,
    this.parentId,
  });

  final String id;
  final String userId;
  final String name;
  final int icon;
  final int color;

  /// Target allocation in **percent** (`[0, 100]`). The investments
  /// overview computes `targetAmount = totalInvested * targetPercent / 100`.
  /// Sum across all classes *should* be 100 but is not enforced —
  /// mid-edit states are valid. Always `0` on subclasses.
  final double targetPercent;

  /// `null` for root classes; references the parent root for subclasses.
  /// Only one nesting level is permitted (subclasses cannot themselves
  /// be parents).
  final String? parentId;

  final DateTime createdAt;

  double get targetFraction => targetPercent / 100;

  /// Whether this row is a subclass (i.e. has a parent).
  bool get isSubclass => parentId != null;

  /// Roots are the only valid parent picker entries.
  bool get canBeParent => parentId == null;

  AssetClassEntity copyWith({
    String? id,
    String? userId,
    String? name,
    int? icon,
    int? color,
    double? targetPercent,
    String? parentId,
    bool clearParentId = false,
    DateTime? createdAt,
  }) {
    return AssetClassEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetPercent: targetPercent ?? this.targetPercent,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    icon,
    color,
    targetPercent,
    parentId,
    createdAt,
  ];
}
