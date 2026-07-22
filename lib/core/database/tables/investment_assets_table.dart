import 'package:drift/drift.dart';

/// Local cache for the investing `Asset` (a tradable instrument). Firestore is
/// the source of truth; drop + recreate on every schema bump.
///
/// `kind`, `market` and `currency` store the enum `name`. `metadata` is a JSON
/// object string (defaults to `{}`) carrying kind-specific data and the
/// allocation link. See docs/specs/investing_assets.md.
class LocalInvestmentAssets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get ticker => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get market => text()();
  TextColumn get currency => text()();
  TextColumn get institutionId => text().nullable()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
