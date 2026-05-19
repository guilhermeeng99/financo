import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/asset_holdings_table.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';

part 'asset_holdings_dao.g.dart';

@DriftAccessor(tables: [LocalAssetHoldings])
class AssetHoldingsDao extends DatabaseAccessor<AppDatabase>
    with _$AssetHoldingsDaoMixin {
  AssetHoldingsDao(super.attachedDatabase);

  Future<void> insertAllAssetHoldings(List<AssetHoldingEntity> holdings) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localAssetHoldings,
        holdings.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertAssetHolding(AssetHoldingEntity holding) => into(
    localAssetHoldings,
  ).insertOnConflictUpdate(_toCompanion(holding));

  Future<List<AssetHoldingEntity>> getAssetHoldings(String userId) async {
    final rows =
        await (select(localAssetHoldings)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  Future<AssetHoldingEntity?> getAssetHoldingById(String id) async {
    final row = await (select(
      localAssetHoldings,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> deleteAssetHolding(String id) =>
      (delete(localAssetHoldings)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllAssetHoldings() => delete(localAssetHoldings).go();

  Future<void> deleteHoldingsForAccount(String accountId) =>
      (delete(localAssetHoldings)
            ..where((t) => t.accountId.equals(accountId)))
          .go();

  Future<void> deleteHoldingsForClass(String classId) =>
      (delete(localAssetHoldings)
            ..where((t) => t.assetClassId.equals(classId)))
          .go();

  LocalAssetHoldingsCompanion _toCompanion(AssetHoldingEntity e) =>
      LocalAssetHoldingsCompanion.insert(
        id: e.id,
        userId: e.userId,
        accountId: e.accountId,
        assetClassId: e.assetClassId,
        amount: e.amount,
        notes: Value(e.notes),
        updatedAt: e.updatedAt,
      );

  AssetHoldingEntity _toEntity(LocalAssetHolding row) => AssetHoldingEntity(
    id: row.id,
    userId: row.userId,
    accountId: row.accountId,
    assetClassId: row.assetClassId,
    amount: row.amount,
    notes: row.notes,
    updatedAt: row.updatedAt,
  );
}
