import 'package:drift/drift.dart';

/// Local cache for the investing `AssetTransaction` (buy/sell/dividend event).
/// Firestore is the source of truth; drop + recreate on every schema bump.
///
/// Money is stored as integer minor units (`*Minor`) plus a single `currency`
/// (enum `name`) reapplied to all three money fields. `kind` stores the enum
/// `name`. See docs/specs/investing_transactions.md.
class LocalInvestmentTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get institutionId => text()();
  TextColumn get assetId => text()();
  TextColumn get kind => text()();
  RealColumn get quantity => real()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get feesMinor => integer()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
