import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';

/// Durable cache for the derived market data the portfolio needs to value
/// foreign holdings (FX) and accrue fixed income (economic-index series) on a
/// cold start — before any network refresh lands.
///
/// Decouples *persistence* of the last-known FX/index data from the network
/// adapters (which keep their own in-memory TTL cache for in-session dedup).
/// The dashboard and allocation cubits read it on creation (warm start) and
/// write through it after a successful refresh, so closing and reopening the
/// app shows the previous values immediately instead of dropping foreign
/// holdings and zeroing fixed-income yield until the network responds. See
/// `docs/specs/quotes.md`.
///
/// Example:
/// ```dart
/// final rate = await store.lastFxRate(Currency.usd, Currency.brl); // null=none
/// await store.saveFxRate(Currency.usd, Currency.brl, 5.12);
/// ```
abstract class MarketCacheStore {
  /// Last cached multiplier converting [from] into [to], or null if unset.
  Future<double?> lastFxRate(Currency from, Currency to);

  /// Persists [rate] as the latest [from]→[to] multiplier (upsert by pair).
  Future<void> saveFxRate(Currency from, Currency to, double rate);

  /// Every persisted index series, keyed by index, oldest point first.
  Future<Map<EconomicIndex, List<IndexPoint>>> allIndexSeries();

  /// Persists [points] for [index] (upsert by date, so a revised value wins and
  /// the series accumulates across refreshes).
  Future<void> saveIndexSeries(EconomicIndex index, List<IndexPoint> points);
}
