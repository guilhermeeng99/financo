# Investments Feature Spec

> **Status**: V1 — initial design
> **Last updated**: 2026-05-18
> **Coverage**: Entity, Business Rules, Repository, State Machines, UI, Edge Cases, Navigation

The **Investments** tab is a tracking layer that sits **on top of** the
existing `AccountType.investment` accounts. It lets the user declare
**how the money inside each investment account is allocated** across
user-defined asset classes (ARCA methodology friendly — Ações, Real
Estate, Cripto, Ativos de renda fixa, or anything else the user
invents), see real-vs-target allocation, and read rebalance suggestions.

## 0. Scope decisions (locked at design time)

These were debated and locked before code:

- **Tracking only — never writes transactions.** Editing a holding,
  creating an asset class, or accepting a rebalance suggestion never
  produces a `TransactionEntity` and never mutates any account balance.
  Transactions remain the single source of truth for **cash flow** —
  investments are a **composition layer** on top of the already-tracked
  cash balance. This is the central isolation invariant.
- **Account balance is the ceiling (Model A — coupled).** For each
  `AccountType.investment` account, the sum of holdings on that account
  must be `≤ account.effectiveBalance`. The delta —
  `pending = effectiveBalance − Σ holdings of account` — surfaces as an
  "unallocated" amount and prompts the user to classify. Choosing
  Model A (vs a fully standalone universe) lets aporte transfers
  (`checking → investment`) automatically surface as pending — the user
  cannot silently forget to allocate a fresh deposit.
- **Holdings are per-account, not per-portfolio.** A holding belongs to
  one investment account. Total per class is `Σ holdings.amount where
  holding.assetClassId == class.id` across all accounts. This matches
  the rest of the app's "balance lives on the account" model.
- **Targets are user-defined.** `AssetClassEntity.targetPercent` carries
  the user's intended allocation. Sum across all the user's classes
  **should** equal 100 but the system only warns — it never blocks edits
  on that basis (mid-edit states are valid).
- **No yield / market-value tracking in V1.** Holdings carry a manual
  `amount` only. Cotação real-time, ticker integration, P&L vs purchase
  price — all out of scope. Documented in UI copy.
- **No automatic rebalance execution.** Rebalance suggestions are
  read-only labels. The user moves money via the existing transfer flow
  on the Accounts page; the investments tab does not push transactions.
- **Investments keeps its shell slot.** Bills/payables no longer occupies a
  mobile bottom-nav slot; payables/receivables live under Dashboard on the
  sidebar.

## 1. Entity Contract

### `AssetClassEntity`

| Field          | Type    | Nullable | Constraints                                                          |
|----------------|---------|----------|----------------------------------------------------------------------|
| id             | String  | No       | Firestore doc ID; empty on create.                                   |
| userId         | String  | No       | Owner.                                                               |
| name           | String  | No       | Non-empty. Free text — "Real Estate", "Bitcoin", "Tesouro Selic"...  |
| icon           | int     | No       | Material/FontAwesome icon code point. **Subclass rows inherit from the parent at write time.** |
| color          | int     | No       | ARGB. **Subclass rows inherit from the parent at write time.**       |
| targetPercent  | double  | No       | `[0, 100]`. Carried by **both** roots and subclasses: on a root it is the share of the **total portfolio**; on a subclass it is the share of its **parent class's** allocation. `0` = no target set. |
| parentId       | String? | Yes      | References another root class; `null` = root. See subclass rules.    |
| createdAt      | DateTime| No       | Set on creation.                                                     |

Computed getters:

- `targetFraction` → `targetPercent / 100` — convenient for math.
- `isSubclass` → `parentId != null`.
- `canBeParent` → `parentId == null` — only roots can be picked as a parent.

### Subclass rules

1. **One nesting level only.** A subclass cannot itself own subclasses. The parent picker filters to root classes; saving a subclass with a `parentId` pointing at another subclass is blocked at the use-case layer.
2. **Subclasses inherit `icon` + `color` from the parent at write time** — the form mirrors the parent's appearance and the persisted row carries that snapshot. If the parent's appearance changes later, existing subclasses keep the old visuals; users can re-save the subclass to re-sync. (Mirrors the explicit-on-write trade-off used by categories — see `docs/specs/categories.md` rule 17.)
3. **Subclasses carry their own `targetPercent`** — the share of the parent class they should represent. The root's target sizes the whole group against the portfolio; each subclass's target splits that group internally. The form shows the target slider for subclasses too. `0` means "no target set yet", in which case the detail page shows share-of-class only and offers no suggestion. Sibling subclass targets should sum to 100 (not hard-enforced — see rule 7).
4. **Holdings only reference subclasses.** Root classes are pure
   organisational containers — the user never writes a holding
   directly on a root. The use cases (`CreateAssetHoldingUseCase` and
   `UpdateAssetHoldingUseCase`) reject any payload whose `assetClassId`
   resolves to a class with `parentId == null`. The class total at the
   overview level is `Σ holdings where assetClassId IN subclassIdsOf(root)`.
5. **Deleting a parent class is blocked while it has subclasses.** The user must remove or re-parent the subclasses first.
6. **Orphan subclass tolerance** — when a subclass's `parentId` resolves to a missing/deleted class, its holdings count as unclassified (same fallback as orphan holdings).

### `AssetHoldingEntity`

| Field         | Type     | Nullable | Constraints                                                             |
|---------------|----------|----------|-------------------------------------------------------------------------|
| id            | String   | No       | Firestore doc ID; empty on create.                                      |
| userId        | String   | No       | Owner.                                                                  |
| accountId     | String   | No       | References an `AccountType.investment` account.                         |
| assetClassId  | String   | No       | References an `AssetClassEntity`.                                       |
| amount        | double   | No       | `≥ 0`. Manually declared by the user.                                   |
| notes         | String?  | Yes      | Free text — "CDB Banco Inter, vence 2028".                              |
| updatedAt     | DateTime | No       | Touched on every write.                                                 |

### `InvestmentOverview` (computed, presentation entity)

Not persisted. Built by `computeInvestmentOverview(...)`.

| Field              | Type                          | Notes                                                          |
|--------------------|-------------------------------|----------------------------------------------------------------|
| totalInvested      | double                        | Σ `account.effectiveBalance` over investment accounts.         |
| totalAllocated     | double                        | Σ `holding.amount`.                                            |
| totalPending       | double                        | `totalInvested − totalAllocated`, clamped `≥ 0`.               |
| accountBreakdown   | List<InvestmentAccountSlice>  | One per investment account (balance, allocated, pending).      |
| classBreakdown     | List<InvestmentClassSlice>    | One per class (current amount, current %, target %, delta R$). |
| rebalanceActions   | List<RebalanceAction>         | Sorted: biggest absolute delta first.                          |
| targetSumPercent   | double                        | Σ of every class's `targetPercent`. UI warns when ≠ 100.       |
| hasInvestments     | bool                          | `true` if `totalInvested > 0`.                                 |
| hasClasses         | bool                          | `true` if user has at least one class.                         |

### `InvestmentAccountSlice`

| Field          | Type    |
|----------------|---------|
| accountId      | String  |
| accountName    | String  |
| balance        | double  |
| allocated      | double  |
| pending        | double  |

### `InvestmentClassSlice`

| Field             | Type    |
|-------------------|---------|
| classId           | String  |
| name              | String  |
| icon              | int     |
| color             | int     |
| currentAmount     | double  |
| currentPercent    | double  |
| targetPercent     | double  |
| targetAmount      | double  |
| deltaAmount       | double  | (`targetAmount − currentAmount`; positive = under, negative = over)
| subclasses        | List<InvestmentSubclassSlice> | One per direct subclass of this root class. Empty when the class has none. |

### `InvestmentSubclassSlice`

Rendered nested under its parent's class row. The subclass's `percentOfClass`
is `subclass.amount / parent.currentAmount` — never divides by zero (returns 0
when the parent has no holdings yet).

| Field           | Type   | Notes                                              |
|-----------------|--------|----------------------------------------------------|
| subclassId      | String |                                                    |
| name            | String |                                                    |
| icon            | int    | Snapshot of the parent's icon at write time.       |
| color           | int    | Snapshot of the parent's color at write time.      |
| currentAmount   | double | Σ of holdings tied to this subclass.               |
| percentOfClass  | double | `[0, 1]` — share of the parent class's total.     |
| percentOfTotal  | double | `[0, 1]` — share of `totalInvested`.              |
| targetPercent   | double | `[0, 100]` — user-declared share of the parent class. `0` = no target. |

### `RebalanceAction`

| Field        | Type                | Notes                                                          |
|--------------|---------------------|----------------------------------------------------------------|
| classId      | String              |                                                                |
| className    | String              |                                                                |
| direction    | RebalanceDirection  | `buy` (current < target) or `sell` (current > target).         |
| amount       | double              | Absolute R$ to move to reach target.                           |

### `RebalanceDirection` (enum)

```dart
enum RebalanceDirection { buy, sell }
```

## 2. Business Rules

1. **Holdings only attach to investment accounts.** The form's account
   picker filters to `AccountType.investment`. Submitting against any
   other type returns `ValidationFailure`.
2. **Σ holdings per account ≤ account.effectiveBalance.** The form
   blocks submit when the new total would exceed the balance and shows
   the available remainder inline. Editing an existing holding compares
   against `(currentSum − thisHolding.amount + newAmount)`.
3. **`amount` is non-negative.** Zero is allowed (transient state while
   the user redistributes) but the form prefers `amount > 0` on submit
   to avoid noise rows.
4. **No transactions are written.** Create/update/delete of holdings or
   classes never call the transactions repository or the accounts
   repository. This is enforced by giving the investments repository
   no dependency on either — see §3.
5. **Deleting a class with holdings is blocked** until every holding
   pointing to it is reassigned or deleted. Error surfaces as
   `ValidationFailure`. The form lists the impacted holdings in the
   error sheet so the user can act.
6. **Deleting an investment account cascades** — all holdings on that
   account are deleted by the accounts cubit through a hook
   (`InvestmentsCubit.removeHoldingsForAccount(accountId)` called from
   the accounts cubit's delete success path). Cascade is best-effort:
   the account delete still succeeds even if holding cleanup fails;
   stale holdings simply surface as "orphan holding — account missing"
   on the next investments refresh and are filtered out of the
   overview.
7. **`targetPercent` sum is not enforced.** The UI computes
   `targetSumPercent` and shows a yellow banner ("Os alvos somam X% —
   ajuste para 100%") when it differs from 100 by more than 0.1. Edit
   submission is never blocked on this — the user is allowed to be in
   the middle of redistributing.
8. **Rebalance suggestions are computed against the live total**
   (`totalInvested`, including pending). Pseudocode in §4.
9. **Pending is always ≥ 0**. If `Σ holdings > balance` (theoretically
   blocked by rule 2 but possible if a transaction post-dates a holding
   write — e.g. user records a withdrawal after declaring composition),
   the overview clamps `pending = 0` and the affected account is
   flagged with `hasOverflow = true` so the UI can prompt
   reconciliation. (See §8 for the exact display copy.)
10. **Orphan tolerance**: holdings whose `accountId` does not match any
    current investment account, or whose `assetClassId` does not match
    any current class, are ignored by the overview (filtered out) and
    surface in a "manutenção" list at the bottom of the page with a
    one-click "remover" affordance.
11. **The feature only requires an investment account to be useful**
    but does not require one to exist before declaring classes. A user
    can pre-define their target allocation (R$0 invested, target 25/25/25/25)
    before opening any investment account; the overview renders in
    "empty data" mode.

## 3. Architecture

The feature is fully isolated from the transactions/accounts write
paths. To make this enforceable rather than aspirational:

- `AssetClassRepository` and `AssetHoldingRepository` are independent
  abstractions, each with its own remote datasource + DAO. Neither
  takes a `TransactionRepository` or `AccountRepository` dependency.
- The compose step (account balance × holdings → overview) happens in
  `GetInvestmentOverviewUseCase`, which depends on:
  - `AccountRepository` (read-only — to fetch account balances)
  - `AssetClassRepository`
  - `AssetHoldingRepository`
- The pure function
  `lib/features/investments/domain/services/compute_investment_overview.dart`
  takes already-fetched data and returns `InvestmentOverview`. No IO,
  no async — directly unit-testable.

This mirrors the way `compute50_30_20Overview` already piggybacks on
`DashboardRepositoryImpl.getDashboardSummary`. Investments do **not**
piggyback because they have their own page and their own cubit; the
overhead of a dedicated use case is justified by the page's needs
(forms, mutations) vs. the dashboard card being a pure read.

## 4. Compute Algorithm

```text
Inputs:
  accounts : List<AccountEntity>            // all of the user's accounts
  classes  : List<AssetClassEntity>
  holdings : List<AssetHoldingEntity>

Pre-build:
  investmentAccounts        = accounts.where(type == investment)
  investmentAccountIds      = {a.id for a in investmentAccounts}
  classesById               = {c.id: c}
  accountsById              = {a.id: a for a in investmentAccounts}

  liveHoldings              = holdings.where(accountId ∈ investmentAccountIds
                                          && assetClassId ∈ classesById)
  orphanHoldings            = holdings − liveHoldings

Per-account slice:
  for each account a in investmentAccounts:
    allocated = Σ liveHoldings.amount where accountId == a.id
    pending   = max(0, a.effectiveBalance − allocated)
    hasOverflow = allocated > a.effectiveBalance + 0.005   // float tolerance
    accountBreakdown += InvestmentAccountSlice(a.id, a.name, a.effectiveBalance, allocated, pending)

Per-class slice:
  totalInvested = Σ a.effectiveBalance for a in investmentAccounts
  for each class c in classes:
    currentAmount  = Σ liveHoldings.amount where assetClassId == c.id
    currentPercent = totalInvested == 0 ? 0 : currentAmount / totalInvested
    targetAmount   = totalInvested * c.targetPercent / 100
    deltaAmount    = targetAmount − currentAmount
    classBreakdown += InvestmentClassSlice(...)

Aggregates:
  totalAllocated = Σ liveHoldings.amount
  totalPending   = max(0, totalInvested − totalAllocated)
  targetSumPct   = Σ classes.targetPercent

Rebalance:
  for each class c in classes:
    if abs(c.deltaAmount) < tolerance(R$1): skip
    direction = deltaAmount > 0 ? buy : sell
    rebalanceActions += RebalanceAction(c.id, c.name, direction, abs(deltaAmount))
  sort descending by amount

  // If totalPending > 0, prepend a synthetic action labeled "Alocar pendente"
  // (handled in the UI, not in the algorithm — keeps the data layer pure).

Output:
  InvestmentOverview(...)
```

Complexity: O(A + C + H). No nested scans.

## 5. Repository Contracts

```dart
abstract class AssetClassRepository {
  Future<Either<Failure, List<AssetClassEntity>>> getAssetClasses({
    required String userId,
    bool forceRefresh = false,
  });
  Future<Either<Failure, AssetClassEntity>> createAssetClass(AssetClassEntity c);
  Future<Either<Failure, AssetClassEntity>> updateAssetClass(AssetClassEntity c);
  Future<Either<Failure, void>> deleteAssetClass(String id);
}

abstract class AssetHoldingRepository {
  Future<Either<Failure, List<AssetHoldingEntity>>> getAssetHoldings({
    required String userId,
    bool forceRefresh = false,
  });
  Future<Either<Failure, AssetHoldingEntity>> createAssetHolding(AssetHoldingEntity h);
  Future<Either<Failure, AssetHoldingEntity>> updateAssetHolding(AssetHoldingEntity h);
  Future<Either<Failure, void>> deleteAssetHolding(String id);
  Future<Either<Failure, void>> deleteHoldingsForAccount(String accountId);
  Future<Either<Failure, void>> deleteHoldingsForClass(String classId);
}
```

Caching strategy matches the rest of the app: `forceRefresh: false` →
local Drift; `forceRefresh: true` → Firestore → replace local. Create /
update writes to Firestore then upserts local; delete inverts.

## 6. Use Cases

| Use case                        | Notes                                                       |
|---------------------------------|-------------------------------------------------------------|
| `GetAssetClassesUseCase`        | Read-through to repository.                                 |
| `CreateAssetClassUseCase`       | Validates `name.isNotEmpty`, `targetPercent ∈ [0,100]`.     |
| `UpdateAssetClassUseCase`       | Same validations.                                            |
| `DeleteAssetClassUseCase`       | Pre-checks holdings (rule 5). Blocks with `ValidationFailure`.|
| `GetAssetHoldingsUseCase`       | Read-through.                                               |
| `CreateAssetHoldingUseCase`     | Validates account type, available balance, amount ≥ 0.      |
| `UpdateAssetHoldingUseCase`     | Same validations.                                            |
| `DeleteAssetHoldingUseCase`     | Plain delete.                                                |
| `GetInvestmentOverviewUseCase`  | Composes accounts + classes + holdings via the pure helper. |

## 7. State Machines

### `InvestmentsCubit` (page-scoped)

```text
State: { status, overview?, classes, holdings, failure? }

InvestmentsInitial
  ──loadInvestments──→ InvestmentsLoading
     → fetches accounts (forceRefresh), classes (forceRefresh), holdings (forceRefresh)
     → if any fails → InvestmentsError(failure)
     → composes via compute → InvestmentsLoaded(overview, classes, holdings)

InvestmentsLoaded
  ──refresh(forceRefresh)──→ InvestmentsLoading → ...
  ──onClassMutated──→ refresh (no spinner)  // optimistic
  ──onHoldingMutated──→ refresh (no spinner)
  ──removeHoldingsForAccount──→ delegates to repo, then refresh
```

The cubit is created once per session by the shell (so the dashboard
banner can read the pending sum without the user visiting the page).
On mount of the page, it does a `forceRefresh` to pick up changes.

### `AssetClassFormCubit` (page-scoped per use)

Single-state pattern (`FormStatus.initial | submitting | success |
failure`). Fields: `name`, `icon`, `color`, `targetPercent`,
`existingId?`. `isValid = name.isNotEmpty && targetPercent ∈ [0,100]`.

### `AssetHoldingFormCubit` (sheet-scoped per use)

Single-state pattern. Fields: `accountId`, `assetClassId`, `amount`,
`notes`, `existingId?`. `isValid = accountId != '' && assetClassId !=
'' && amount >= 0 && amount <= availableForAccount`. `availableForAccount`
is passed in at construction time (computed by the parent from the
current overview).

## 8. UI

### Route + entry points

- Route: `/investments`.
- Bottom nav (mobile, slot 1) and sidebar (second item) — both reuse
  the slot previously occupied by Bills.
- Optional deep link from the Dashboard "pendência" banner once
  added (V1.1 follow-up).

### Layout

```
┌─ Investimentos ───────────────────────────┐
│ Patrimônio: R$ 60.000                     │
│ Alocado: R$ 48.000 · Pendente: R$ 12.000  │
│ ⚠ R$ 12.000 não alocados [Distribuir]     │   ← only when totalPending > 0
└───────────────────────────────────────────┘

┌─ Alocação ────────────────────────────────┐
│ (donut: each slice = currentPercent)      │
└───────────────────────────────────────────┘

┌─ Classes ─────────────────────────────────┐
│ 🏠 Real Estate   R$ 30.000  (50%)         │
│    Alvo 25% · +R$ 15k acima               │
│    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                │
│                                            │
│ ₿ Bitcoin        R$ 5.000   (8%)          │
│    Alvo 25% · −R$ 10k abaixo              │
│    ▓▓▓░░░░░░░░░░░░░░░░░░                  │
└───────────────────────────────────────────┘

┌─ Rebalanceamento ─────────────────────────┐
│ Alocar R$ 12.000 pendentes                │   ← only when totalPending > 0
│ Vender R$ 15.000 de Real Estate           │
│ Comprar R$ 10.000 de Bitcoin              │
└───────────────────────────────────────────┘

┌─ Pendência por conta ─────────────────────┐
│ Conta XP    R$ 12.000 não alocados        │
│ [+ Alocar]                                 │
└───────────────────────────────────────────┘

[opcional] [Manutenção: 2 holdings órfãos]
```

### Header rules

- Hero shows `formatCurrency(totalInvested)` and the
  allocated/pending split.
- "⚠ não alocados" banner shows only when `totalPending > 0`. Tap
  routes to the per-account pending list.

### Class row

- Leading: round badge with icon+color from the class.
- Title: class name + current amount.
- Subtitle: "Alvo X% · ±R$Y absoluto" coloured red (over target) /
  green (close to target, within 5% of the target amount) / amber
  (under target).
- Linear progress bar: `currentPercent / max(currentPercent, targetFraction)`
  capped at 1.0 so over-target classes show a full bar (the delta
  copy carries the magnitude).

### Class detail page (`AssetClassDetailPage`)

Reached by tapping a class row; the app-bar pencil opens the class form.

- **Hero card**: the class's current amount, `actual% / target%` of the
  portfolio, a progress bar (`currentPercent / targetFraction`), the
  target amount, and the over/under/on-target delta.
- **Subclass list**: one `_SubclassCard` per subclass, accent stripe in
  the parent's colour (subclasses inherit it). Each card shows:
  - name;
  - a detail line `R$ X · actual% de target%` — the subclass's
    share of the class now vs. its `targetPercent`. Falls back to
    `R$ X · actual% da classe` when no target is set;
  - a suggestion line (add / trim / on-target / "set a target") derived
    from the suggested amount = `class.targetAmount × subclass.targetPercent / 100`;
  - an inline "Alocar" chip opening the holding sheet preset to the subclass.
- Trailing full-width "Adicionar subclasse" button; an empty state with
  the same CTA when the class has no subclasses.

There is **no donut** on this page — the per-subclass numbers carry the
breakdown; an early donut iteration was dropped as visual noise.

### Rebalance section

- One row per `RebalanceAction`, ordered by amount desc.
- Verb: "Vender" (sell) / "Comprar" (buy). Copy in i18n.
- If `targetSumPercent != 100 ± 0.1`, yellow banner pinned above:
  "Os alvos somam X% — ajuste para 100%."

### Empty states

| Scenario                                    | Render                                                            |
|---------------------------------------------|-------------------------------------------------------------------|
| No investment accounts at all               | Empty state with "Crie uma conta de investimento" CTA → /account/add. |
| Investment accounts but no classes          | Empty state with "Crie sua primeira classe" CTA → /investments/class/add. |
| Classes defined but no holdings, total > 0  | All money flagged as pending, banner prominent.                  |
| Classes defined and totalInvested == 0      | Donut + class rows render at 0% with "Comece a investir" hint.   |

### Forms

- **Class form** (`/investments/class/add` and `/investments/class/edit`):
  name, icon picker, color picker (same widgets as categories),
  targetPercent slider/text. Submit gated on validity. On submit
  success the page pops with `result == true` so the parent refreshes.
- **Holding sheet** (bottom sheet, opened from class row or from
  account pending row): account picker (investment accounts only),
  class picker (existing classes), amount field with "available"
  helper text, notes field. Validated against the available remainder.

### FAB

A single primary FAB opens a small "what to add" sheet with two
options ("Nova classe" / "Nova alocação"). This avoids two FABs and
keeps the layout clean on mobile.

### Pendência banner on Dashboard (V1.1, not in this slice)

Designed for a follow-up: when `totalPending > 0`, surface a chip on
the dashboard top section. Not implemented in V1 to keep this slice
self-contained.

## 9. Edge Cases

| Scenario                                                      | Behaviour                                                                                 |
|---------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| User adds a holding then withdraws cash (balance drops below holding) | `hasOverflow == true` for that account. Banner: "Holdings excedem saldo — reconcilie."     |
| User deletes an asset class with holdings                     | Blocked. `ValidationFailure` lists impacted holdings.                                     |
| User deletes an investment account                            | Holdings cascade-delete via the accounts cubit hook (best-effort, see rule 6).            |
| Class targets sum to 110%                                     | Banner shows. Overview still renders normally; rebalance amounts still use real percent. |
| Holding with `amount == 0`                                    | Counted in totals (no effect). Shown in the list with a muted style.                     |
| Orphan holding (accountId or classId missing)                 | Skipped by overview. Listed in the "Manutenção" section with a remove button.            |
| Two accounts, R$50k each, single class with target 100%       | totalInvested = 100k; allocate manually; targetAmount = 100k for the class.              |
| User has zero investment accounts but has classes             | Overview renders empty (no totals). Class rows show "R$ 0 · 0% · alvo X%".              |
| User edits holding amount to exceed remaining available       | Form blocks submit; helper text shows remainder.                                          |

## 10. Cross-feature wiring

- **AccountsCubit** — after a successful `deleteAccount`, invokes
  `InvestmentsCubit.removeHoldingsForAccount(deletedId)` (fire and
  forget — failures are logged but do not block the account delete).
  Provides the cascade required by rule 6.
- **Navigation refactor** — Bills/payables are no longer a Planning tab.
  Planning contains 50/30/20 and Orçamentos. Payables/receivables live as
  Dashboard sidebar children at `/payables-receivables` and
  `/paid-and-received`; legacy `/bills` redirects to
  `/payables-receivables` for deep-link/push compatibility.
- **Payables/receivables page** — remains transaction-backed and is no longer
  embedded in Planning.
- **Legacy Bills nav badge** — `nav_bills_badge.dart` is no longer rendered on
  the bottom/sidebar nav. Due/overdue payables should be surfaced through the
  transaction-backed payables/receivables entry.

## 11. Firestore

```
asset_classes/{id}     → userId, name, icon, color, targetPercent, createdAt
asset_holdings/{id}    → userId, accountId, assetClassId, amount, notes, updatedAt
```

**Indexes:** none. Both collections are queried with a single-field
`where('userId', isEqualTo: userId)` only — the remote datasources
deliberately skip server-side ordering (and the composite index it would
require) and sort in memory instead. See the comment in
`asset_class_remote_datasource.dart`.

Queries are always scoped by `userId`.

## 12. Drift

Two new tables (`LocalAssetClasses`, `LocalAssetHoldings`) and two
DAOs. Schema version bumps from 6 → 7. Migration drops + recreates
(local cache is disposable; Firestore re-sync repopulates).

## 13. Out of Scope (V1)

- Yield / market value / cotação real-time.
- Per-class historical chart (snapshots over time).
- Auto-creating transactions from accepted rebalance suggestions.
- Per-account class targets (only global targets in V1).
- Importing holdings from a broker CSV.
- AI chat actions for creating classes or holdings.
- Pendência banner on the Dashboard top section (deferred to V1.1).
