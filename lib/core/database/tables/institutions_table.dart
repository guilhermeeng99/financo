import 'package:drift/drift.dart';

/// Local cache for the investing `Institution` (custody: Nubank, Avenue, …).
/// Firestore is the source of truth; the migration drops + recreates on every
/// schema bump and the sync layer repopulates from remote on next open.
///
/// `kind` and `currency` store the enum `name` (e.g. `broker`, `usd`).
class LocalInstitutions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get currency => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// Optional display hint (a `BankType.name`) for a brand logo/avatar, and an
  /// ARGB colour — set when an investment account is unified into an
  /// institution (F8). Nullable; older rows and manually-created brokers
  /// leave them empty. See docs/specs/investing_account_unification.md.
  TextColumn get bank => text().nullable()();
  IntColumn get color => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
