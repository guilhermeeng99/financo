# Investing Account Unification (F8)

**Status:** Complete. Decisions B1 + automation + guided migration locked with
the user 2026-07-25 and shipped. **F8.6 closed it out**: the
`AccountType.investment` enum value is gone, and the guided migration feature
(`lib/features/data_migration/`, route `/migration`) was deleted with it once no
account of that type remained in Firestore. This
spec supersedes the relevant parts of `investing.md §0` (which deliberately
*decoupled* account and institution on 2026-07-22); F8 is a deliberate
re-reversal toward a single record.

---

## 1. Motivation

Today the app keeps **two disjoint ledgers** for the same real-world thing:

| | Accounts ledger (Dashboard) | Investing ledger (Portfolio) |
|---|---|---|
| Collection | `accounts` (`type=investment`) | `institutions` + `investment_assets/transactions` |
| "Avenue" is | a hand-kept **principal** balance | a market-valued **custody** record |
| Balance | `initialBalance` + transactions | `Σ qty × live quote × FX → BRL` |

"Avenue", "Nu Investimentos", "Cryptomoedas" exist **twice** — once as an
`AccountType.investment` account, once as an `Institution` — with **no link**
(`account_entity.dart` has no `institutionId`; `institution.dart` has no
`accountId`; verified no name-match, no balance sync). Consequences:

- Numbers never reconcile (≈R$227k principal vs ≈R$230k market value).
- Double data-entry: a purchase must be logged as a `buy` (investing) **and** a
  transfer checking→investment-account (for balance + 50/30/20).
- The Dashboard "Total Balance" is not a real net worth (excludes market value).

**Goal:** one record per broker, an auto-synced market-value balance on the
Dashboard, and single-entry purchases that also feed the 50/30/20 savings bucket.

---

## 2. Decisions

- **D1 — Merge direction: B1.** The `AccountType.investment` *account* is retired.
  The **`Institution`** becomes the single record ("investment account"). The
  `accounts` collection keeps only `checking` and `creditCard`. The valuation
  engine (entirely `institutionId`-based) is untouched.
- **D2 — Automation: yes.** A `buy` (and `sell`) may be *funded from* (paid to) a
  checking account; the app auto-creates the paired cash-flow transaction that
  moves BRL out of / into that account and is recognised as a 50/30/20 aporte
  (resgate).
- **D3 — Migration: guided.** Account↔institution matched by name; a preview diff
  is shown; the user approves before any write to production Firestore. Reversible.

### Open sub-decisions (recommended calls — confirm on review)

- **O1 — Cash parked at a broker** (money in the account, not yet invested):
  modelled as a `cash` holding (`AssetKind.cash` already exists and is
  authoritative-not-stale in valuation). *Recommended: yes* — so the institution
  balance = invested holdings + uninvested cash, matching reality.
  > **Not implemented (2026-07-31).** `RecordInstitutionCashFlowUseCase`, the
  > one-call path this decision needed, was **deleted** in the 2026-07-31 audit
  > because it had zero callers: nothing in the form, the CSV importer or the
  > chat ever invoked it, so it was untested dead weight sitting on the money
  > path. The pieces it was built from all survive — `AssetKind.cash` is in
  > `selectableKinds`, valuation treats it as face-value-never-stale, and
  > `SyncInvestmentCashFlowUseCase` writes the checking-side row for any funded
  > buy/sell. **Today the user gets O1 by hand**: create a `cash` asset at the
  > institution and record a `buy` against it with a funding account; the aporte
  > row and the 50/30/20 credit follow automatically.
  >
  > *To bring it back*: reintroduce a use case that (a) finds-or-creates the
  > per-currency `cash` asset for an institution, (b) builds a `buy`/`sell`
  > `AssetTransaction` against it with `fundingAccountId` set, and (c) delegates
  > to `SaveAssetTransactionUseCase` — which already routes through
  > `SyncInvestmentCashFlowUseCase`, so step (c) needs no new money logic. Wire
  > it to a real entry point (a "deposit cash" action on the institution detail
  > page) **in the same change**, or it will be dead again.
- **O2 — Aporte amount / FX.** A USD buy debits BRL from checking. The BRL amount
  actually left the account, so it is authoritative for 50/30/20. *Recommended:*
  user enters the **BRL debited** (default computed via the day's FX, editable);
  store both the native buy amount and the BRL cash amount.
- **O3 — Old principal seed.** The retired investment account's `initialBalance`
  seed (e.g. Avenue R$117,663.79) is **not** carried as a balance (market value
  replaces it). Its historical aporte **transactions** are preserved and repointed
  (see §6). *Recommended: drop the seed; keep the transaction history.*
- **O4 — Dashboard display.** Investment rows show **market value (BRL)** as the
  headline. *Recommended:* a secondary line shows "aportado" (cost basis /
  `totalInvestedBase` for that institution) so the user still sees principal.

---

## 3. Entity contracts

### 3.1 `Institution` (now = "investment account")

Existing fields (`lib/features/investing/domain/entities/institution.dart`):
`id, userId, name, kind (bank|broker|internationalBroker|crypto|other), currency, createdAt`.

**Added for Dashboard parity:**

| Field | Type | Invariant |
|---|---|---|
| `bank` | `BankType?` | Optional logo/avatar hint; reuses the accounts `BankType` enum (already includes `avenue`, Nubank, etc.). Null → initials avatar. |
| `color` | `int?` | Optional display colour; falls back to a deterministic colour from `kind`. |

`kind` and `currency` are unchanged. No holdings/value fields are stored on the
institution — value is always **derived** from `PortfolioValuation.byInstitution`.

### 3.2 `AccountEntity`

- `AccountType` is `{ checking, creditCard }`. `investment` was retained through
  the migration so legacy docs kept deserializing, then removed in F8.6 along
  with its pill in `add_account_page.dart`. A stored `"investment"` now degrades
  to `checking` via `enumByName`.
- No other field changes. `linkedAccountId` (credit-card → paying checking) is
  unaffected.

### 3.3 `TransactionEntity` — investment cash-flow link

A transaction may represent cash moving between a **checking account** and an
**institution** (aporte on buy, resgate on sell). Added fields:

| Field | Type | Meaning |
|---|---|---|
| `institutionId` | `String?` | Set when this cash flow funds/receives from an institution. Marks it as an investment aporte/resgate. |
| `linkedInvestmentTransactionId` | `String?` | The `investment_transactions` doc (buy/sell) that generated this row. Drives linked lifecycle. |

- An **aporte** = `type=expense`, `accountId=<checking>`, `institutionId=<broker>`,
  `linkedInvestmentTransactionId=<buy>`.
- A **resgate** = `type=income`, `accountId=<checking>`, `institutionId=<broker>`,
  `linkedInvestmentTransactionId=<sell>`.
- These are **not** account↔account transfers (`linkedTransactionId` stays null);
  the counterparty is an institution, not a second account.

### 3.4 `AssetTransaction` — funding link

| Field | Type | Meaning |
|---|---|---|
| `fundingAccountId` | `String?` | Checking account the cash came from (buy) / went to (sell). Null → cash already at broker (no aporte generated; see O1). |
| `cashAmount` | `Money?` (BRL) | The BRL that actually moved (O2). Null when `fundingAccountId` is null. |

---

## 4. Business rules (numbered, testable)

1. **One record per broker.** After cutover, "Avenue" exists only as an
   `Institution`. No `accounts` doc has `type=investment`.
2. **Investment balance = market value.** The Dashboard value for an institution
   equals `PortfolioValuation.byInstitution[id].marketValueBase` (BRL,
   FX-consolidated), cache-first, refreshed with live quotes. When a quote/FX is
   unavailable it falls back to cost basis flagged stale (existing valuation behaviour).
3. **Dashboard Total Balance = true net worth.** `Total = Σ(non-muted checking
   balances) + Σ(non-muted institution market values)`. Credit cards remain in
   their own section.
4. **Single-entry purchase.** Creating a `buy` with `fundingAccountId=A` and
   `cashAmount=C` atomically creates: (a) the `investment_transaction` (buy), and
   (b) one `transactions` row (expense, `accountId=A`, `amount=C`,
   `institutionId=<broker>`, `linkedInvestmentTransactionId=<buy>`).
5. **Single-entry sale.** A `sell` with a payout account creates an income
   `transactions` row symmetrically (resgate).
6. **Linked lifecycle.** Editing/deleting a buy/sell updates/deletes its generated
   cash-flow row. Deleting the cash-flow row alone is disallowed (edit via the
   investing transaction).
7. **50/30/20 savings = aporte flow.** Savings bucket spend for the month =
   `Σ aporte.amount − Σ resgate.amount` (i.e. `transactions` where
   `institutionId != null`, expense adds, income subtracts), clamped ≥ 0. This
   replaces the old "checking→investment-account transfer" detection in
   `_netSavingsFlow` (`compute_fifty_thirty_twenty.dart`).
8. **Optional funding.** A buy/sell with `fundingAccountId=null` generates no
   cash-flow row (cash already at the broker / external). It still affects
   holdings and market value, but not 50/30/20 or any checking balance.
9. **Currency.** The institution's `currency` is display/native. A **foreign**
   institution (e.g. Avenue in US$) renders its Dashboard amount like a foreign
   cash account: the native figure (`marketValueNative`, from `byCurrency`) on
   top with a `≈ R$` estimate below; the `≈ R$` line is omitted when no FX rate
   consolidated the value (so it shows the real US$ instead of R$ 0). A BRL
   institution shows a single R$ figure. The consolidated **BRL** `marketValue`
   is what still feeds the Total. Every institution row carries an "Investment"
   tag (not the currency code — that moved to the amount column).
10. **No investment account creation.** The add-account form offers only
    `checking`/`creditCard` — since F8.6 those are the only types there are.
    Brokers are created in the investing Institutions UI.
11. **Market values warm at startup.** `InstitutionValuationReader` prices
    cache-only (no network), so its figures are only correct once the shared
    market-quote cache is warm — and only `InvestingOverviewCubit.load()`'s
    network refresh warms it. Therefore the overview provider is eager
    (`lazy: false` in `app_router.dart`) so that refresh runs at app start, and
    the Dashboard re-reads once it settles (listenWhen `investingRefreshSettled`
    — `isRefreshing` true→false — in `dashboard_page.dart`). Result: institution
    market values are correct on first paint without visiting the Investing tab.
    The Portfolio app bar also exposes a manual refresh (`load(force: true)`),
    covering the empty/error states and web, where pull-to-refresh isn't
    available.

---

## 5. Repository / cubit contracts

- **`InstitutionRepository`** — gains `bank`/`color` in create/update. Unchanged CRUD.
- **`SyncInvestmentCashFlowUseCase`** (`investing/domain/usecases/`) — owns the
  paired `transactions` row. Given an `AssetTransaction` it derives the row that
  transaction *should* have and makes reality match: create, update, delete when
  the funding account is cleared, delete when the investing row is deleted
  (`investingDeleted: true`), and drop duplicates. `SaveAssetTransactionUseCase`
  and `DeleteAssetTransactionUseCase` both route through it, so **any** writer
  that carries a `fundingAccountId` gets the behaviour for free — today that is
  only the transaction form (see the F8.4 note in §7). The two writes are not
  one batch (they target different collections); a failed cash row rolls back a
  newly created investing row, but not an edited one — see
  `investing_transactions.md` rule 12.
- ~~**`RecordInstitutionCashFlowUseCase`**~~ — **deleted 2026-07-31** (zero
  callers). It was the O1 "cash parked at a broker" entry point; see the O1 note
  in §2 for the manual workaround and how to reinstate it.
- **`AccountRepository`** — no longer returns `investment` accounts post-migration.
- **`DashboardRepositoryImpl.getDashboardSummary`** — gains an investing input:
  it must obtain `byInstitution` market values (from the latest snapshot / a shared
  valuation read) and emit institution rows alongside checking balances. *This is
  the one place the two features are intentionally joined.* Contract: inject a
  read-only `InstitutionValuationReader` (institution id → `marketValueBase`,
  `investedBase`, currency, stale flag) so the dashboard does not depend on the
  full investing cubit.
- **`compute50_30_20Overview`** — `_netSavingsFlow` reads `institutionId`-tagged
  cash flows instead of pairing transfers by account type.

### State machines
- `DashboardBloc` — same states; summary now includes institution rows. Also
  reloads (plain `DashboardLoadRequested`) on the investing overview
  refresh-settle edge so the warmed market values surface on first paint.
- `InvestingTransactionFormPage` — a "Cash movement" section on buy/sell only:
  an optional checking-account picker (its first entry clears the choice) and a
  BRL amount whose hint is `quantity × unitPrice`, so a BRL asset needs no typing
  and a foreign one can state the reais actually debited (O2). Dividends hide the
  section (`investing_transactions.md` rule 11). Credit cards are excluded from
  the picker — they have no cash to move.
- `InvestingOverviewCubit` — unchanged valuation; the buy/sell forms gain the
  funding-account picker + BRL amount field. Eager-loaded at shell mount
  (`lazy: false`) to warm the market-quote cache at startup; the Portfolio app
  bar exposes a manual `load(force: true)` refresh.
- `AccountsCubit` — no longer lists investment accounts.

---

## 6. Migration (guided, F8-M)

> **Done and removed.** This shipped as `lib/features/data_migration/` (route
> `/migration`), a plan-then-apply screen that also carried F9.6. Once no
> account of type `investment` remained in Firestore, F8.6 deleted the feature
> and its spec — a one-shot migration with nothing left to migrate is dead
> code, and keeping it blocked removing the enum value it was built around.
> The steps below are the original *intent*, kept as the record of what the
> data went through. Two deliberate departures from this list: step 1's JSON
> backup was never automated (the executor had no rollback; a partial run was
> finished by re-opening the page), and step 5's cutover flag never existed
> (the unified model was never gated). `git log -- lib/features/data_migration`
> has the implementation if a similar rewrite is ever needed.

Applied to the user's **production** Firestore, one reversible step at a time,
each previewed and approved:

1. **Snapshot/backup** the `accounts`, `institutions`, `transactions` docs touched
   (export to a dated JSON in the repo/scratchpad for rollback).
2. **Match** each `type=investment` account to an institution by normalised name
   (Avenue↔Avenue, Nu Investimentos↔Nu, Cryptomoedas↔crypto). Show the proposed
   mapping; the user confirms/edits. Unmatched on either side is reported, not guessed.
3. For each matched pair:
   - **Repoint aporte history.** Transfer transactions whose destination was the
     investment account are converted to institution-tagged aportes
     (`institutionId=<broker>`, `linkedTransactionId` cleared). This preserves
     50/30/20 history.
   - **Copy display hints** (`bank`, `color`) from the account onto the institution.
   - **Retire the account.** Delete the `accounts` doc (its `initialBalance` seed is
     dropped per O3; market value replaces it).
4. **Verify** Dashboard total = cash + market value, and 50/30/20 history intact.
5. Cutover flag flips the UI to the unified model.

Rollback = restore the backed-up docs.

---

## 7. Phased rollout

- **F8.1** — Entity/schema additions (Institution `bank`/`color`; Transaction
  `institutionId`/`linkedInvestmentTransactionId`; AssetTransaction
  `fundingAccountId`/`cashAmount`). Drift + Firestore models + build_runner. No behaviour change.
- **F8.2** — Dashboard reads institution market values; investment rows rendered
  from institutions; Total Balance = net worth. (Old investment accounts still exist.)
- **F8.3** — 50/30/20 switches to `institutionId` aporte flow (dual-read during transition).
- **F8.4** — Automation: funding-account picker + BRL amount on buy/sell forms;
  paired cash-flow write + linked lifecycle. *(Shipped in two parts: the entity
  fields and `RecordInstitutionCashFlowUseCase` landed first, but nothing wrote
  the paired row for a plain buy/sell and the form had no picker — a funded sale
  was unreachable from the UI. Completed 2026-07-31 by
  `SyncInvestmentCashFlowUseCase` + the form's Cash-movement section; the unused
  `RecordInstitutionCashFlowUseCase` was deleted in the same pass.)*

  **Chat and CSV are *not* updated** (an earlier draft of this row claimed they
  were). Verified 2026-07-31:
  - `ImportInvestingTransactionsCsvUseCase` never sets `fundingAccountId` — the
    CSV format has no funding column, so an imported buy is always "cash already
    at the broker" (rule 8) and generates no aporte. `SyncInvestmentCashFlowUseCase`
    short-circuits that path without a ledger read (`wanted == null &&
    id.isEmpty`), so it costs nothing, but the 50/30/20 savings bucket does not
    see imported purchases.
  - `lib/features/chat/` has **no investing action at all** — the AI proposes
    transactions, transfers, accounts and categories only. This matches
    `investing.md` §9 ("AI-chat actions for investing entities" is out of scope
    for V2); the F8.4 row was simply wrong. Tracked in `TODO.md`.
- **F8.5** — Guided migration (F8-M) on real data. Shipped as an in-app,
  plan-then-apply screen at `/migration`; see §6.
- **F8.6** — **Done.** Removed `AccountType.investment` and everything built on
  it: the type pill and its hint in `add_account_page`, the investments section
  of `accounts_page`, the pill/label branches in `account_card`,
  `dashboard_account_row` and `transaction_account_picker_sheet`, the two
  payables account filters, the `_delta` branch in
  `account_balance_calculator`, the transfer-pairing leg of `_netSavingsFlow`
  (and with it the `accounts` parameter of `compute50_30_20Overview`), the
  now-callerless `TransactionEntity.asInstitutionCashFlow`, the four orphaned
  `accounts.investment*` i18n keys, and the whole `data_migration` feature.

Each phase: `dart run build_runner build` / `dart run slang` as needed,
`flutter analyze` zero issues, `flutter test` green, regression tests for money paths.

---

## 8. Edge cases

- Checking/credit accounts and their transfers: unaffected.
- Buy funded from checking in a **different** currency: `cashAmount` is BRL; the
  buy native amount is the broker currency; FX at date (O2).
- Sell partial / oversell guard: existing investing rules apply; resgate cash =
  proceeds actually received.
- Delete a checking account that has aporte history: aportes reference an
  institution, not the deleted account's balance — handle like any account-delete
  (transactions cascade per existing rules).
- Institution with zero holdings and no cash: Dashboard value R$0 (still listed).
- Muting an institution on the Dashboard (existing per-account checkbox) excludes
  it from Total, same as accounts.
- Legacy `asset_holdings` / V1: already retired in F7; not revisited.

---

## 9. Testing

- Regression: 50/30/20 savings equals aporte flow for a known transaction set.
- Buy-with-funding creates exactly one paired transaction with correct signs/links;
  edit/delete cascades; funding-null creates none.
- Dashboard Total = Σcash + Σinstitution market value (mocked valuation reader).
- Migration: given N investment accounts + institutions, mapping preview is correct;
  applied migration preserves aporte totals and deletes the right accounts.
