import 'package:drift/drift.dart';

/// Local cache for `AssetHoldingEntity`. See
/// `lib/core/database/tables/asset_classes_table.dart` for the schema
/// recreate strategy.
class LocalAssetHoldings extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get accountId => text()();
  TextColumn get assetClassId => text()();
  RealColumn get amount => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
