# Spec: Asset Transactions (investing V2)

> Part of the V2 investing module (`docs/specs/investing.md`). Entity field table
> lives in the umbrella §3; this spec adds rules, repository, ordering and edges.

The events that build a position: buys, sells, dividends. **Source of truth** —
holdings are derived from them (`holdings.md`). The entity is `AssetTransaction`
(not `Transaction`) to avoid clashing with Drift's generated `Transaction` **and**
Financo's cash-side `TransactionEntity`.

## Entity

`AssetTransaction` (`lib/features/investing/domain/entities/asset_transaction.dart`):
`id, userId, institutionId, assetId, kind (TransactionKind), quantity (double),
unitPrice (Money), fees (Money), amount (Money), date, notes?,
fundingAccountId?, cashAmount?, createdAt, updatedAt`. Persisted as
`unitPriceMinor/feesMinor/amountMinor` INT + one `currency` column (umbrella
§3, §4). `TransactionKind = {buy, sell, dividend}`.

- `fundingAccountId?` (String) — the checking account the cash came from (buy)
  / went to (sell). When set, the app auto-manages a paired cash-flow
  `transactions` row so the purchase is a single entry that also feeds the
  50/30/20 savings bucket (F8 — see
  [investing_account_unification.md](investing_account_unification.md) §4). Null
  → cash already at the broker / external; no cash-flow row is generated.
- `cashAmount?` (Money) — the amount that actually moved on the checking side,
  always **BRL** (F8 O2: a USD buy debits BRL from checking; the native
  `amount` may be USD, this is the reais debited/credited). Persisted as
  `cashAmountMinor`; non-null only alongside `fundingAccountId`.

## Ordering (single source, shared by calculator + guard)

`compareTransactionsOldestFirst` orders by `date`, then `createdAt`, then
`transactionKindRank` (buy 0 < dividend 1 < sell 2). This one comparator is used
by both `HoldingCalculator` and `oversellsTimeline`, so a same-instant deposit
covers its redemption and the guard and holding math can never disagree.

## Business rules

1. The transaction's `institutionId` must equal the asset's `institutionId` → else
   `ValidationFailure(transactionInstitutionMismatch)`. If the asset has no
   institution yet → `ValidationFailure(assetInstitutionRequired)`.
2. `buy`/`sell` require `quantity > 0` → `ValidationFailure(nonPositiveQuantity)`;
   `unitPrice ≥ 0`. Enforced in the repository (form + CSV both guarded).
3. A `sell` cannot exceed the quantity held **at its date** →
   `ValidationFailure(oversell)`. `oversellsTimeline` re-runs the whole
   (asset, institution) position, so a backdated buy/edit that strands a later
   sell is caught too.
4. `dividend` carries `amount` only; does not change quantity
   (`resolveTransactionAmounts` zeroes quantity + unit price).
5. `date` cannot be in the future → `ValidationFailure(futureTransactionDate)`.
6. Editing/deleting a transaction re-derives the affected holding.
7. Native currency is the **asset's** currency; consolidation to BRL happens at
   valuation time, not storage time.
8. **Fixed income** uses transactions as dated cash flows: `buy` = aplicação,
   `sell` = resgate, `quantity = 1` placeholder, `unitPrice = amount`. The
   valuation reads each transaction's `amount` + `date` as a cash flow
   (`valuation.md`), so partial redemptions value correctly and `quantity = 1`
   keeps the oversell guard from blocking a resgate that includes accrued yield.

## Repository contract

```dart
abstract class TransactionRepository {
  Future<Either<Failure, List<AssetTransaction>>> getTransactions({
    required String userId,
    bool forceRefresh = false,
  });
  Future<Either<Failure, AssetTransaction>> saveTransaction(AssetTransaction tx);
  Future<Either<Failure, void>> deleteTransaction(String id);
}
```

Firestore-primary + Drift cache. Collection `investment_transactions/{id}` (renamed
from Investanco's `transactions` to avoid colliding with Financo's cash
`transactions/{id}`), scoped by `userId`. Rules 1, 2, 3, 5 run in the repository
impl **before any write** (the CSV import sorts oldest-first so a valid file's sells
follow their covering buys).

## State machine

`TransactionsCubit` (F3) merges transactions + assets + institutions so the list
can render labels; optional `institutionFilter`. Form validates locally and calls
save/delete which surface `Failure?`.

## Edge cases

| Scenario | Behaviour |
|---|---|
| Oversell (sell > held at date) | `ValidationFailure(oversell)`. |
| Backdated buy that invalidates a later sell | Blocked (full timeline re-validated). |
| Zero-fee, zero-price (bonus shares) | Allowed. |
| Dividend | quantity 0, no unit price; only `amount` counts. |
