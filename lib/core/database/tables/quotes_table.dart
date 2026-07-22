import 'package:drift/drift.dart';

/// Device-local cache of the latest unit price per asset. A **derived** cache —
/// NOT mirrored to Firestore and NOT scoped by userId (prices are the same for
/// everyone). Survives restarts so a cold start values holdings from the last
/// known price. See docs/specs/quotes.md.
///
/// `currency` and `source` store the enum `name`.
class LocalQuotes extends Table {
  TextColumn get assetId => text()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get previousCloseMinor => integer().nullable()();
  TextColumn get currency => text()();
  DateTimeColumn get asOf => dateTime()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get source => text()();

  @override
  Set<Column> get primaryKey => {assetId};
}
