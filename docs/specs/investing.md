# Investing (V2) — Umbrella Spec

> **Status**: V2 — design (umbrella). Supersedes `investments.md` (V1, tracking-only).
> **Last updated**: 2026-07-22
> **Coverage**: Scope decisions · reconciled model · entity contracts · target persistence · architecture · migration · phase map · edge cases
> **Companion**: `docs/investanco-integration-plan.md` (the integration plan + locked decisions this spec formalizes).

This spec replaces Financo's tracking-only investments module with a **real
investing ledger** ported from Investanco (`C:\Users\guiga\Documents\Projetos\Investanco`):
the user records **what they own** (buy/sell/dividend transactions); the app
**derives positions**, **prices them** from public market-data APIs, **consolidates
multi-currency net worth** to BRL via FX, and **snapshots** the total daily. Same
stack both sides — this is a **port with adaptation**, not a rewrite.

Per-feature specs (`institutions.md`, `investing_transactions.md`, `holdings.md`,
`quotes.md`, `valuation.md`, `fixed_income.md`, `snapshots.md`,
`allocation_v2.md`, `investing_csv_import.md`) are written **per phase** — this
umbrella fixes the model, invariants and seams they must honor.

---

## 0. Scope decisions (locked 2026-07-22)

Debated in the integration plan §7 and locked before code:

1. **The V1 module is fully replaced.** `lib/features/investments/` (manual
   `AssetHoldingEntity.amount` in BRL) is deleted. The **Model-A balance-ceiling
   invariant is removed** — a market-valued portfolio legitimately exceeds the
   principal held on any account, so `Σ holdings.amount ≤ account.effectiveBalance`
   no longer holds and is deleted (`create_asset_holding_usecase.dart`,
   `compute_investment_overview.dart`).
2. **Holdings become derived, not stored.** A `Holding` is computed from
   `AssetTransaction`s (buy/sell/dividend) by a pure `HoldingCalculator`. There is
   no persisted holding row and no manual `amount`.
3. **`AssetClass` (allocation) survives.** Same concept both apps. Financo's entity
   is kept as-is, including **`icon:int` + `color:int`** (Investanco's
   `iconKey`/`colorValue` are mapped at port time). The asset→class link moves
   **onto the asset** (`metadata`), matching Investanco.
4. **`Money`/`Currency` (integer minor units, multi-currency) is adopted ONLY in
   the investing module.** The rest of Financo keeps `double` BRL. `formatCurrency`
   gains an additive `Money` overload — no transversal refactor of the ~15
   cash-side call-sites.
5. **Institution is a new sibling collection**, not an overload of `Account`.
6. **`AccountType.investment` is kept only for the 50/30/20 feature** (savings/aporte
   tag). It no longer hosts holdings; the account-delete → holdings cascade is
   removed.
7. **Existing `asset_holdings` data is discarded** on cutover (inconvertible — no
   ticker/quantity/price). Users re-enter positions via transactions / CSV import.
8. **Market data**: keyed sources (**brapi**, **Finnhub**) go through **Cloud
   Functions proxies** (keys become backend secrets); keyless sources (**CoinGecko,
   Tesouro Direto, BCB SGS, AwesomeAPI FX**) stay client-side via `dio`.
9. **Rollout is phased behind the `kInvestingV2` feature flag**; the old module and
   `asset_holdings` are removed in the final phase.
10. **Cost method**: weighted average (Investanco V1). FIFO out of scope.
11. **Base currency**: BRL, fixed. A currency switcher is deferred.

---

## 1. Reconciled conceptual model

```
Institution  1───∞  Asset  1───∞  AssetTransaction
  (custody)         (what)         (events: buy | sell | dividend)
   currency        currency               │
                      │                    ▼  derived, never stored
                      │              Holding (qty, avgCost, realizedPL, dividends)
                      │                    │
                      ▼                    ▼
             metadata.allocationClassId   Quote / FX / Index series
                      │                    │
                      ▼                    ▼
                 AssetClass ◄──── Valuation (marketValueNative → ×FX → marketValueBase)
                 (targets)              │
                                        ▼
                          PortfolioValuation (byClass / byCurrency / byInstitution)
                                        │
                                        ▼
                                Snapshot (daily total, base currency)
```

- **Institution** = where an asset is custodied (Nubank, Avenue, Wise). Carries a
  default `currency`.
- **Asset** = a tradable instrument (ticker + kind + market + native currency),
  belonging to one institution. Its `metadata` carries the allocation-class link and
  kind-specific data (fixed-income basis/rate, tesouro name, coingecko id).
- **AssetTransaction** = the source-of-truth event. `AssetTransaction` (not
  `Transaction`) to avoid clashing with Drift's generated class **and** Financo's
  cash-side `TransactionEntity`.
- **Holding** = derived value object, keyed by `(assetId, institutionId)`.
- **AssetClass** = allocation taxonomy with target %; UI is flat (parentId plumbing
  reserved).
- **Quote / FxRate / IndexPoint** = device-local market caches (not user data).
- **Valuation / Snapshot** = pure computation + daily history.

---

## 2. Core money contract (ported from Investanco `core/money/`)

```dart
enum Currency {
  brl('BRL', r'R$', 'pt_BR'),
  usd('USD', r'$', 'en_US'),
  eur('EUR', '€', 'de_DE');           // de_DE formats €1.234,56 — matches BR separators
  const Currency(this.code, this.symbol, this.locale);
  final String code; final String symbol; final String locale;
}

class Money extends Equatable {              // integer minor units — no double drift
  const Money(this.minorUnits, this.currency);
  factory Money.fromMajor(double major, Currency c) => Money((major*100).round(), c);
  const Money.zero(this.currency) : minorUnits = 0;
  final int minorUnits; final Currency currency;
  double get major => minorUnits / 100;
  Money operator +(Money o) // throws ArgumentError on currency mix (loud, release too)
  Money operator -(Money o) // same guard
  Money operator *(num factor) => Money((minorUnits*factor).round(), currency);
}
```

`Money + Money` across currencies **throws** — consolidation must go through FX
first (`marketValueNative × fxToBase → marketValueBase`). A dedicated
`formatMoney(Money)` uses `NumberFormat.currency(locale: m.currency.locale,
symbol: m.currency.symbol)`; the existing `formatCurrency(double)`→BRL stays for
the cash side. (Separate names, not an overload — Dart has no function
overloading.)

---

## 3. Entity contracts (overview — deep contracts live in per-feature specs)

Persisted investing entities add a **`userId`** field (Financo top-level +
`userId` convention; Investanco nested-under-user is not adopted).

### `Institution`  → `institutions/{id}`
| Field | Type | Invariant |
|---|---|---|
| id | String (uuid) | client-generated |
| userId | String | owner |
| name | String | non-empty, ≤60, unique per user (case-insensitive) |
| kind | `InstitutionKind` | `bank, broker, internationalBroker, crypto, other` (informational) |
| currency | `Currency` | default `brl` |
| createdAt | DateTime | |

Delete blocked while referenced by an asset/transaction → `InUseFailure`.

### `Asset`  → `investment_assets/{id}`
| Field | Type | Invariant |
|---|---|---|
| id | String (uuid) | |
| userId | String | |
| ticker | String | non-empty, uppercased; quote symbol |
| name | String | label |
| kind | `AssetKind` | `stockBr, fiiBr, etfBr, bdrBr, stockUs, etfUs, crypto, treasury, fixedIncome, fund, cash` |
| market | `Market` | `br, us, global` |
| currency | `Currency` | native quote currency (defaults from market) |
| institutionId | String | FK → Institution (required on save) |
| metadata | `Map<String,String>` | `allocationClassId`, `allocationTargetPercent`, `fiBasis`, `fiRate`, `tesouroName`, `coingeckoId`; default `{}` |
| createdAt | DateTime | |

`(ticker, market)` unique per user → `ValidationFailure(duplicateAsset)`. `cash`
kind = face-value balance (valued at cost, never stale). Form's Type picker exposes
`selectableKinds = {etfUs, crypto, fixedIncome, cash}`; all kinds still deserialize.

### `AssetTransaction`  → `investment_transactions/{id}`
| Field | Type | Invariant |
|---|---|---|
| id | String (uuid) | |
| userId | String | |
| institutionId | String | must equal the asset's institutionId |
| assetId | String | FK → Asset |
| kind | `TransactionKind` | `buy, sell, dividend` |
| quantity | double | >0 for buy/sell (fractional ok); ignored for dividend |
| unitPriceMinor | int | ≥0 (native currency minor units) |
| feesMinor | int | ≥0, default 0 |
| amountMinor | int | dividend: total received; else derived `quantity×unitPrice` |
| currency | `Currency` | the asset's native currency (one column, applied to the 3 money fields) |
| date | DateTime | not in the future |
| notes | String? | |
| createdAt / updatedAt | DateTime | audit |

Invariants (enforced in the repository so form **and** CSV are guarded): institution
matches asset (else `transactionInstitutionMismatch` / `assetInstitutionRequired`),
positive quantity for buy/sell (`nonPositiveQuantity`), no oversell at the
transaction's date over the whole re-validated timeline (`oversell`), no future date
(`futureTransactionDate`). Fixed income uses transactions as **dated cash flows**
(buy=aplicação, sell=resgate, `quantity=1` placeholder).

### `Holding` (derived, never persisted — see `holdings.md`)
Value object keyed by `(assetId, institutionId)`: `quantity` (Σbuys−Σsells),
`avgCost` (weighted, incl. fees), `realizedPL`, `dividends`, `isClosed`
(`|qty|<1e-9`). Re-buy after full close starts a fresh average. Produced by
`const HoldingCalculator().derive(transactions)`.

### `AssetClass` (kept from Financo V1)  → `asset_classes/{id}`
`id, userId, name, icon:int, color:int, targetPercent:double[0,100], parentId?,
createdAt`. Flat in UI. The asset→class link + per-asset target live on
`Asset.metadata`, **not** on separate subclass rows. Deleting a class → its assets
fall back to "não alocado".

### `Snapshot`  → `investment_snapshots/{id}`  (id = `${userId}_${yyyy-MM-dd}`)
`id, userId, date, totalValueMinor, totalInvestedMinor, totalPlMinor, currency`.
Idempotent per day (`insertOnConflictUpdate`); written at the end of a dashboard
refresh, **skipped** when no fresh-priced open position exists.

### Market caches (device-local, not mirrored, no `userId`)
`Quote(assetId, unitPriceMinor, previousCloseMinor?, currency, asOf, fetchedAt,
source)`, `FxRate(pair, rate, fetchedAt)`, `IndexPoint(index, date, rate)`.

---

## 4. Target persistence

### Firestore (top-level, scoped by `userId`)
| Collection | Origin | Note |
|---|---|---|
| `asset_classes/{id}` | Financo (kept) | — |
| `institutions/{id}` | new | — |
| `investment_assets/{id}` | Investanco `assets` | namespaced |
| `investment_transactions/{id}` | Investanco `transactions` | renamed — avoids collision with cash `transactions/{id}` |
| `investment_snapshots/{id}` | new | id `yyyy-MM-dd` |
| ~~`asset_holdings/{id}`~~ | **removed** | rules + data deleted |

Each doc: explicit `toFirestore()`/`fromFirestore()` + `userId` field via a
per-feature `RemoteDataSource` (Financo pattern) — **not** raw `row.toJson()` under
`users/{uid}/...` (Investanco pattern). Rules mirror the existing
`isAllowed() && ownsCreate()` / `ownsResource() || isMaster()` shape; access gate
stays `allowed_emails/{email}` (Investanco's hard-coded `_ownerEmails` const is
dropped).

### Drift — `schemaVersion 11 → 12` (disposable cache, drop-recreate on upgrade)
- **Add** (mirrored, carry `userId`): `Institutions`, `InvestmentAssets`,
  `InvestmentTransactions` (`unitPriceMinor/feesMinor/amountMinor` INT,
  `quantity` REAL, `metadata` TEXT default `{}`), `InvestmentSnapshots`. Keep
  `LocalAssetClasses`.
- **Add** (device-local caches): `Quotes`, `FxRates`, `IndexPoints`. `Settings`
  (single row, `baseCurrency`) — *investigate* whether a settings table already
  exists.
- **Remove**: `LocalAssetHoldings` + `AssetHoldingsDao` from `allTables`/DAOs.
- **New DAOs** (Financo requires DAOs; Investanco hit `_db` directly):
  `InstitutionsDao, InvestmentAssetsDao, InvestmentTransactionsDao,
  InvestmentSnapshotsDao, QuotesDao, FxRatesDao, IndexPointsDao`.

Confirmed: current `app_database.dart:44` → `schemaVersion => 11`.

---

## 5. Architecture integration

| Concern | Decision |
|---|---|
| **DI** | Extend the existing `get_it` ladder in `injection_container.dart` (External→DAOs→Datasources→Repos→UseCases→Cubits). Repos as `registerLazySingleton<Interface>`. The pricing engine is composed per-cubit, not registered. |
| **Routing / shell** | Keep Financo routes (`/investments`, `/investments/class/:id`) inside the `ShellRoute`; the session-scoped investing cubit plugs into the shell seam, `userId` resolved from `AuthBloc.state` at mount (CLAUDE.md lifecycle). Do **not** adopt Investanco's `/allocation` landing tab. |
| **Persistence model** | Firestore-primary (Financo): write-through per `RemoteDataSource` + authoritative full pull at sign-in; online-first; no push/tombstones. Investanco's `RemoteMirror` mechanics are dropped — the *philosophy* already matches. |
| **Market data** | Keyed sources (**brapi `BRAPI_TOKEN`**, **Finnhub `FINNHUB_TOKEN`**) behind **Cloud Functions** proxies in `functions/` (keys = backend secrets, out of the web bundle) — aligns with Gemini-via-Functions. Keyless (**CoinGecko, Tesouro Direto, BCB SGS, AwesomeAPI FX**) client-side via `dio` behind project-owned `QuoteDataSource`/`FxDataSource` interfaces. Handle Finnhub's serial 1-req/symbol + 60/min limit in the proxy/adapter. |
| **i18n** | Extend the `investments` namespace in `en.i18n.json` + `pt-BR.i18n.json`; `dart run slang`. |
| **Feature flag** | `kInvestingV2` gates the new module; the old `/investments` keeps serving until F7 flips it. |

---

## 6. Cross-feature wiring & migration

- **Model-A removal**: delete the balance-ceiling checks; market value lives in the
  new ledger, decoupled from `account_balance_calculator.dart`. Verify the
  dashboard and 50/30/20 (which today treat `investment` accounts like checking)
  still behave — 50/30/20 keeps using `AccountType.investment` purely as a
  savings/aporte tag.
- **Account-delete cascade**: `delete_account_with_dependents_usecase.dart` no
  longer deletes holdings (they're decoupled) — that call becomes a no-op/removed.
- **Data migration**: `asset_classes` preserved (same shape). `asset_holdings`
  discarded; communicate to the user to re-enter positions. Single-owner base →
  low impact.
- **Coexistence**: F0–F6 build the new module behind `kInvestingV2` in parallel;
  F7 flips the flag, deletes `lib/features/investments/` (V1) and the
  `asset_holdings` rules/table.

---

## 7. Phase map (detail in `docs/investanco-integration-plan.md` §6)

| Phase | Goal | Effort |
|---|---|---|
| **F0** | Scaffolding: port `core/money/`, `formatCurrency(Money)` overload, `dio`, `kInvestingV2`, bump schemaVersion 12, i18n namespace | S |
| **F1** | Data model + persistence: entities, `HoldingCalculator`, oversell, Drift tables+DAOs, `RemoteDataSource`+rules, remove `asset_holdings` | L |
| **F2** | Quotes/FX + valuation: proxies (brapi/Finnhub) + client adapters (CoinGecko/Tesouro/BCB/FX), caching, `ValuationService` (incl. fixed income) | L |
| **F3** | Buy/sell/dividend transaction form + CRUD | M |
| **F4** | Multi-currency net worth + daily snapshots | L |
| **F5** | Allocation/rebalance over market value | M |
| **F6** | CSV import (assets + transactions) | M |
| **F7** | Remove V1 module, flip flag, rewire cascade, rewrite `investments.md`→V2 | M |

Each phase writes its own `docs/specs/<feature>.md` **before** code (spec-driven).

---

## 8. Edge cases (umbrella-level; per-feature specs expand)

| Scenario | Behaviour |
|---|---|
| Foreign holding, no FX rate | Excluded from `totalValueBase`; kept in `holdings`; UI warns. Native subtotal (`byCurrency`) still shown. |
| Quote missing | Market value falls back to `investedBase`, `priceStale=true`, `unrealizedPL=0` (no fabricated gains). Exception: `cash` = face value, never stale. |
| Oversell (raw or backdated) | Blocked at the repository before write (`ValidationFailure(oversell)`); calculator clamps qty to 0 defensively. |
| Re-buy after full close | Fresh average cost (closed lot not blended). |
| Snapshot, app opened twice/day | Single row per `yyyy-MM-dd`, updated. |
| Class targets sum ≠ 100 | UI warns; never blocks. Save is blocked only if it pushes the sum **over** 100%+0.01. |
| Asset points at deleted class | Treated as "não alocado" (pending). |
| Currency mix in a sum | `Money +` throws — a real bug surfaces loudly, not silent corruption. |

---

## 9. Out of scope (V2)

- FIFO cost basis (weighted average only).
- Base-currency switcher (BRL fixed).
- Broker auto-import / login / scraping (public APIs only, manual + CSV).
- Real-time streaming quotes (cached + background refresh).
- AI-chat actions for investing entities (revisit after V2 lands).
- Per-institution snapshot breakdown (`byInstitutionJson` reserved, unwritten).
