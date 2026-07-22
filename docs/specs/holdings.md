# Spec: Holdings (investing V2)

> Part of the V2 investing module (`docs/specs/investing.md`).

A **derived** view: the net position of one asset at one institution — quantity
and weighted average cost — computed from its transactions. Never stored; a pure
value object recomputed on demand.

## Derived contract

`Holding` (`lib/features/investing/domain/entities/holding.dart`) — value object,
no `id`, no `userId`:

| Field | Type | Derivation |
|---|---|---|
| `assetId` | String | group key |
| `institutionId` | String | group key |
| `quantity` | double | Σ buys − Σ sells (clamped ≥ 0) |
| `avgCost` | Money (native) | weighted average incl. fees |
| `realizedPL` | Money | Σ realized gains/losses from sells (minus fees) |
| `dividends` | Money | Σ dividend amounts |

Getters: `investedCost = avgCost * quantity`; `isClosed = |quantity| < 1e-9`.

## Service — `HoldingCalculator` (pure, const)

`lib/features/investing/domain/services/holding_calculator.dart`. Groups the
transaction list by `(assetId, institutionId)` and derives one `Holding` each,
replaying oldest-first (`compareTransactionsOldestFirst`).

Per transaction (all math in integer minor units):
- **buy**: `newQty = qty + tx.qty`;
  `avgCost = (avgCost*qty + tx.unitPrice*tx.qty + tx.fees) / newQty`; `qty = newQty`.
- **sell**: `realized += (tx.unitPrice − avgCost) * tx.qty − tx.fees`;
  `qty -= tx.qty` (clamped ≥ 0). `avgCost` is unchanged by a sell.
- **dividend**: `dividends += tx.amount`.

## Business rules

1. Positions with `isClosed` (`|quantity| < 1e-9`) are **closed** — excluded from
   current allocation but retained for realized-P/L history.
2. Weighted-average cost (FIFO out of scope V1, umbrella §0.10).
3. Keyed by `(assetId, institutionId)` — the same asset at two institutions is two
   holdings (aggregated by asset in the dashboard when needed).
4. Recomputation is pure and deterministic given the ordered transaction list.

## Edge cases (all covered by `holding_calculator_test.dart`)

- Sell to exactly zero → closed; `avgCost` retained for the realized record.
- Dividends on a closed holding → counted; holding stays closed.
- Out-of-order dates → calculator sorts before replaying.
- Fractional quantities (US/crypto) → supported (`double`).
- Raw oversell (Σ sells > Σ buys) → quantity clamped to 0 (defensive; the
  repository blocks oversell before any write — `investing_transactions.md` rule 3).
- Re-buy after a full close → fresh average cost (the closed lot's cost is not
  blended into the new position).
