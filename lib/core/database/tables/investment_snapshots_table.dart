import 'package:drift/drift.dart';

/// Local cache of the net-worth history. Firestore is the source of truth; the
/// migration drops + recreates on every schema bump and the sync layer
/// repopulates from remote on next open.
///
/// `id` is the deterministic `${userId}_${dayKey}` so re-recording a day
/// overwrites rather than duplicating. Money is stored as integer minor units
/// with a single base `currency` (enum `name`).
class LocalInvestmentSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get totalValueMinor => integer()();
  IntColumn get totalInvestedMinor => integer()();
  IntColumn get unrealizedPlMinor => integer()();
  TextColumn get currency => text()();

  @override
  Set<Column> get primaryKey => {id};
}
