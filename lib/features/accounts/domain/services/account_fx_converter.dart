import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:financo/features/investing/domain/services/market_cache_store.dart';

/// Converts a foreign-currency account amount into the base currency (BRL) at
/// the **current** FX rate, for the consolidated cash-side views (dashboard
/// total, income/expense, 50/30/20). Native amounts stay exact; only this
/// roll-up is an estimate (F9 — see `docs/specs/multi_currency_accounts.md`).
///
/// It reuses the investing FX stack: the durable [MarketCacheStore] (shared
/// with the portfolio's warm start) is read first, and only on a miss is a
/// rate fetched from [FxDataSource] and written back. A currency with no cached
/// and no fetchable rate yields `null`, and the caller drops it from the BRL
/// total rather than consolidating at a bogus 1:1.
class AccountFxConverter {
  const AccountFxConverter({
    required FxDataSource fxDataSource,
    required MarketCacheStore cache,
  }) : _fx = fxDataSource,
       _cache = cache;

  final FxDataSource _fx;
  final MarketCacheStore _cache;

  static const Currency _base = Currency.brl;

  /// The current multiplier converting [from] into BRL (1.0 for BRL). Cache
  /// first; on a miss, fetches once and persists. Null when unavailable.
  Future<double?> rateToBrl(Currency from) async {
    if (from == _base) return 1;
    final cached = await _cache.lastFxRate(from, _base);
    if (cached != null) return cached;
    final fetched = await _fx.rate(from, _base);
    return fetched.fold(
      (_) => Future<double?>.value(),
      (rate) async {
        await _cache.saveFxRate(from, _base, rate);
        return rate;
      },
    );
  }

  /// [amount] (native to [from]) converted to BRL, or null when no rate exists.
  Future<double?> toBrl(double amount, Currency from) async {
    final rate = await rateToBrl(from);
    return rate == null ? null : amount * rate;
  }

  /// Resolves BRL rates for each distinct currency in [currencies], omitting
  /// any that has no rate. Lets a consumer fetch every rate it needs up front.
  Future<Map<Currency, double>> ratesToBrl(
    Iterable<Currency> currencies,
  ) async {
    final rates = <Currency, double>{};
    for (final currency in currencies.toSet()) {
      final rate = await rateToBrl(currency);
      if (rate != null) rates[currency] = rate;
    }
    return rates;
  }
}
