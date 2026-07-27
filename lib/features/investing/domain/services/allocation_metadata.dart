import 'package:financo/features/investing/domain/entities/asset.dart';

/// Reads and writes the allocation link an [Asset] carries in its `metadata`
/// map: which allocation class (bucket) it belongs to, and its **target share
/// within that class** (a 0–100 percent). Centralizes the key names so the
/// asset form (writer) and the allocation view (reader) never drift.
///
/// The class carries the portfolio-level target (`AssetClass.targetPercent`);
/// the per-asset [target] here refines it — the class's target value is split
/// across its assets by their [target] shares, driving the class-detail page's
/// per-asset "add to reach the target" suggestions (ported from Investanco).
/// An asset with no target set (0) contributes nothing to a suggestion.
abstract final class AllocationMetadata {
  /// Metadata key for the linked `AssetClass` id.
  static const classIdKey = 'allocationClassId';

  /// Metadata key for the asset's target share **within its class** (percent).
  static const targetKey = 'allocationTargetPercent';

  /// The linked allocation class id, or null when the asset is unclassified.
  static String? classId(Asset asset) {
    final value = asset.metadata[classIdKey];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// The asset's target share within its class (`[0, 100]`; 0 when unset).
  static double target(Asset asset) =>
      double.tryParse(asset.metadata[targetKey] ?? '') ?? 0;

  /// A copy of [metadata] with the allocation class set to [classId] and the
  /// within-class [targetPercent] (or both keys removed when [classId] is
  /// null/empty). Never mutates the input.
  static Map<String, String> write(
    Map<String, String> metadata,
    String? classId, {
    double targetPercent = 0,
  }) {
    final next = Map<String, String>.from(metadata);
    if (classId == null || classId.isEmpty) {
      next
        ..remove(classIdKey)
        ..remove(targetKey);
    } else {
      next[classIdKey] = classId;
      next[targetKey] = _formatTarget(targetPercent);
    }
    return next;
  }

  /// Trims a target percent to a compact string: `57.0` → `"57"`, `12.5` →
  /// `"12.5"`. Keeps the stored metadata free of noisy trailing zeros.
  static String _formatTarget(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
