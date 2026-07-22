import 'package:financo/features/investing/domain/entities/asset.dart';

/// Reads and writes the allocation link an [Asset] carries in its `metadata`
/// map: which allocation class (bucket) it belongs to. Centralizes the key name
/// so the asset form (writer) and the allocation view (reader) never drift.
///
/// The **target** percentage lives on the `AssetClass` (the V1 collection that
/// survives the V2 migration), not on the asset — an asset only points at its
/// class here, so retargeting a class moves every asset in it at once.
abstract final class AllocationMetadata {
  /// Metadata key for the linked `AssetClass` id.
  static const classIdKey = 'allocationClassId';

  /// The linked allocation class id, or null when the asset is unclassified.
  static String? classId(Asset asset) {
    final value = asset.metadata[classIdKey];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// A copy of [metadata] with the allocation class set to [classId] (or the
  /// key removed when [classId] is null/empty). Never mutates the input.
  static Map<String, String> write(
    Map<String, String> metadata,
    String? classId,
  ) {
    final next = Map<String, String>.from(metadata);
    if (classId == null || classId.isEmpty) {
      next.remove(classIdKey);
    } else {
      next[classIdKey] = classId;
    }
    return next;
  }
}
