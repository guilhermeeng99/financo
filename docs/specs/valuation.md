# Spec: Valuation (investing V2)

> Part of the V2 investing module (`docs/specs/investing.md`). Pure, deterministic
> math — no IO. Ported from Investanco; fully unit-tested.

Turns holdings + quotes + FX + indices into money figures: current value, P/L,
returns, all consolidated to the base currency (BRL). Lives in
`lib/features/investing/domain/services/valuation_service.dart`.

## Inputs / output

`ValuationInput`: `holding` (derived), `asset`, `quote?` (null when unavailable),
`fxToBase` (`double?` — 1.0 when same currency; **null** = FX unavailable for a
foreign holding → excluded from totals, never valued 1:1), `fixedIncome?`
(`FixedIncomeTerms`, used only when `quote == null`).

`HoldingValuation`: `assetId, institutionId, assetKind, quantity,
marketValueBase, marketValueNative, investedBase, unrealizedPL, totalPL,
returnPct, dayChangeBase, priceStale, fxMissing`.

`PortfolioValuation`: `totalValueBase, totalInvestedBase, totalUnrealizedPL,
totalDayChangeBase, totalReturnPct, byClass (Map<AssetKind,Money>), byInstitution
(Map<String,Money>), byCurrency (Map<Currency,Money>), holdings`. Built by
`PortfolioValuation.fromHoldings(list, base)`; `forInstitution(id?)` re-aggregates
a subset for the dashboard filter.

## Rules

1. **Market value (native)** = `quantity * quote.unitPrice`.
2. **Fixed income** (no market quote): valued from dated **cash flows** — a buy is
   a deposit (aplicação, +), a sell a redemption (resgate, −). By linearity of
   daily accrual, `currentValue = Σ amount × accrualFactor(flow.date → now)` and
   `invested = Σ amount`; both from the flows, not the average-cost model — so
   partial redemptions value correctly and `totalPL = unrealizedPL` (no double
   count). `ratePercent`: CDI/Selic → percent **of** the index (110 = 110% of
   CDI); prefixed → annual rate; IPCA+ → annual spread.
   - CDI/Selic: `∏(1 + (dailyRate/100) × (ratePercent/100))` over series days ≥ flow.
   - Prefixed: `(1 + ratePercent/100)^(businessDays/252)`.
   - IPCA+: `(∏(1 + ipca_m/100)) × (1 + ratePercent/100)^(businessDays/252)`.
   `businessDays` counts weekdays since the flow date (bank holidays ignored — the
   BCB series already excludes them for index bonds; only prefixed/IPCA+ affected).
   Falls back to cost + `priceStale` only when `fixedIncome` is absent/empty.
3. **Base conversion**: `valueBase = valueNative × fxToBase` (1.0 when same
   currency). Each holding's `fxToBase` is its **own** currency's rate into base
   (a USD and a EUR holding use different rates); a null rate → excluded, flagged
   `fxMissing`.
4. **Unrealized P/L** = `marketValueBase − investedBase`.
5. **Return %** = `unrealizedPL / investedBase`; `0.0` when `investedBase == 0`.
6. **Total P/L** = `unrealizedPL + realizedPL(base) + dividends(base)`.
7. **Day change** = `(unitPrice − previousClose) × quantity × fxToBase`; `0` when
   `previousClose` is null.
8. **Stale** = quote null OR `now − quote.fetchedAt > staleThreshold` (1 h).

## Aggregation

`PortfolioValuation.fromHoldings` sums base totals + `byClass`/`byInstitution`
over non-`fxMissing` holdings; `byCurrency` sums each holding's
`marketValueNative` by its own currency (**includes** fxMissing holdings — the
native subtotal needs no FX). The full `holdings` list is always retained so the
UI can list excluded ones with a warning.

## Edge cases (covered by `valuation_service_test.dart`)

| Scenario | Behaviour |
|---|---|
| Missing quote (non-cash) | Market value = `investedBase`, `priceStale = true`, `unrealizedPL = 0` (no fabricated gains). |
| `cash` kind | Face value (cost basis) *is* the current value → `priceStale = false`, counts toward totals. |
| Missing FX (foreign) | Excluded from `totalValueBase`; kept in `holdings`; native subtotal in `byCurrency`. |
| Fixed income CDI accrual | `Σ amount × ∏(1 + dailyCdi × pct)`. |
| Old quote | `priceStale = true`. |
| `investedBase == 0` | `returnPct = 0` (no div-by-zero). |

## Metadata

`FixedIncomeMetadata` (`domain/services/fixed_income_metadata.dart`) reads/writes
`fiBasis` + `fiRate` on `Asset.metadata`, centralizing the key names so the asset
form (writer) and the valuation (reader) never drift.

## Overview (net worth) — F4

`InvestingOverviewCubit` owns a per-cubit `PortfolioPricingEngine` and prices the
portfolio cache-first then network-refreshes (same warm-start → priceFromCache →
refreshNetwork → re-price flow the engine documents). `InvestingOverviewPage`
renders the base-currency net worth, invested + unrealized P/L, `byCurrency`
subtotals (shown only when >1 currency), a per-holding list (stale / fx-missing
badges), and the history sparkline.

## Snapshots (net-worth history) — F4

A `Snapshot` is the portfolio consolidated to base on a calendar day
(`totalValue`, `totalInvested`, `unrealizedPL` — all base). One per user per day,
**idempotent**: Firestore doc id is the deterministic `"${userId}_${dayKey}"`
(`dayKey = yyyy-MM-dd`) written via `set()`, so re-recording a day overwrites
rather than appending (a deliberate exception to the auto-id convention — daily
idempotency requires a deterministic key). Mirrored + cached in the
`investment_snapshots` Drift table (schema 15) as integer minor units + a base
`currency`.

`RecordDailySnapshotUseCase` runs at the end of every overview refresh from the
already-priced portfolio; a zero-value **and** zero-invested portfolio is skipped
so an empty/loading portfolio never writes a misleading flat line. Snapshots are
read back via `GetSnapshotsUseCase` (cache-first; `forceRefresh` pulls remote).
