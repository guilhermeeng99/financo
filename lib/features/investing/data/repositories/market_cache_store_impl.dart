import 'package:financo/core/database/daos/fx_rates_dao.dart';
import 'package:financo/core/database/daos/index_points_dao.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:financo/features/investing/domain/services/market_cache_store.dart';

/// Drift-backed [MarketCacheStore]. FX rates are stored one row per pair; index
/// observations one row per (index, date), so a series accumulates across
/// refreshes and a single read returns the whole history for an index.
class DriftMarketCacheStore implements MarketCacheStore {
  /// Creates the store over the FX and index caches.
  const DriftMarketCacheStore({
    required FxRatesDao fxRatesDao,
    required IndexPointsDao indexPointsDao,
  }) : _fx = fxRatesDao,
       _index = indexPointsDao;

  final FxRatesDao _fx;
  final IndexPointsDao _index;

  String _pairKey(Currency from, Currency to) => '${from.code}->${to.code}';

  @override
  Future<double?> lastFxRate(Currency from, Currency to) =>
      _fx.getRate(_pairKey(from, to));

  @override
  Future<void> saveFxRate(Currency from, Currency to, double rate) =>
      _fx.saveRate(_pairKey(from, to), rate, DateTime.now());

  @override
  Future<Map<EconomicIndex, List<IndexPoint>>> allIndexSeries() async {
    final byName = await _index.allByIndexName();
    final byIndex = <EconomicIndex, List<IndexPoint>>{};
    byName.forEach((name, points) {
      final index = _indexByName(name);
      if (index != null) byIndex[index] = points;
    });
    return byIndex;
  }

  @override
  Future<void> saveIndexSeries(EconomicIndex index, List<IndexPoint> points) =>
      _index.saveSeries(index.name, points);

  EconomicIndex? _indexByName(String name) {
    for (final value in EconomicIndex.values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
