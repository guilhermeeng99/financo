import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/datasources/index_data_source.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/repositories/quote_repository.dart';
import 'package:financo/features/investing/domain/services/holding_calculator.dart';
import 'package:financo/features/investing/domain/services/market_cache_store.dart';
import 'package:financo/features/investing/domain/services/portfolio_inputs_builder.dart';
import 'package:financo/features/investing/domain/services/quote_freshness.dart';
import 'package:financo/features/investing/domain/services/valuation_service.dart';

/// Shared portfolio pricing/refresh engine for the dashboard and allocation
/// cubits, which value the *same* portfolio from the *same* caches and only
/// differ in how they present it. It owns the FX rate + economic-index series
/// (warm-started from the durable cache), prices held positions from the local
/// quote cache (no network), and performs the best-effort network refresh.
///
/// Each cubit composes its own instance, so the two screens share the rules but
/// not the state. This is pure domain orchestration (no widgets), so it lives
/// under `domain/services`. See `docs/specs/valuation.md` and
/// `docs/specs/quotes.md`.
///
/// Example:
/// ```dart
/// final engine = PortfolioPricingEngine(
///   quoteRepo, fx, valuation, index, cache, calculator,
/// );
/// await engine.warmStart();
/// final priced = await engine.priceFromCache(transactions, assets);
/// ```
class PortfolioPricingEngine {
  /// Creates the engine over the market-data ports and pure valuation helpers.
  PortfolioPricingEngine(
    this._quoteRepository,
    this._fxDataSource,
    this._valuationService,
    this._indexDataSource,
    this._marketCacheStore,
    this._calculator, [
    this._inputsBuilder = const PortfolioInputsBuilder(),
  ]);

  final QuoteRepository _quoteRepository;
  final FxDataSource _fxDataSource;
  final ValuationService _valuationService;
  final IndexDataSource _indexDataSource;
  final MarketCacheStore _marketCacheStore;
  final HoldingCalculator _calculator;
  final PortfolioInputsBuilder _inputsBuilder;

  /// The currency every holding is consolidated into (the app's base).
  static const Currency _base = Currency.brl;

  /// Latest known rate from each foreign currency into [_base]. A currency
  /// absent here has no loaded rate yet, so holdings in it are passed a null FX
  /// and excluded from totals (with a warning) instead of consolidating at a
  /// bogus 1:1. Each foreign currency is priced independently.
  final Map<Currency, double> _fxToBaseRates = {};

  /// Index series (CDI/Selic/IPCA) reused to accrue fixed income; each holding
  /// filters it from its own purchase date.
  final Map<EconomicIndex, List<IndexPoint>> _indexSeries = {};

  /// Seeds FX + index series from the durable cache so the first paint already
  /// consolidates foreign holdings and accrues fixed income from last-known
  /// data — a reopened app shows the previous values instead of a wrong total
  /// until the network responds. See `docs/specs/quotes.md`.
  Future<void> warmStart() async {
    for (final currency in Currency.values) {
      if (currency == _base) continue;
      final fx = await _marketCacheStore.lastFxRate(currency, _base);
      if (fx != null) _fxToBaseRates[currency] = fx;
    }
    _indexSeries.addAll(await _marketCacheStore.allIndexSeries());
  }

  /// The held assets (open positions + fixed income with cash flows) and their
  /// ids, derived from [transactions] against [assets].
  ({List<Asset> assets, Set<String> ids}) heldPositions(
    List<AssetTransaction> transactions,
    List<Asset> assets,
  ) {
    final holdings = _calculator.derive(transactions);
    final ids = _inputsBuilder.heldAssetIds(holdings, assets, transactions);
    return (assets: assets.where((a) => ids.contains(a.id)).toList(), ids: ids);
  }

  /// True when the held assets' newest cached quote is within [quoteFreshness]
  /// (or nothing is held). Lets the second portfolio screen skip a refresh the
  /// first just did; the freshness signal is shared via `quotes.fetchedAt`.
  Future<bool> quotesAreFresh(Set<String> heldIds) async {
    if (heldIds.isEmpty) return true;
    final last = await _quoteRepository.lastFetchedAt(heldIds.toList());
    return last != null && DateTime.now().difference(last) < quoteFreshness;
  }

  /// Best-effort network refresh: quotes, then the index series each
  /// fixed-income holding needs, then the FX rate into base for **each distinct
  /// foreign currency held** (USD, EUR, …). Each fetched value is persisted to
  /// the durable cache. Callers wrap this in their own try/finally so a failure
  /// keeps cached values on screen.
  Future<void> refreshNetwork(
    List<Asset> heldAssets,
    List<AssetTransaction> transactions,
  ) async {
    await _quoteRepository.refresh(heldAssets);
    await _refreshIndices(heldAssets, transactions);
    final foreign = {
      for (final asset in heldAssets)
        if (asset.currency != _base) asset.currency,
    };
    for (final currency in foreign) {
      final fx = await _fxDataSource.rate(currency, _base);
      await fx.fold((_) async {}, (rate) async {
        _fxToBaseRates[currency] = rate;
        await _marketCacheStore.saveFxRate(currency, _base, rate);
      });
    }
  }

  /// Prices the held positions from the local quote cache (no network),
  /// returning the valuation, an id→asset lookup for the UI, and whether any
  /// position is open (drives the one-shot auto-refresh).
  Future<
    ({
      PortfolioValuation portfolio,
      Map<String, Asset> assetsById,
      bool hasOpenPosition,
    })
  >
  priceFromCache(
    List<AssetTransaction> transactions,
    List<Asset> assets,
  ) async {
    final assetsById = {for (final a in assets) a.id: a};
    final holdings = _calculator.derive(transactions);
    final cached = await _quoteRepository.getCached(
      holdings.map((h) => h.assetId).toList(),
    );
    final quotes = cached.getOrElse(() => const []);
    final quotesById = {for (final q in quotes) q.assetId: q};
    final inputs = _inputsBuilder.build(
      holdings: holdings,
      assetsById: assetsById,
      transactions: transactions,
      quotesById: quotesById,
      indexSeries: _indexSeries,
      fxToBaseRates: _fxToBaseRates,
    );
    final portfolio = _valuationService.valuatePortfolio(
      inputs,
      now: DateTime.now(),
    );
    return (
      portfolio: portfolio,
      assetsById: assetsById,
      hasOpenPosition: holdings.any((h) => h.quantity > 0),
    );
  }

  /// Fetches the index series each held fixed-income asset needs, from the
  /// earliest purchase across positions using that index. Failures are ignored
  /// (the holding shows cost until a series arrives).
  Future<void> _refreshIndices(
    List<Asset> heldAssets,
    List<AssetTransaction> transactions,
  ) async {
    final earliestByIndex = _inputsBuilder.earliestIndexDates(
      heldAssets,
      transactions,
    );
    for (final entry in earliestByIndex.entries) {
      final result = await _indexDataSource.series(entry.key, entry.value);
      await result.fold((_) async {}, (points) async {
        _indexSeries[entry.key] = points;
        await _marketCacheStore.saveIndexSeries(entry.key, points);
      });
    }
  }
}
