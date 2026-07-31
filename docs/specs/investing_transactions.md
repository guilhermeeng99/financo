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
   `unitPrice ≥ 0`. Enforced in `SaveAssetTransactionUseCase`, which both the
   form and the CSV importer go through.
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
9. **Funded buy/sell (F8.4).** When `fundingAccountId` is set, saving the
   transaction also reconciles one paired cash row on that account —
   `SyncInvestmentCashFlowUseCase`, called by both save and delete. Expense for
   a `buy` (aporte), income for a `sell` (resgate), amount = `cashAmount ??
   amount`, `institutionId` = the asset's institution,
   `linkedInvestmentTransactionId` = this transaction. Description = `notes`,
   falling back to `Aporte`/`Resgate`.
10. **Reconcile, not insert.** The same call covers every edit: changing the
    amount/account/date updates the existing row, clearing the account deletes
    it, deleting the investing transaction deletes it, and stray duplicates from
    a partial failure are dropped so "one cash row per investing transaction"
    self-heals instead of double-counting the aporte.
11. **Dividends are never paired.** A dividend is yield credited at the broker,
    not cash crossing between the two ledgers; tagging one would wrongly shrink
    the month's savings bucket. The form hides the funding picker for them.
12. **Partial-write policy.** If the cash row fails on a *create*, the investing
    row is rolled back (a half-landed aporte is worse than none). On an *edit*
    it is kept and the failure surfaced — the previous values are already gone,
    and the next save reconciles again.

## Repository contract

```dart
// lib/features/investing/domain/repositories/asset_transaction_repository.dart
// Named AssetTransactionRepository — Financo's cash side already owns
// `TransactionRepository`, and both are injected into the same use cases.
abstract class AssetTransactionRepository {
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
`transactions/{id}`), scoped by `userId`.

**Where the rules run.** Rules 1, 2, 3, 5 are enforced by
**`SaveAssetTransactionUseCase`** (`investing/domain/usecases/`), not by the
repository impl — the repository is a plain persistence seam. Both writers (the
form and the CSV importer) go through the use case, so both are guarded; the
oversell check in particular needs a second repository (`AssetRepository`, to
resolve the asset's institution) plus a full re-read of the position timeline,
which a repository impl has no business owning. The CSV import additionally
sorts oldest-first so a valid file's sells follow their covering buys.

> The dartdoc on `AssetTransactionRepository.saveTransaction` still claims it
> "Enforces the institution-match, non-positive-quantity, oversell and
> future-date rules before writing". That comment is stale — it does not.
> Tracked in `TODO.md`.

## State machine

`InvestingTransactionsCubit`
(`presentation/cubit/investing_transactions_cubit.dart`, F3) merges transactions
+ assets + institutions so the list can render labels; optional
`institutionFilter`. `InvestingTransactionFormPage` validates locally and calls
`SaveAssetTransactionUseCase` / `DeleteAssetTransactionUseCase`, surfacing the
`Failure` through `localizedFailure` in a snackbar.

**Cash-movement section (F8.4).** On `buy`/`sell` only (`_supportsFunding`), the
form shows an optional funding-account picker (`showFundingAccountPicker` — its
first row clears the choice, returning `''` to distinguish "cleared" from
"dismissed") plus a BRL amount field. The amount defaults to the transaction's
own `amount` when left blank, which is already correct for a BRL asset; a
foreign asset needs the field because the debit is in reais (F8 O2). Clearing
the account nulls both `fundingAccountId` and `cashAmount`, which deletes the
paired row on the next save (rule 10).

## Edge cases

| Scenario | Behaviour |
|---|---|
| Oversell (sell > held at date) | `ValidationFailure(oversell)`. |
| Backdated buy that invalidates a later sell | Blocked (full timeline re-validated). |
| Zero-fee, zero-price (bonus shares) | Allowed. |
| Dividend | quantity 0, no unit price; only `amount` counts. |
