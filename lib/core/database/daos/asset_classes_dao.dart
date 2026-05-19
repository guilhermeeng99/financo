import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/asset_classes_table.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';

part 'asset_classes_dao.g.dart';

@DriftAccessor(tables: [LocalAssetClasses])
class AssetClassesDao extends DatabaseAccessor<AppDatabase>
    with _$AssetClassesDaoMixin {
  AssetClassesDao(super.attachedDatabase);

  Future<void> insertAllAssetClasses(List<AssetClassEntity> classes) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localAssetClasses,
        classes.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertAssetClass(AssetClassEntity assetClass) => into(
    localAssetClasses,
  ).insertOnConflictUpdate(_toCompanion(assetClass));

  Future<List<AssetClassEntity>> getAssetClasses(String userId) async {
    final rows =
        await (select(localAssetClasses)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  Future<AssetClassEntity?> getAssetClassById(String id) async {
    final row = await (select(
      localAssetClasses,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> deleteAssetClass(String id) =>
      (delete(localAssetClasses)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllAssetClasses() => delete(localAssetClasses).go();

  LocalAssetClassesCompanion _toCompanion(AssetClassEntity e) =>
      LocalAssetClassesCompanion.insert(
        id: e.id,
        userId: e.userId,
        name: e.name,
        icon: e.icon,
        color: e.color,
        targetPercent: Value(e.targetPercent),
        parentId: Value(e.parentId),
        createdAt: e.createdAt,
      );

  // Drift names the row class `LocalAssetClassesData` (rather than
  // dropping the trailing `es`) because its pluralisation heuristic
  // can't safely strip the suffix from "AssetClasses". Matching the
  // generated name keeps the mapping fully typed.
  AssetClassEntity _toEntity(LocalAssetClassesData row) => AssetClassEntity(
    id: row.id,
    userId: row.userId,
    name: row.name,
    icon: row.icon,
    color: row.color,
    targetPercent: row.targetPercent,
    parentId: row.parentId,
    createdAt: row.createdAt,
  );
}
