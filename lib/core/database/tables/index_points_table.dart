import 'package:drift/drift.dart';

/// Device-local cache of economic-index observations (CDI/Selic/IPCA), one row
/// per (index, date). A derived cache — not mirrored, not userId-scoped.
/// Accumulates across refreshes so fixed income accrues from the last known
/// series on a cold start. `indexName` stores the `EconomicIndex` name. See
/// docs/specs/quotes.md.
class LocalIndexPoints extends Table {
  TextColumn get indexName => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get rate => real()();

  @override
  Set<Column> get primaryKey => {indexName, date};
}
