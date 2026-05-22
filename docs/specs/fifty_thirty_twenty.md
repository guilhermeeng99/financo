# 50/30/20 Feature Spec

> **Status**: Implemented (V1.1 — dedicated page + custom targets + history)
> **Last updated**: 2026-05-17
> **Coverage**: Entity, Business Rules, Repository, State Machines, UI, Edge Cases, Chat, Custom Targets, History, Navigation

The **50/30/20 rule** is a budgeting heuristic: of your monthly income,
allocate up to 50% to **needs** (essentials), up to 30% to **wants**
(discretionary), and at least 20% to **savings/investment**. Financo
surfaces the user's actual split against these targets on the Dashboard so
the user knows, at a glance, whether the current month is on track.

Targets default to 50/30/20 but are **customisable** as of V1.1 (see §12):
`FiftyThirtyTwentyTargetsCubit` + `UpdateFiftyThirtyTwentyTargetsUseCase`
persist per-user overrides on `users/{id}.fiftyThirtyTwentyTargets`.
Per-bucket month navigation and pay-down-debt accounting remain deliberate
non-goals (see §11).

## 0. Scope decisions (locked at design time)

These were debated and locked before code:

- **Needs vs. wants classification is per-category** (Option A in the
  design discussion). A new `bucket` field on `CategoryEntity` carries
  `needs | wants` for expense categories. Income categories never have a
  bucket. Bucket is **nullable** because legacy categories created before
  this feature exist — `null` is rendered as "unclassified" and surfaced as
  a prompt to classify, not as an error.
- **Savings is tracked via account type**, not via a category bucket. A
  new `AccountType.investment` is added. The savings bucket spend is the
  **net flow of money transferred from any `checking` account to any
  `investment` account during the month** — resgates (investment →
  checking) subtract.
- **Income base is the sum of `income`-typed transactions in the month**
  (no configurable salary in V1). If the month's income sum is 0, the
  card renders an empty-state explaining why percentages can't be shown.
- **Targets are user-customisable** (V1.1; were locked at 50/30/20 in
  V1). Stored as a `FiftyThirtyTwentyTargets` value object on the
  `users/{userId}` document. Default (when never edited) is
  [FiftyThirtyTwentyTargets.classic] (50/30/20). The detail page hosts
  the editor.
- **Period is the current real month**. The card respects the global
  `DateFilterCubit` (already used by the Dashboard) so when the user
  steps the month, the card recomputes alongside the other dashboard
  data.
- **No push notifications, no history view**. The card shows the active
  period only; both deferred to a later iteration.
- **Account type `investment` has no special fields** (no creditLimit /
  closingDay / dueDay / linkedAccountId). It behaves like a `checking`
  account for every cubit/widget that isn't the 50/30/20 calculation.
  Concretely: it shows up in transaction pickers, can be the source or
  destination of a transfer, contributes to total balance.
- **Rendimento (investment yield) is out of scope**. The investment
  account's `currentBalance` tracks principal (deposits − withdrawals)
  only. Documented in the UI copy so the user doesn't expect
  market-value tracking.

## 1. Entity Contract

### `CategoryBucket` (enum)

```dart
enum CategoryBucket { needs, wants }
```

Stored as `enum.name` in Firestore + Drift. Backwards-compatible:
absence of the field maps to `null`, which the overview treats as
"unclassified".

### `CategoryEntity` (modified — see also [categories.md](categories.md))

Adds:

| Field  | Type             | Nullable | Constraints                                                                 |
|--------|------------------|----------|-----------------------------------------------------------------------------|
| bucket | CategoryBucket?  | Yes      | Set only on root expense categories; subcategories inherit from the parent. |

Rules:

1. `bucket` is editable at any time (unlike `type` and `parentId`, which
   are immutable post-creation). The reason is pragmatic: users will
   classify categories *after* having created them, and changing a
   category's bucket has no cascading data consequences — only the live
   monthly overview re-bins.
2. **Subcategories inherit the parent's bucket.** Their own `bucket`
   field is always written as `null` (the category form hides the
   picker when `parentId != null`) and the 50/30/20 calculation walks
   up to the parent at read time. Justification: forcing per-child
   classification creates silent drift (a fresh "Delivery" subcategory
   under "Mercado" would otherwise sit `null` and pollute the
   `unclassified` bucket) and we have no concrete user need for a
   subcategory to diverge from its parent's bucket. Orphan-parent
   (parent deleted) transactions count as unclassified.

### `AccountType` (modified — see also [accounts.md](accounts.md))

Adds `investment`:

```dart
enum AccountType { checking, creditCard, investment }
```

Rules:

1. Investment accounts use no credit-card-specific fields. Form leaves
   them unset (same as checking).
2. Investment accounts contribute to "total balance" displays the same
   way checking accounts do (positive balance = money you hold).
3. `account_balance_calculator` treats investment identically to
   checking: income deposits raise the balance, expenses lower it,
   transfers move money in/out.

### `FiftyThirtyTwentyOverview` (computed, presentation entity)

Not persisted. Built by `compute50_30_20Overview` and surfaced as a
field on `DashboardSummary`.

| Field               | Type                                | Notes                                                              |
|---------------------|-------------------------------------|--------------------------------------------------------------------|
| income              | double                              | Sum of `income`-type, non-transfer transactions in the period      |
| needsSpent          | double                              | Sum of expenses in categories where `bucket == needs` (or child)   |
| wantsSpent          | double                              | Sum of expenses in categories where `bucket == wants` (or child)   |
| savingsAmount       | double                              | Net `checking → investment` transfer flow in the period (≥ 0)      |
| unclassifiedSpent   | double                              | Expense sum where the resolved root category's `bucket == null` (transaction-based, period-scoped) |
| unclassifiedCount   | int                                 | Backlog of root expense categories with `bucket == null`. **Category-based, not transaction-based** — surfaces the full classification work to do, independent of whether those categories spent this month. Subcategories and orphans never increment it. |
| status              | FiftyThirtyTwentyStatus             | See below                                                          |

Computed getters:

- `needsTarget = income * 0.50`
- `wantsTarget = income * 0.30`
- `savingsTarget = income * 0.20`
- `needsPercent = needsSpent / income` (0 if income == 0)
- `wantsPercent = wantsSpent / income` (0 if income == 0)
- `savingsPercent = savingsAmount / income` (0 if income == 0)
- `hasData = income > 0`
- `hasUnclassified = unclassifiedCount > 0`

### `FiftyThirtyTwentyStatus` (enum)

A coarse summary of the whole snapshot, used by the headline copy on the
card. Computed per-bucket then aggregated:

- per-bucket:
  - `needs`: `onTrack` if `needsPercent <= 0.50`, `over` otherwise
  - `wants`: `onTrack` if `wantsPercent <= 0.30`, `over` otherwise
  - `savings`: `onTrack` if `savingsPercent >= 0.20`, `under` otherwise
- aggregated:
  - `noData` if `income == 0`
  - `unclassifiedDominant` if `unclassifiedSpent > needsSpent + wantsSpent`
    (we can't trust the split — prompt the user to classify before
    drawing conclusions)
  - `onTrack` if all three buckets are on-track
  - `needsAttention` otherwise

### `BucketStatus` (enum — per-bucket)

```dart
enum BucketStatus { onTrack, over, under }
```

Used only by the card UI when rendering each of the three rows. `over`
for needs/wants means actual > target; `under` for savings means
actual < target.

## 2. Business Rules

1. **Income base is the sum of `income`-typed, non-transfer transactions
   in the selected month, restricted to categories with
   `countsIn50_30_20 == true`** (the default). Transfers
   (`linkedTransactionId != null`) are always excluded — moving money
   between own accounts is not income. Income categories explicitly
   marked `false` (e.g. "Reembolso") are skipped so non-recurring
   receipts don't distort the breakdown (see
   [categories.md](categories.md) rule 22).
2. **Needs/wants spend uses the parent's bucket for subcategory
   transactions**: when a transaction's `categoryId` resolves to a
   subcategory, the calculation walks up to the parent and reads the
   parent's `bucket`. The subcategory's own bucket is always `null` and
   ignored (see §1 rule 2 for the rationale). If the parent is missing
   (orphan parent), or if the transaction's category itself is missing
   (orphan category), the transaction counts as unclassified.
3. **Only `expense`-type transactions count toward needs/wants**.
   Transfers excluded.
4. **Savings calculation**:
   - Look at every transfer in the month (`linkedTransactionId != null`).
   - For each transfer pair (one expense leg, one income leg):
     - If the expense leg's account is `checking` AND the income leg's
       account is `investment`: ADD `amount`.
     - If the expense leg's account is `investment` AND the income leg's
       account is `checking`: SUBTRACT `amount` (resgate).
     - Any other combination: ignore. Specifically:
       - checking → checking: not savings, just internal moves
       - investment → investment: rebalancing within the carteira
       - any pair involving `creditCard`: cartão payments are not
         savings
   - The result is clamped to `≥ 0` in the overview (negative net flow
     means the user took out more than they put in this month — we
     surface savings as `0` so the percentage doesn't go negative).
5. **Targets are fixed**: 50 / 30 / 20. No customisation in V1.
6. **A transaction with `categoryId` pointing to an income category but
   typed as expense is data drift** — excluded from any bucket
   (filtered out at rule 2).
7. **Period boundaries** are `startOfMonth(month)` / `endOfMonth(month)`
   from `lib/core/utils/date_helpers.dart`, matching the dashboard.
8. **Orphan tolerance**: deleted categories don't crash the overview.
   Expenses on orphan categories count as `unclassifiedSpent`.
9. **No savings without an investment account**: if the user has zero
   investment accounts, `savingsAmount` is always 0 (no transfers can
   possibly count). The UI shows a hint that explains this and links to
   `/account/add`. This is the most common first-time-user state.

## 3. Architecture

The feature does **not** introduce a new repository or DI registration.
It piggybacks on `DashboardRepositoryImpl`:

- A pure function `compute50_30_20Overview(...)` lives in
  `lib/features/dashboard/domain/services/`. Inputs: income transactions,
  expense transactions, categories, transfer transactions, accounts.
  Output: `FiftyThirtyTwentyOverview`. **Stateless and synchronous** — no
  IO, no async, no DI.
- `DashboardRepositoryImpl.getDashboardSummary` calls this function with
  the data it already fetched and adds the result to `DashboardSummary`
  under a new `fiftyThirtyTwenty` field.
- The `FiftyThirtyTwentyCard` widget reads `state.summary.fiftyThirtyTwenty`
  from `DashboardLoaded`.

This avoids:

- A redundant Firestore round-trip (`getDashboardSummary` already fetches
  everything we need).
- New entries in `injection_container.dart`.
- A separate cubit/bloc (the dashboard bloc already orchestrates the
  load + period change).

## 4. Compute Algorithm

```text
Inputs:
  - periodTransactions   : List<TransactionEntity> for [startOfMonth, endOfMonth]
  - categories           : List<CategoryEntity>
  - accounts             : List<AccountEntity>

  Pre-build:
    categoriesById  : Map<String, CategoryEntity>
    accountTypeById : Map<String, AccountType>

  Steps:
    1. income = sum(t.amount where t.type == income && !t.isTransfer)

    2. needsSpent, wantsSpent, unclassifiedSpent, unclassifiedCatIds : initialise to 0 / {}
       for each t in periodTransactions where t.type == expense && !t.isTransfer:
         cat = categoriesById[t.categoryId]
         if cat == null:
           unclassifiedSpent += t.amount
           unclassifiedCatIds += t.categoryId        # orphan id; counted separately
           continue
         # Subcategories inherit the parent's bucket (rule 2).
         rootCat = (cat.parentId == null) ? cat : categoriesById[cat.parentId]
         if rootCat == null:
           # orphan parent — the subcategory exists but its parent was deleted
           unclassifiedSpent += t.amount
           unclassifiedCatIds += cat.id
           continue
         switch (rootCat.bucket):
           needs   → needsSpent += t.amount
           wants   → wantsSpent += t.amount
           null    → unclassifiedSpent += t.amount
                     unclassifiedCatIds += rootCat.id

    3. savingsAmount:
       Build a transfer pair map keyed by linkedTransactionId.
       For each pair (expenseLeg, incomeLeg):
         srcType = accountTypeById[expenseLeg.accountId]
         dstType = accountTypeById[incomeLeg.accountId]
         if srcType == checking && dstType == investment:
           net += amount
         else if srcType == investment && dstType == checking:
           net -= amount
       savingsAmount = max(0, net)

    4. unclassifiedCount = unclassifiedCatIds.length

    5. Compose FiftyThirtyTwentyOverview { income, needsSpent, wantsSpent,
                                           savingsAmount, unclassifiedSpent,
                                           unclassifiedCount }
```

Order of complexity: O(T + C + A) where T = transactions, C = categories,
A = accounts. No nested scans.

## 5. Repository / Use Case

No new repository. No new use case.

`DashboardRepositoryImpl.getDashboardSummary`:

```dart
final overview = compute50_30_20Overview(
  periodTransactions: transactions,
  categories: categories,
  accounts: accounts,
);
return Right(DashboardSummary(
  ...,
  fiftyThirtyTwenty: overview,
));
```

`DashboardSummary` gains a non-nullable `fiftyThirtyTwenty` field. The
overview entity itself handles empty state (income == 0); callers don't
need to null-check.

## 6. UI

### Card placement

`FiftyThirtyTwentyCard` is inserted on `DashboardPage` immediately
**after** the credit-card `DashboardSection` and **before** the
investment section. Rationale: account balances are the most-glanced
data, so they sit at the top; the rule-of-thumb summary comes next as
a contextual read. Same horizontal margins (`16`), same
`flutter_animate` entrance treatment (`fadeIn` + `slideY` with a
175ms delay so it tweens in after the account sections).

### Layout

A single rounded `surface`-coloured container, 16px padding, 20px
border-radius (matches the rest of the dashboard surfaces).

```
┌────────────────────────────────────────────┐
│ 50/30/20 ······················ 100% = R$ X │  <- header row
│                                            │
│ 🟢 Necessidades  · 48% de 50%  R$ 2.400   │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░ ← bar w/ target  │
│                                            │
│ 🟡 Desejos        · 33% de 30%  R$ 1.650  │
│ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░                 │
│                                            │
│ 🔵 Investimento   · 18% de 20%  R$ 900    │
│ ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░                 │
│                                            │
│ [opcional] dica curta                      │
└────────────────────────────────────────────┘
```

- **Header line**: section title (`dot + uppercase label`, like
  `DashboardSection`) inline within the card, with the `100% = R$ X`
  baseline pill anchored to the right (hidden when income is 0).
- **No status headline**: the card does *not* render a status sentence
  ("Você está no caminho." etc. were removed for being noise). The
  `overview.status` enum still exists and is still computed — it drives
  the **footer dica precedence** (e.g. `unclassifiedDominant` surfaces
  the classify tip first), not any headline copy.
- **Per-bucket rows** (3 of them):
  - Leading icon (FontAwesome): `walletAlt` (needs), `face_grin_beam`
    (wants — use a sensible mapping like `cocktail`), `piggy_bank`
    (savings).
  - Label + actual% / target% + actual currency amount, right-aligned.
  - `LinearProgressIndicator` clamped `[0, 1]`, height 8, rounded.
  - Bar value = `actualPercent` for needs/wants (capped to 1.0 visually,
    actual reported textually). For savings, value = `actualPercent / targetPercent`
    so the bar fills at the *target* (20%), making "on or above target"
    a full-or-above bar.
  - **Target marker**: a 2px vertical tick on the bar at the target
    position (50% / 30% / N/A for savings since the bar already
    represents "fraction of target"). Same `onBackgroundLight` colour.
- **Footer dica**: one-liner inferred from the data:
  - `needsSpent > needsTarget`: "Reduza R$X em necessidades para fechar
    no alvo."
  - `wantsSpent > wantsTarget`: "Você passou do orçamento de desejos em
    R$X este mês."
  - `savingsAmount < savingsTarget && hasInvestmentAccount`: "Faltam R$X
    para atingir 20% de investimento."
  - `savingsAmount < savingsTarget && !hasInvestmentAccount`: "Crie uma
    conta de investimento para começar a registrar seus aportes." with a
    button-style trailing chip → `/account/add`.
  - `hasUnclassified`: "$count categoria(s) ainda sem classificação." +
    chip → `/categories`.

### Empty / partial states

| Scenario                                                | Render                                                                                                                                       |
|---------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `income == 0`                                           | Compact card with a single no-income hint row ("Registre suas receitas...", `noIncomeHeadline`) + chart-pie icon. No baseline pill. No bars. No bucket rows. Same visual height as a `_NoAccountsHint`. |
| `income > 0` but every expense category is unclassified | Bars rendered with all spend pooled in a 4th, muted "Sem classificação" row. CTA to classify (chip → `/categories`).                          |
| `income > 0`, partial classification                    | Bars rendered normally + footer dica counts the unclassified                                                                                  |
| No investment accounts                                  | Savings row still rendered (will read `R$ 0 · 0% de 20%`) + footer dica with `/account/add` chip                                              |

### Colours

Re-uses tokens — no new constants:

- Needs bar fill: `colors.primary` (the brand accent for the largest
  bucket).
- Wants bar fill: `colors.warning` (matches the spending tone elsewhere
  — yellow is the "spend money on yourself" colour).
- Savings bar fill: `colors.income` (green, matches "growing balance").
- Per-bucket status icon tint follows `BucketStatus`:
  - `onTrack` → `colors.success`
  - `over` (needs/wants) → `colors.warning` if same-side margin, escalates
    to `colors.expense` when `actualPercent >= targetPercent * 1.25`.
  - `under` (savings) → `colors.expense` when `savingsPercent < 0.5 * 0.20`
    (i.e. less than half of target), else `colors.warning`.

### Accessibility

- Each row's bar has a `Semantics` label that reads the bucket name,
  the absolute amount, and the percentage (e.g. "Necessidades: R$ 2.400,
  48% de 50%").
- Status icons carry `excludeFromSemantics: true` because the row label
  already covers it.

## 7. State Machines

No new bloc/cubit. State changes flow through:

- `DateFilterCubit` → emits → `DashboardBloc` reloads → `DashboardLoaded`
  carries a fresh `summary.fiftyThirtyTwenty`.
- `AccountsCubit` → emits `AccountsLoaded` / `AccountsImported` → existing
  dashboard listener triggers a force refresh. **The same path also
  refreshes the 50/30/20 card** because it's just a slice of
  `DashboardSummary`.

The category form will dispatch an additional refresh after editing
`bucket` (already done implicitly: today the categories cubit's
`updateCategory` triggers downstream blocs that listen to it — needs
explicit verification, see §10).

## 8. Edge Cases

| Scenario                                                                     | Expected behaviour                                                                                                                          |
|------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| Income == 0                                                                  | Card collapses to the empty hint. No division-by-zero anywhere.                                                                             |
| Every expense category lacks `bucket`                                        | All expense spend → `unclassifiedSpent`. Status is `unclassifiedDominant`. CTA to classify.                                                 |
| One investment account, zero transfers in the month                          | Savings row shows `R$ 0 · 0% de 20%` and the under-target hint without the "create account" CTA.                                            |
| Transfer checking → investment of R$ 1000, then resgate of R$ 200            | `savingsAmount = 800`.                                                                                                                       |
| Resgate (investment → checking) of R$ 500 with no deposits                   | Net = -500, clamped to 0. UI shows R$ 0 + the under-target hint.                                                                            |
| Transfer between two checking accounts                                       | Ignored. Not savings.                                                                                                                        |
| Transfer checking → credit card (cartão payment)                             | Ignored. Not savings.                                                                                                                        |
| Transfer investment → investment (rebalancing)                               | Ignored.                                                                                                                                     |
| User changes a category's `bucket` mid-month                                 | The card re-bins on next refresh. Past spend on that category counts under the **new** bucket — there is no historical bucket-at-time-of-tx. |
| Subcategory transaction with parent bucket = `needs`                         | Counts toward `needs` (subcategory inherits parent — see rule 2).                                                                          |
| Subcategory transaction where the parent was deleted                         | Counts as `unclassified` (orphan-parent fallback).                                                                                          |
| Income transaction with `linkedTransactionId != null` (transfer income leg)  | Excluded from `income`.                                                                                                                      |
| Category deleted while user is mid-classification (race)                     | Expenses on it count as unclassified. The orphan never reaches the UI.                                                                       |

## 9. Testing Checklist

### Unit — `compute_fifty_thirty_twenty_test.dart`

- `income == 0` → `status == noData`, all percentages `0`.
- Happy path: income 5000, needs 2400, wants 1650, savings 900 →
  percentages 48 / 33 / 18; status `needsAttention` (savings short).
- All on target: 2500 needs / 1500 wants / 1000 savings → `onTrack`.
- Boundaries: `needsPercent == 0.50` → `onTrack` (≤ not <).
- Resgate exceeds deposits → `savingsAmount == 0`, no negative.
- Resgate partial → net positive.
- Investment ↔ investment transfer → not counted.
- Checking → credit card → not counted.
- Subcategory `bucket` overrides parent (parent needs, child wants).
- Orphan-category expense → `unclassifiedSpent`.
- `unclassifiedDominant` boundary: when unclassified > needs+wants.
- Excludes transfers from `income` and from bucket sums.
- Excludes income-typed transactions on expense categories from buckets.

### Integration — `dashboard_repository_impl_test.dart`

- `getDashboardSummary` populates `summary.fiftyThirtyTwenty` with the
  same numbers `compute50_30_20Overview` would produce in isolation.
- No regression to existing summary fields.

### Categories

- Drift schema bump migrates (test runs against an in-memory DB after
  the version bump → tables are dropped + recreated; no data loss
  expected because Firestore re-sync repopulates).
- `CategoryModel.fromMap` reads `bucket` as `null` when absent and as
  the enum value when present.
- `CategoryFormCubit` exposes `updateBucket` and submits with the
  selected bucket. Bucket selector is hidden when `type == income`.

### Accounts

- `AccountType.investment` round-trips through `AccountModel.toJson` /
  `fromMap`.
- `AccountFormCubit` accepts `investment` as a valid type, skipping the
  credit-card-only required fields.

### Widget — `fifty_thirty_twenty_card_test.dart`

- Renders the empty hint when `overview.hasData == false`.
- Renders three bucket rows + footer dica when on-track.
- Renders the unclassified CTA chip when `hasUnclassified`.
- Renders the "create investment account" CTA when savings is under
  target and there are no investment accounts.

## 10. Cross-Feature Wiring

- **Categories form**: a new `bucket` selector appears below the type
  toggle, only when `state.type == expense`. Toggling type to `income`
  clears the bucket (`copyWith(clearBucket: true)`).
- **Category tile**: optional small pill next to the subtitle showing
  "Essencial" or "Desejo" when classified. Categories without a bucket
  show no pill (no negative-space indicator — keep the row clean).
- **CSV import** (categories): `bucket` column is **not** introduced in
  V1. Imported categories land with `bucket == null` and the user
  classifies them in the form. Documented in the import CSV intro copy.
- **Chat action handler — `category create`**: `bucket` is **not** part
  of the chat payload in V1. Documented in [chat.md](chat.md) ↩ §
  "Category create".
- **Dashboard refresh after category edit**: when the user edits a
  category's bucket from `/categories`, the dashboard must reflect it
  on next visit. The dashboard already force-refreshes on
  `AccountsCubit` events; we add a `CategoriesCubit` listener with the
  same pattern (see `dashboard_page.dart`).

## 11. Out of Scope (V1)

Deferred — each adds complexity that's better tackled after V1 ships
and we have real usage signal:

- **Custom targets** (e.g., 60/20/20 or 70/20/10).
- **Per-month history** ("how did I do in March?"). The dashboard's
  month stepper already controls the period, so this works passively —
  but a dedicated trend view (last 6 months at a glance) is V2.
- **Pay-down-debt as savings**. Requires `AccountType.loan` and a clear
  rule for what counts (amortization only vs. minimum payment).
- **Investment yield / current market value**. Out of scope —
  documented in the UI copy so the user knows the "saldo" reflects
  principal only.
- **Push notifications when off-track**. Uses existing FCM infra but
  intentionally postponed to avoid notification fatigue debate.
- **`bucket` on the CSV import column**. Manual classification only in
  V1.
- **`bucket` over the chat**. AI doesn't propose bucket on create.
- **Configurable income source** ("use my salary number, not the income
  sum"). Useful for variable-income users (freelancers); deferred.
- **Bucket inheritance from parent**. The current "explicit on
  subcategory" rule is more flexible; an inheritance toggle is V2.

## 12. V1.1 Additions — Custom Targets, Detail Page, History, Navigation

### 12.1 Custom Targets

- New value object `FiftyThirtyTwentyTargets` (`needs`, `wants`,
  `savings` — each `[0, 1]`; sum must equal `1.0 ± 0.001`).
  [FiftyThirtyTwentyTargets.classic] is the default for users who
  haven't customised.
- Persisted on `users/{userId}` as a nested map:
  `fiftyThirtyTwentyTargets: { needs, wants, savings }`. Absence of the
  field is the "never customised" state — the use case resolves to
  classic in that case.
- Three nullable doubles mirror the same shape in Drift
  (`fiftyThirtyTwentyNeeds`, `fiftyThirtyTwentyWants`,
  `fiftyThirtyTwentySavings`); all-null means "use classic".
- New use cases: `GetFiftyThirtyTwentyTargetsUseCase` (always returns a
  valid value, falling back to classic) and
  `UpdateFiftyThirtyTwentyTargetsUseCase` (read-modify-write through
  `ProfileRepository`; rejects invalid input with `ValidationFailure`
  before touching the network).
- Session cubit `FiftyThirtyTwentyTargetsCubit` holds the active
  targets. The shell route instantiates it once per session, kicks off
  `loadTargets()`, and provides it via `BlocProvider.value` to the
  whole shell.
- `DashboardBloc` reads `state.targets` from the cubit and passes them
  to `getDashboardSummary`, so the dashboard card always reflects the
  user's choice.
- The card's `_BucketRow` and the `BucketStatus` getters on
  `FiftyThirtyTwentyOverview` now compute against `targets.needs`,
  `targets.wants`, `targets.savings` instead of hardcoded
  `0.5/0.3/0.2`.

### 12.2 Dedicated Detail Page

- Route: `/fifty-thirty-twenty` (and as the second sub-tab of
  `/planning`). Reachable by tapping the dashboard card or from the
  shell tab.
- Page widget: `FiftyThirtyTwentyPage`.
- Page bloc: `FiftyThirtyTwentyDetailCubit` — fetches accounts,
  categories, period transactions, and a 3-month history; composes
  overview + breakdown via `compute50_30_20Overview` and
  `compute50_30_20Breakdown`.
- Layout: month stepper (mobile only — sidebar already has one on
  desktop) → big card → per-bucket breakdown → 3-month history chart.
- App-bar action: a sliders icon opens the targets editor sheet.
- Refresh triggers: `DateFilterCubit` change, targets change, and the
  initial mount.

### 12.3 Per-Bucket Breakdown

- New pure function `compute50_30_20Breakdown(periodTransactions,
  categories)` returns `FiftyThirtyTwentyBreakdown` with three sorted
  lists (needs / wants / unclassified) of `(rootCategoryId, name, icon,
  color, amount)`.
- Subcategories roll up to their parent root (same rule 20 handling as
  the overview). Orphans land under unclassified.
- The page renders each bucket as a `DashboardSection` listing the
  rows.

### 12.4 3-Month History

- New entity `FiftyThirtyTwentyHistoryEntry` (`month`, `overview`).
- New use case `GetFiftyThirtyTwentyHistoryUseCase` fetches accounts,
  categories and the **whole 3-month window of transactions** in one
  pass, then buckets per month locally and runs
  `compute50_30_20Overview` on each.
- Returned in chronological order (oldest → current). Default count is
  3; callable with any value ≥ 1.
- Rendered by `FiftyThirtyTwentyHistoryChart` — a hand-painted
  stacked-bar widget showing actual needs/wants/savings percent per
  month, capped visually at 100%. Empty months render as a faint
  placeholder.

### 12.5 Navigation: Planejamento Shell Tab

- The bottom-nav and sidebar entry previously labelled "Orçamento" is
  renamed to "Planejamento" (key `t.nav.planning`) and targets the new
  `/planning` route.
- `PlanningPage` is a tabbed container with three `TabBarView`
  children (order intentionally matches "high-level → tactical"):
  - Tab 0: **50/30/20** — `FiftyThirtyTwentyPage` (embedded).
  - Tab 1: **Contas** — `BillsPage` (embedded). Inherited the slot
    from the old top-level Bills nav entry; see [investments.md](investments.md)
    for the navigation refactor rationale.
  - Tab 2: **Orçamentos** — `BudgetsPage` (embedded).
- Legacy direct links to `/bills`, `/budgets`, and `/fifty-thirty-twenty`
  resolve to `PlanningPage` with the appropriate `initialTab` so
  bookmarks, push notifications, and chat-tap navigation keep working.
- Bottom-bar "active" detection covers all four paths
  (`/planning`, `/bills`, `/budgets`, `/fifty-thirty-twenty`).
- Mobile bottom bar stays at 5 items. The slot freed by Bills moving
  into Planning is now occupied by the **Investimentos** entry
  (see [investments.md](investments.md)).

### 12.6 Editor sheet

- `showFiftyThirtyTwentyTargetsSheet(context, cubit)` opens the editor
  as a bottom sheet.
- Three integer percent fields (Needs / Wants / Savings) with a live
  sum indicator that goes green at 100% and amber otherwise.
- "Reset to 50/30/20" button reverts the draft.
- Submit is disabled while sum != 100. On success the sheet pops and
  the cubit emits the new targets — every listener (dashboard,
  detail page) reloads.

## 13. Open Questions

None blocking V1 implementation. Tracked here for future iterations:

1. Should `bucket` be **required** for new expense categories (form
   validation)? Currently optional. Pro-required: forces clean data.
   Con-required: friction on first-time-user flow.
2. Surface a tiny "classify all" wizard from the Dashboard card when
   `unclassifiedDominant`? Probably yes, but designed in a follow-up
   spec.
3. Should the dashboard month stepper carry a marker on past months
   that finished off-track? Useful for retro view; out of V1.
