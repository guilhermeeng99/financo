import 'package:drift/drift.dart';

/// Local cache for `AssetClassEntity`. Firestore is the source of
/// truth — the migration strategy drops + recreates on every schema
/// bump because the sync layer repopulates from remote on next open.
class LocalAssetClasses extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  IntColumn get icon => integer()();
  IntColumn get color => integer()();
  RealColumn get targetPercent => real().withDefault(const Constant(0))();
  // Nullable — `null` marks a root class. Subclasses reference a root
  // by id. See docs/specs/investments.md §1.
  TextColumn get parentId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
