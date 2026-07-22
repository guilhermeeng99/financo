import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/fx_rates_table.dart';

part 'fx_rates_dao.g.dart';

@DriftAccessor(tables: [LocalFxRates])
class FxRatesDao extends DatabaseAccessor<AppDatabase> with _$FxRatesDaoMixin {
  FxRatesDao(super.attachedDatabase);

  /// The cached multiplier for [pair] (`"USD->BRL"`), or null if none stored.
  Future<double?> getRate(String pair) async {
    final row = await (select(
      localFxRates,
    )..where((t) => t.pair.equals(pair))).getSingleOrNull();
    return row?.rate;
  }

  Future<void> saveRate(String pair, double rate, DateTime fetchedAt) {
    return into(localFxRates).insert(
      LocalFxRatesCompanion.insert(
        pair: pair,
        rate: rate,
        fetchedAt: fetchedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteAllFxRates() => delete(localFxRates).go();
}
