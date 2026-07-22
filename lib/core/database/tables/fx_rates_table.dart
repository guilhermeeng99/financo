import 'package:drift/drift.dart';

/// Device-local cache of the last-known FX rate per pair. A derived cache — not
/// mirrored, not userId-scoped. `pair` is `"${from.code}->${to.code}"`
/// (e.g. `USD->BRL`). See docs/specs/quotes.md.
class LocalFxRates extends Table {
  TextColumn get pair => text()();
  RealColumn get rate => real()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {pair};
}
