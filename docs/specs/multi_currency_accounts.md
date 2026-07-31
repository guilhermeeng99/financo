# Multi-Currency Accounts (F9)

**Status:** Implemented. Direction confirmed with the user 2026-07-25 and
shipped: accounts can be denominated in different currencies (one currency per
account), amounts stored **native**, and a consolidated **BRL estimate** computed
at the **current** FX rate. Distinct from F8 (investing unification); Wise is a
foreign-currency *spending* account, not an investing institution.

---

## 1. Motivation

The user operates in more than one currency: EUR while travelling, BRL at home,
via a Wise account they **spend from** (groceries, purchases) in the foreign
currency. Today `accounts` are BRL-only (`initialBalance: double`, no currency),
so a Wise EUR account can't be modelled as what it is — a checking account in
euros. (It was mis-set-up as an investing *institution*, which has no categories,
spending, or 50/30/20 — see `investing_account_unification.md`.)

Goal: hold accounts in different currencies, record spending in each account's
own currency, and view balances/totals **either** natively per account **or**
consolidated into a single BRL estimate.

### Key simplification
The consolidated BRL view is an **estimate at the current FX rate** — the user
explicitly asked for "de forma estimada, convertendo tudo para real". So amounts
are stored **native** and converted to BRL only for display/aggregation, using
the latest FX rate. No per-transaction historical rate is stored. Exact native
figures are never lossy; only the BRL roll-up is an estimate.

---

## 2. Decisions

- **D1 — One currency per account.** Each account has a single `currency`
  (BRL/USD/EUR). A person using both EUR and USD at Wise keeps two accounts
  (Wise EUR, Wise USD). No per-account multi-balance. (User-confirmed.)
- **D2 — Native storage, current-FX consolidation.** `initialBalance` and every
  transaction `amount` are in the account's currency. The BRL-consolidated total
  is `Σ nativeBalance(account) × fx(account.currency → BRL)` at the current rate.
- **D3 — FX source reuse.** Reuse the investing FX stack (AwesomeAPI via
  `FxDataSource` + `CachingFxDataSource`, warm-started from the durable cache).
  No new FX integration.
- **D4 — Cross-currency transfer captures the received amount.** A BRL→Wise-EUR
  transfer stores −R$X on the BRL leg and +€Y on the EUR leg, where Y is the
  euros actually received (user-entered, defaulted from current FX). This is the
  one place a specific conversion is recorded (as the two leg amounts).

### Open sub-decisions (recommended — confirm on review)

- **O1 — Views.** Dashboard shows each account's **native** balance with a BRL
  estimate beneath; section/"Total" is BRL-consolidated. *Recommended.*
- **O2 — Category/50-30-20 totals.** Income/expense and 50/30/20 aggregate in
  **BRL** (each foreign transaction converted at current FX). A per-currency
  breakdown can come later. *Recommended: BRL-consolidated first.*
- **O3 — Missing FX rate.** If the rate for a currency is unavailable, that
  account shows native only and is excluded from the BRL total with a "≈"/stale
  hint (mirrors the investing `fxMissing` policy). *Recommended.*

---

## 3. Entity contracts

### 3.1 `AccountEntity`

| Field | Type | Invariant |
|---|---|---|
| `currency` | `Currency` | New. Default `Currency.brl`. Immutable after creation (like `type`) — changing it would reinterpret every stored native amount. |

`initialBalance`, `currentBalance` and all derived balances are henceforth in
`currency`. No other field changes.

### 3.2 `TransactionEntity`

- No new field. A transaction's currency **is its account's currency** (D1).
  `amount` is native to that account. Cross-account transfers are the only case
  where the two legs can differ in currency (each leg is native to its own
  account).
- Consolidation helpers convert `amount` to BRL at display time via the FX
  service; the entity itself stays currency-agnostic (native double).

### 3.3 FX access for the cash side

A small `AccountFxConverter` (thin wrapper over the investing `FxDataSource` +
durable cache) exposes `rate(Currency from) → double?` (to BRL, current) and
`toBrl(double amount, Currency from) → double?`. Injected into the dashboard and
statement layers. Returns null when no rate is cached (O3).

---

## 4. Business rules (numbered, testable)

1. **Native balance.** An account's balance = `initialBalance +
   Σ native transaction deltas`, all in `account.currency` (unchanged math, now
   per-currency).
2. **BRL estimate.** `brl(account) = balance × fx(account.currency→BRL)`;
   `fx(BRL) = 1`. Null rate → excluded from BRL totals (O3).
3. **Dashboard total = BRL net worth estimate.** `Σ brl(non-muted checking) +
   Σ institution market values (F8.2)`, with a "≈" marker since FX is current.
4. **Per-account native display.** Each Dashboard account row shows its native
   balance (e.g. `€1.234,56`) and, when currency ≠ BRL, a smaller `≈ R$…`
   estimate. The **account statement is native-only** — no `≈ R$` line, no
   FX-converted totals (§5, F9.7).
5. **Income/Expense/50-30-20 in BRL.** Each transaction is converted to BRL at
   current FX before aggregation (O2). A BRL-only user sees identical numbers to
   today (fx = 1, no behaviour change).
6. **Cross-currency transfer.** A transfer between accounts of different
   currencies records each leg native: expense −X in the source currency, income
   +Y in the destination currency. Y defaults to `X × fx(src→dst)` and is
   user-editable (D4). Same-currency transfers are unchanged (X = Y).
7. **Currency is create-time only.** The account form offers currency at creation
   and locks it on edit (rule mirrors `type`).
8. **BRL default & back-compat.** Every existing account is BRL; every existing
   computation yields identical results (fx = 1). F9 is additive.

---

## 5. Repository / cubit contracts

- `AccountEntity`/model/Drift table/DAO gain `currency` (enum name), default `brl`.
- `AccountBalanceCalculator` stays native (no FX) — it already only sums deltas.
- `DashboardRepositoryImpl` takes an `AccountFxConverter` to produce BRL
  estimates and consolidated totals; native values stay untouched. It is the
  **only** consumer — the statement was originally slated for one too, but that
  was dropped with the native-only decision below (`AccountStatementCubit` has
  no FX dependency).
- `compute50_30_20`/category aggregation convert per-transaction to BRL via the
  converter.
- The transfer form supports two leg amounts when the accounts' currencies differ.
- **The money input adapts to the currency (F9.7).** `FinancoCurrencyField` takes
  a `Currency` (default `brl`) that drives its prefix symbol and locale number
  format (`R$ 1.234,56` / `$ 1,234.56` / `€ 1.234,56`), backed by
  `CurrencyInputFormatter` (renamed from `BrlCurrencyInputFormatter`). Wiring:
  the transaction form passes the selected account's `accountCurrency` (and
  `destinationCurrency` for the cross-currency received field); the account form
  passes the picked `currency`; the transactions-import sheet resolves the source
  account's currency by name. `parseDecimalAmount` reads both BR and EN styles,
  so the display format stays decoupled from parsing.

  **Exclusions.** Budgets and the accounts-import sheet stay BRL — neither has a
  per-row currency to pass. The investing transaction form's money fields
  (`unitPrice`, `fees`, `amount`, and the F8.4 cash amount) *are*
  `FinancoCurrencyField`s and receive the asset's currency (the cash field
  receives BRL, since that is what moves on the checking side). An earlier
  version of this section claimed they "already carry the asset currency in
  their labels" and were therefore skipped — that is no longer how the form
  works.
- **Statement/tile currency pass (F9.7).** The display side mirrors the input
  side: `formatCurrency(double value, [Currency currency = Currency.brl])`
  delegates to `formatMoney` for anything but BRL; `AmountText` and
  `TransactionTile` each take an optional `currency` with the same default, so
  every existing BRL call site is untouched. `AccountStatementPage` passes
  `account.currency` to its summary rows, its credit-card limit/available lines
  and every `TransactionTile`.

  **Decision: the statement shows the native amount only — no `≈ R$` estimate.**
  The FX estimate is a *dashboard* affordance answering "what is this worth
  today"; a statement is a record of a specific past month, and stamping today's
  rate onto March's rows would read as historical fact while changing every time
  it is opened. The statement's totals are plain sums of its own rows and are
  never FX-converted. Rule 4's `≈ R$` sub-line therefore applies to account rows
  on the Dashboard, not to the statement.

### State machines
- `AccountFormCubit` — currency picker at create; locked on edit.
- `DashboardBloc` / statement cubits — unchanged states; values carry native +
  BRL estimate.

---

## 6. Migration (F9-M, guided)

1. **All existing accounts → `currency: brl`** (schema default; no data change).
2. **Wise Gui / Wise Mila: institution → EUR account.** These were mis-modelled
   as investing institutions. Create a `checking` account (currency EUR) for
   each, carry the display name, and retire the institution (it has no holdings).
   Guided + previewed, like F8-M. Any Wise holdings (none today) would be handled
   first.
3. Verify: Wise appears in the Balances section as a EUR account with a BRL
   estimate; the investing Institutions list no longer shows Wise.

---

## 7. Phased rollout

- **F9.1** — `AccountEntity` + model + Drift + DAO gain `currency` (default brl);
  build_runner; account factories. No behaviour change (all BRL).
- **F9.2** — `AccountFxConverter` (wraps investing FX + cache) + DI + tests.
- **F9.3** — Account create form: currency picker; account rows/statement show
  native + `≈ R$` estimate.
- **F9.4** — Dashboard total + income/expense + 50/30/20 consolidate to BRL via
  the converter (BRL-only users unchanged).
- **F9.5** — Cross-currency transfer (two leg amounts + FX default).
- **F9.6** — Guided migration (F9-M): existing → BRL; Wise institutions → EUR
  accounts. Shipped as the in-app plan-then-apply screen at `/migration`, shared
  with F8.5 — contract in [data_migration.md](data_migration.md). Docs/CLAUDE.md
  updates.
- **F9.7** — Currency reaches the widgets. Input side: `FinancoCurrencyField`
  takes a `Currency`, `BrlCurrencyInputFormatter` → `CurrencyInputFormatter`,
  wired through the transaction form (source + cross-currency destination), the
  account form and the transactions-import sheet. Display side:
  `formatCurrency(value, [currency])`, `AmountText(currency:)` and
  `TransactionTile(currency:)` all gain an optional currency defaulting to BRL,
  and the account statement renders end-to-end in the account's own currency —
  **native only, no `≈ R$` line** (see §5). Cross-currency transfer *edit* was
  fixed in the same pass: `_forTransferEdit` routes the tapped leg to the
  matching field and `_resolveTransferCounterpart` recovers the other leg's
  amount and re-resolves both currencies
  ([transactions.md](transactions.md) Transfer Rules 25–29).

Each phase: build_runner/slang as needed, `flutter analyze` zero, `flutter test`
green, regression on money paths (esp. BRL-unchanged invariant).

---

## 8. Edge cases

- BRL-only user: fx = 1 everywhere; zero visible change (the back-compat invariant).
- FX rate unavailable: native shown, excluded from BRL total with a hint (O3).
- Cross-currency transfer with no rate: user must enter the received amount.
- Credit cards in foreign currency (a USD card): same model — a `creditCard`
  account with a foreign `currency`; out of scope for first cut unless needed.
- Editing a foreign transaction: amount stays native; BRL estimate re-derives.

---

## 9. Testing

- BRL-unchanged invariant: a BRL-only fixture yields identical dashboard/50-30-20
  numbers pre/post F9.
- `AccountFxConverter`: native→BRL conversion, null-rate exclusion.
- Cross-currency transfer: legs stored native; default received amount from FX.
- Migration: Wise institution → EUR account mapping preview + apply.
