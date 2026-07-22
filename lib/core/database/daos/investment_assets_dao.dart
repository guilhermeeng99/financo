import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/investment_assets_table.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';

part 'investment_assets_dao.g.dart';

@DriftAccessor(tables: [LocalInvestmentAssets])
class InvestmentAssetsDao extends DatabaseAccessor<AppDatabase>
    with _$InvestmentAssetsDaoMixin {
  InvestmentAssetsDao(super.attachedDatabase);

  Future<void> insertAllAssets(List<Asset> assets) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localInvestmentAssets,
        assets.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertAsset(Asset asset) =>
      into(localInvestmentAssets).insertOnConflictUpdate(_toCompanion(asset));

  Future<List<Asset>> getAssets(String userId) async {
    final rows =
        await (select(localInvestmentAssets)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.asc(t.ticker)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> deleteAsset(String id) =>
      (delete(localInvestmentAssets)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllAssets() => delete(localInvestmentAssets).go();

  LocalInvestmentAssetsCompanion _toCompanion(Asset e) =>
      LocalInvestmentAssetsCompanion.insert(
        id: e.id,
        userId: e.userId,
        ticker: e.ticker,
        name: e.name,
        kind: e.kind.name,
        market: e.market.name,
        currency: e.currency.name,
        institutionId: Value(e.institutionId),
        metadata: Value(jsonEncode(e.metadata)),
        createdAt: e.createdAt,
      );

  Asset _toEntity(LocalInvestmentAsset row) => Asset(
    id: row.id,
    userId: row.userId,
    ticker: row.ticker,
    name: row.name,
    kind: AssetKind.values.byName(row.kind),
    market: Market.values.byName(row.market),
    currency: Currency.values.byName(row.currency),
    institutionId: row.institutionId,
    metadata: Map<String, String>.from(
      jsonDecode(row.metadata) as Map<String, dynamic>,
    ),
    createdAt: row.createdAt,
  );
}
