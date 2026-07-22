# Spec: Quotes & Market Data (investing V2)

> Part of the V2 investing module (`docs/specs/investing.md`). Fetches unit
> prices, FX and indices from public APIs, caches them locally (Drift), and
> exposes a uniform `Quote` regardless of source. Ported from Investanco.

## Ports (`domain/datasources`, `domain/repositories`, `domain/services`)

```dart
abstract class QuoteDataSource {
  bool supports(Asset asset);
  Future<Either<Failure, List<Quote>>> fetch(List<Asset> assets); // batch
}
abstract class FxDataSource {
  Future<Either<Failure, double>> rate(Currency from, Currency to);
}
abstract class IndexDataSource {
  Future<Either<Failure, List<IndexPoint>>> series(EconomicIndex i, DateTime from);
}
abstract class QuoteRepository {          // cache-first
  Future<Either<Failure, List<Quote>>> getCached(List<String> assetIds);
  Future<Either<Failure, List<Quote>>> refresh(List<Asset> assets);
  Future<DateTime?> lastFetchedAt(List<String> assetIds);
}
abstract class MarketCacheStore {         // durable FX + index for warm start
  Future<double?> lastFxRate(Currency from, Currency to);
  Future<void> saveFxRate(Currency from, Currency to, double rate);
  Future<Map<EconomicIndex, List<IndexPoint>>> allIndexSeries();
  Future<void> saveIndexSeries(EconomicIndex index, List<IndexPoint> points);
}
```

## Sources & routing

| Source | Prices | Key | Where |
|---|---|---|---|
| **CoinGecko** | crypto (native BRL/USD) | none | client (`http`) |
| **Tesouro Direto** | treasury bonds (redemption value) | none | client |
| **BCB SGS** | CDI(12)/Selic(11)/IPCA(433) series | none | client |
| **AwesomeAPI** | FX pairs (`USD-BRL`, `EUR-BRL`) | none | client |
| **brapi** | BR equities/FII/ETF/BDR | `BRAPI_TOKEN` | **Cloud Function proxy** |
| **Finnhub** | US equities/ETF | `FINNHUB_TOKEN` | **Cloud Function proxy** |

A registry routes each asset to the first `QuoteDataSource` whose `supports()` is
true. Keyless sources hit the public API directly (`guardedFetch` maps any
transport/parse error to `ServerFailure`, degrading to cache). The keyed sources
go through the **`fetchInvestmentQuotes`** callable
(`functions/src/quotes/fetchInvestmentQuotes.ts`) so `BRAPI_TOKEN`/`FINNHUB_TOKEN`
stay backend secrets, never in the web bundle. brapi batches all BR tickers;
Finnhub is one request per symbol (free tier).

**Deploy (manual, by the owner):**
```bash
firebase functions:secrets:set BRAPI_TOKEN
firebase functions:secrets:set FINNHUB_TOKEN
firebase deploy --only functions:fetchInvestmentQuotes
```
Both secrets are optional: empty `BRAPI_TOKEN` → brapi free tier; empty
`FINNHUB_TOKEN` → US holdings show cost basis (no crash).

## Caching rules

1. **Cached-first**: UI reads cache instantly; refresh runs in background.
2. On fetch failure keep the previous cached quote and mark it **stale**
   (`fetchedAt` age; `staleThreshold` 1 h in valuation).
3. FX and indices have an **in-memory** TTL (`CachingFxDataSource` 10 min,
   `CachingIndexDataSource` 12 h) — shared singletons so the two portfolio
   screens reuse a fetch in-session — **and** a **durable** copy in Drift via
   `MarketCacheStore` (`LocalFxRates`, `LocalIndexPoints`), written through after
   each successful refresh.
4. **Warm start**: on creation `PortfolioPricingEngine.warmStart()` seeds FX +
   index series from `MarketCacheStore`, so a reopened app consolidates foreign
   holdings and accrues fixed income from last-known values before the first
   network response.
5. **Freshness guard**: a background refresh is skipped when the held assets'
   newest `LocalQuotes.fetchedAt` is within `quoteFreshness` (15 min); manual
   refresh passes `force`.

## Drift caches (device-local, not mirrored, no userId)

`LocalQuotes` (assetId pk, unitPriceMinor, previousCloseMinor?, currency, asOf,
fetchedAt, source), `LocalFxRates` (pair pk `"USD->BRL"`, rate, fetchedAt),
`LocalIndexPoints` ((indexName, date) pk, rate). schemaVersion bumped to 13.

## Composition — `PortfolioPricingEngine` (F2c)

Composed per-cubit (a factory, not a singleton — it holds mutable FX/index
state). `warmStart` → `priceFromCache(transactions, assets)` (no network, from
the local quote cache + `PortfolioInputsBuilder`) → `refreshNetwork` (best-effort
quotes + indices + one FX per distinct foreign currency, all written through to
the durable cache). `PortfolioInputsBuilder` (pure) turns holdings + quotes + FX
+ series into `ValuationInput`s (`docs/specs/valuation.md`).

## Edge cases

- Ticker not found at source → no quote; valuation uses cost basis and flags it.
- Weekend/closed market → price unchanged; `asOf` = last session.
- Foreign holding with no FX → excluded from base totals, native subtotal kept
  (`byCurrency`); warned in the UI.
