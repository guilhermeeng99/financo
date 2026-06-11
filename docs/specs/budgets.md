# Budgets Feature Spec

> **Status**: Implemented (shipped)
> **Last updated**: 2026-05-13
> **Coverage**: Entity, Business Rules, Repository, State Machines, UI, Edge Cases

A **budget** is a user-defined monthly cap on spending for a single root
expense category. Spending is computed from existing `transactions` records;
budgets do not duplicate that data — they only carry the cap and metadata.

**Scope decisions** (locked at design time):

- **Parent-only**: budgets attach to root categories. Subcategory spend rolls
  up into the parent's cap (mirrors dashboard rule 18 of [categories.md](categories.md)).
- **No rollover**: each month starts at the original cap. Underspend does not
  carry over.
- **Expense-only**: only categories of type `expense` can have a budget.
  Income targets (P1 "Metas de economia") are a separate feature.
- **Monthly period only**: weekly/yearly are out of scope for MVP.
- **No push alerts**: progress is visible in-app; FCM notifications come later.

Budgets live inside the **Planning** shell (`Planejamento` in the main
navigation) alongside the 50/30/20 planning views. See
docs/specs/fifty_thirty_twenty.md and docs/specs/investments.md for the
Planning shell layout.

---

## 1. Entity Contract

### BudgetEntity

| Field      | Type     | Nullable | Constraints                                                            |
|------------|----------|----------|------------------------------------------------------------------------|
| id         | String   | No       | Firestore document ID; empty on create                                 |
| userId     | String   | No       | Owner user ID                                                          |
| categoryId | String   | No       | References a `CategoryEntity` where `parentId == null && type == expense` |
| amount     | double   | No       | Monthly cap; must be `> 0`                                             |
| createdAt  | DateTime | No       | Set on creation                                                        |
| updatedAt  | DateTime | No       | Set on creation and update                                             |

`Equatable` + `copyWith`, same convention as the rest of the codebase.

### BudgetOverview (computed, presentation-layer entity)

Not persisted. Produced by `GetBudgetsOverviewUseCase` — the page renders this,
not raw `BudgetEntity`. Combining the budget with the current-month spend
gives every cell of the UI in one pass.

| Field         | Type           | Notes                                                  |
|---------------|----------------|--------------------------------------------------------|
| budget        | BudgetEntity   | The persisted budget                                   |
| categoryName  | String         | Resolved at compose time (categoryId → name)           |
| categoryIcon  | int            | Material icon code point                               |
| categoryColor | int            | ARGB color value                                       |
| spent         | double         | Sum of period expenses for the parent + its children   |
| remaining     | double         | `max(0, amount - spent)` — never negative              |
| overspent     | double         | `max(0, spent - amount)` — 0 unless exceeded           |
| percentage    | double         | `spent / amount` — uncapped (1.20 means 120%)          |
| status        | BudgetStatus   | safe / warning / exceeded                              |

### BudgetStatus (enum)

- `safe` — `percentage < 0.75`
- `warning` — `0.75 <= percentage < 1.0`
- `exceeded` — `percentage >= 1.0`

Color mapping at the UI layer (re-uses theme tokens, no new color constants):

- `safe` → `AppColors.income` (green)
- `warning` → amber/warning token
- `exceeded` → `AppColors.expense` (red)

---

## 2. Business Rules

1. **One budget per category**: a `(userId, categoryId)` pair is unique. Creating
   a second budget for the same category returns `Left(ValidationFailure)`.
2. **categoryId must reference a root expense category** at creation/edit time:
   `category.parentId == null && category.type == expense`. The form's category
   picker filters the list; the repository re-validates as a defensive check.
3. **categoryId is immutable after creation**. To change which category a
   budget covers, delete and recreate. The form hides the category selector in
   edit mode (same pattern as `type` on categories).
4. **Amount must be `> 0`**. The form rejects `<= 0` and non-numeric input.
5. **Spending calculation** (per month, per budget):
   - Filter transactions where `userId == budget.userId`
     `AND type == expense`
     `AND linkedTransactionId == null`  *(transfers excluded — same rule as dashboard)*
     `AND date ∈ [startOfMonth, endOfMonth]`
     `AND (categoryId == budget.categoryId OR category.parentId == budget.categoryId)`
   - Sum the `amount` field. That's `spent`.
6. **MVP shows the current real month only** — the dedicated `Orçamento` page
   does not have month navigation in V1. Past-month inspection is deferred to
   a later iteration.
7. **Cascade delete**: when a category is deleted, every budget referencing
   it is also deleted. Implementation lives in the *category delete cubit
   action*, which dispatches a budget delete after the category delete
   succeeds. Categories repository stays unaware of budgets (no reverse
   dependency).
8. **Orphan tolerance**: if a budget's `categoryId` no longer resolves
   (e.g. category deleted via another device before sync), the overview
   use case skips that budget silently and emits a debug log. The orphan
   row never reaches the UI.
9. **Default amount**: empty / R$ 0,00 — the form requires the user to type a
   value before submit is enabled (same UX as transaction amount fields).
10. **List ordering**: by `categoryName` ASC. Consistent with categories list.

---

## 3. Repository Contract

### BudgetRepository (abstract)

```dart
abstract class BudgetRepository {
  Future<Either<Failure, List<BudgetEntity>>> getBudgets({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity budget);

  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget);

  Future<Either<Failure, void>> deleteBudget(String id);
}
```

### Behavior

- **getBudgets**: Returns local cache by default. With `forceRefresh = true`,
  fetches from remote, replaces local cache, then returns local data. Sorted
  by `createdAt` ASC at the data layer; the use case re-sorts by category name
  after resolving categories.
- **createBudget**: Validates uniqueness (`userId + categoryId`) **at the
  repository level** before writing — load existing budgets from cache and
  return `ValidationFailure` if a duplicate is found. Writes to remote first,
  then upserts locally. Returns the created entity.
- **updateBudget**: Writes to remote first, then upserts locally. Does not
  re-validate uniqueness (categoryId is immutable so duplicates can't appear
  via update).
- **deleteBudget**: Remote first, then local. Idempotent — deleting a
  non-existent ID succeeds silently.
- **All methods**: catch `ServerException` → `Left(ServerFailure)`.

### Use Cases

```dart
class CreateBudgetUseCase {
  Future<Either<Failure, BudgetEntity>> call(BudgetEntity budget);
}

class UpdateBudgetUseCase {
  Future<Either<Failure, BudgetEntity>> call(BudgetEntity budget);
}

class DeleteBudgetUseCase {
  Future<Either<Failure, void>> call(String id);
}

class GetBudgetsUseCase {
  Future<Either<Failure, List<BudgetEntity>>> call({
    required String userId,
    bool forceRefresh = false,
  });
}

/// Composes budgets + transactions + categories into the presentation entity.
/// Mirrors `GetDashboardSummaryUseCase`'s composition pattern.
class GetBudgetsOverviewUseCase {
  Future<Either<Failure, List<BudgetOverview>>> call({
    required String userId,
    required DateTime month,    // any DateTime within the target month
    bool forceRefresh = false,
  });
}
```

`GetBudgetsOverviewUseCase` algorithm:

1. Fetch budgets, categories, period transactions in sequence (same fold
   pattern as `DashboardRepositoryImpl`).
2. Build a `Map<String, double>` of `categoryId → spent`, walking transactions
   once. Skip transfers and non-expense rows up front.
3. For each budget:
   - Resolve the parent category (`categories.firstWhereOrNull`). If missing,
     skip (orphan tolerance, rule 8).
   - Compute `spent` as `parentSpent + sum(childSpent)` where children are
     categories with `parentId == budget.categoryId`.
   - Compose the `BudgetOverview`.
4. Sort by category name and return.

### Data Source Contract

```dart
abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets({required String userId});
  Future<BudgetModel> createBudget(BudgetModel model);
  Future<BudgetModel> updateBudget(BudgetModel model);
  Future<void> deleteBudget(String id);
}
```

`getBudgets` queries Firestore where `userId == userId`, ordered by
`createdAt` ASC.

### Local Cache (BudgetsDao)

- `getBudgets(userId)` — by userId.
- `upsertBudget(entity)` — insert or update on conflict.
- `insertAllBudgets(list)` — batch insert/update.
- `deleteBudget(id)` — by id.
- `deleteAllBudgets()` — full clear (used by sign-out).

---

## 4. State Machines

### BudgetsCubit (list + delete)

```
States:
  BudgetsInitial
  BudgetsLoading
  BudgetsLoaded(overviews: List<BudgetOverview>, month: DateTime)
  BudgetsError(failure: Failure)

Transitions:
  loadBudgets({forceRefresh = false}):
    Initial          → Loading → Loaded | Error
    Loaded + !force  → no-op (returns early)
    Loaded + force   → Loading → Loaded | Error

  deleteBudget(id):
    Loaded → call DeleteBudgetUseCase
           → on success: re-dispatch loadBudgets(forceRefresh: true)
           → on failure: emit BudgetsError, then re-emit prior Loaded
                          so the page stays usable
```

The cubit does **not** own a `month` selector in MVP — `month` is always
`DateTime.now()` at load time. When month navigation lands later, this becomes
a public method `selectMonth(DateTime)` that re-runs the overview pipeline.

### BudgetFormCubit (form management)

```
FormStatus enum: initial | submitting | success | failure

State fields:
  userId, categoryId?, amount, status, existingId?, failure?

Computed:
  isEditing = existingId != null
  isValid = categoryId != null && amount > 0 && (!isEditing || true)

Field updates:
  updateCategoryId(String?)  // create mode only — hidden in edit
  updateAmount(double)

submit():
  if !isValid → no-op
  → emit(submitting)
  → isEditing ? UpdateBudgetUseCase : CreateBudgetUseCase
  → success → emit(success)
  → failure → emit(failure + Failure)

Initial state (create mode):
  categoryId: null, amount: 0, status: initial

Initial state (edit mode):
  categoryId: existing.categoryId, amount: existing.amount,
  existingId: existing.id
  Category selector is HIDDEN (immutable post-creation)
```

---

## 5. Model Serialization

### BudgetModel

```
toJson() → Map<String, dynamic>:
  { userId, categoryId, amount, createdAt: Timestamp, updatedAt: Timestamp }
  Note: 'id' is NOT included (Firestore doc ID is separate)

fromFirestore(DocumentSnapshot) → BudgetModel:
  Reads doc.id as id, all other fields from doc.data().
  amount: (num).toDouble()
  createdAt / updatedAt: Timestamp → DateTime

fromEntity(BudgetEntity) → BudgetModel:
  Direct field mapping.
```

---

## 6. Firestore

**Collection**: `budgets/{id}`

**Indexes** (composite):

- `userId` ASC + `createdAt` ASC — required because the remote datasource
  orders by `createdAt` for stable retrieval. Mirrors the same composite
  shape used by `accounts` and `chat_messages` in `firestore.indexes.json`.

**Security rules** (drop in alongside the existing user-owned collections):

```
match /budgets/{id} {
  allow read, write: if request.auth != null
                     && request.auth.uid == resource.data.userId;
  allow create: if request.auth != null
                && request.auth.uid == request.resource.data.userId;
}
```

---

## 7. UI

### Navigation

A new top-level tab labeled **Orçamento** is added to:

- `FinancoMobileNav` — bottom bar entry in the Planning area.
- `FinancoSidebar` — sidebar entry, same position.

Route: `/budgets` (registered inside the `ShellRoute`).

### Pages

- `BudgetsPage` (`/budgets`) — list of overviews + FAB to add.
- `AddBudgetPage` (`/budget/add`, `/budget/edit`) — form.

### `BudgetsPage` layout

- App bar title: `t.budgets.title` ("Orçamento").
- If `Loaded` and overviews is empty → `EmptyState` with CTA "Criar primeiro
  orçamento" → routes to `/budget/add`.
- If `Loaded` and overviews is non-empty → `ListView` of `BudgetTile`s.
- A summary header card on top:
  - Total cap (sum of `amount`)
  - Total spent (sum of `spent`)
  - Total remaining (sum of `remaining`)
  - All formatted via `formatCurrency`.
- FAB: `LiftedFab` ("Novo orçamento") → `/budget/add`.

### `BudgetTile`

A single row showing:

- Leading: `FinancoCategoryAvatar` (icon + color from the category).
- Title: `categoryName`.
- Subtitle: `formatCurrency(spent)` / `formatCurrency(amount)` ·
  `${(percentage * 100).toStringAsFixed(0)}%`.
- A `LinearProgressIndicator` clamped to `[0, 1]` colored per `BudgetStatus`.
- Trailing: chevron, taps open `/budget/edit`.
- Swipe-to-delete (mobile) or trailing icon button (web) → confirms then
  dispatches `deleteBudget`.

### `AddBudgetPage`

- App bar title: `t.budgets.create` ("Novo orçamento") or `t.budgets.edit`
  ("Editar orçamento") in edit mode.
- Form sections:
  - **Categoria** (`FinancoPickerField`) — opens a bottom sheet listing root
    expense categories. Categories that already have a budget are filtered
    out in create mode. **Hidden in edit mode** (rule 3).
  - **Valor** (`FinancoCurrencyField`) — BR currency input.
- Submit bar (`FinancoSubmitBar`) — disabled while `!isValid` or
  `status == submitting`.
- On `success` → `context.pop()`, the `BudgetsPage` re-loads.
- On `failure` → snackbar with the failure message; form stays open.

### Cascade delete (categories)

`CategoriesCubit.deleteCategory` is extended to also dispatch
`DeleteBudgetUseCase` for every budget whose `categoryId` matches the deleted
category. The categories cubit takes a `BudgetRepository` (or `GetBudgetsUseCase`
+ `DeleteBudgetUseCase`) injection. Failures during budget cascade are
**logged but not surfaced** — the category deletion is the user's primary
intent and budgets being orphaned is recoverable (rule 8).

---

## 8. Edge Cases

| Scenario                                                          | Expected Behavior                                                                          |
|-------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| Empty budgets list                                                | EmptyState with CTA                                                                        |
| Server failure on load                                            | ErrorView with retry                                                                       |
| Server failure on create / update / delete                        | Form/page stays open, snackbar with the failure message                                    |
| Submit with no category selected                                  | Submit disabled, no API call                                                               |
| Submit with amount = 0                                            | Submit disabled                                                                            |
| Create budget for a category that already has one                 | Repository returns `ValidationFailure('Já existe um orçamento para essa categoria')`       |
| Delete category with a budget                                     | Cascade-delete the budget; failure is logged but not surfaced                              |
| Budget references deleted category (orphan)                       | Filtered out of overview silently                                                          |
| Transactions with `linkedTransactionId != null` (transfers)       | Excluded from `spent` calculation                                                          |
| Transactions of type `income` in an expense category (data drift) | Excluded from `spent` calculation (only `expense` rows count)                              |
| Subcategory transaction                                           | Counts toward parent budget's `spent` (rolls up via `category.parentId == budget.categoryId`) |
| User's only category that has a budget gets re-typed              | Cannot happen — `CategoryType` is immutable post-creation                                  |
| `forceRefresh` with empty remote                                  | Local cache cleared, returns empty list                                                    |
| Edit budget                                                       | Category selector hidden, only `amount` editable                                           |
| Two devices create a duplicate budget concurrently                | Last writer wins; the orphan/duplicate is reconciled on next sync. Considered acceptable for single-user MVP. |

---

## 9. Testing Checklist

- **Repository** (mocked datasource + local DAO):
  - `createBudget` rejects duplicates by `(userId, categoryId)`.
  - `getBudgets` returns local cache when `forceRefresh = false`.
  - `getBudgets` re-syncs from remote when `forceRefresh = true`.
  - All methods translate `ServerException` → `ServerFailure`.
- **GetBudgetsOverviewUseCase**:
  - Sums root + subcategory transactions correctly.
  - Excludes transfers.
  - Excludes income transactions.
  - Skips orphan budgets (deleted category).
  - `percentage` reflects uncapped ratio (overspend > 100% reported).
  - `status` boundaries: 0.74 → safe, 0.75 → warning, 1.00 → exceeded,
    1.50 → exceeded.
- **BudgetsCubit** (`bloc_test`):
  - `loadBudgets` happy path emits `Loading → Loaded`.
  - `loadBudgets` failure emits `Loading → Error`.
  - `loadBudgets` no-ops when already loaded and `!forceRefresh`.
  - `deleteBudget` triggers a force-refresh on success.
- **BudgetFormCubit**:
  - `isValid` reflects `categoryId != null && amount > 0`.
  - Submit dispatches Create vs Update based on `existingId`.
  - Failure preserves form state.
- **CategoriesCubit cascade**:
  - Deleting a category with a budget deletes the budget.
  - Deleting a category without a budget is unaffected.
  - Budget cascade failure does not abort the category deletion.

---

## 10. AI Chat Integration

The in-app chat emits a `[BUDGET_ACTION]` block. Same Confirm-button
pattern as transactions and accounts.

### Action shapes

```
[BUDGET_ACTION]
{"action": "create", "category": "Alimentação", "amount": 1500.00}
[/BUDGET_ACTION]

[BUDGET_ACTION]
{"action": "update", "category": "Alimentação", "amount": 2000.00}
[/BUDGET_ACTION]

[BUDGET_ACTION]
{"action": "delete", "category": "Alimentação"}
[/BUDGET_ACTION]
```

The `category` field is the **exact category name** as listed in USER
CONTEXT. The Flutter handler resolves the name → category id locally; the
AI never sees or emits ids.

### Preflight (client-side, before showing the Confirm card)

Same defensive pattern as transactions: validate before the user taps
Confirm so the card is a contract, not a guess. Rejects when:

- `category` is empty or unresolved.
- The resolved category is `income` (rule 2).
- The resolved category is a sub-category (rule 2).
- `action == 'create'` but a budget already exists for that category (rule 1).
- `action == 'update' | 'delete'` but no budget exists for that category.
- `action == 'create' | 'update'` and `amount <= 0`.

### USER CONTEXT injection

The Cloud Function `chat/context.ts` adds an "Orçamentos mensais ativos"
section listing every active budget by `categoryName → R$amount/mês`. The
AI uses this to disambiguate `create` from `update` and to never duplicate
a budget for an already-budgeted category.

### Refresh after confirm

`ChatBloc.ChatLoaded` carries a `shouldRefreshBudgets` flag. The chat page
listens and triggers `BudgetsCubit.loadBudgets(forceRefresh: true)` so the
budgets tab reflects the change without a manual reload.

## 11. CSV Import

Bulk-creates budgets from a 2-column CSV via `ImportBudgetsCsvUseCase` (wired
through `BudgetsCubit`). Sample: `lib/app/assets/samples/budgets_example.csv`
(`Category,Amount`).

Fields are located by **header name** (accent- and case-insensitive), not by
column position; extra/reordered columns are tolerated.

| Logical field | Accepted headers (any of) | Format |
|---|---|---|
| category (required) | `Categoria`, `Category` | Must match an existing **root expense** category by name (case-insensitive). |
| amount (required) | `Valor`, `Amount`, `Value`, `Cap`, `Limite`, `Monthly cap`, `Valor mensal` | Number (BR `1.234,56` or EN `1,234.56` style); must be `> 0`. |

Resolution is **tolerant** — a row is *skipped* (counted in `skippedCount`, not
fatal) when its category does not match a root expense category, already has a
budget (uniqueness is `(userId, categoryId)`), or is duplicated earlier in the
same file.

**Strict failures** raise `ValidationFailure` and abort the whole import: a
missing `category`/`amount` header, an invalid or zero amount, or a file with no
valid rows.

Result: `BudgetImportResult { importedCount, skippedCount }`.

## 12. Out of Scope (V1)

These are deliberately deferred — not because they're hard, but because each
adds modeling complexity that's better tackled once V1 has shipped and we have
real usage signal:

- **Rollover** (carry under/overspend month-to-month).
- **Per-month versioning** (different cap in March vs. April).
- **Subcategory-level budgets** (orçar Delivery separadamente de Mercado).
- **Income / savings targets** — separate "Metas" feature in roadmap P1.
- **Push notifications on threshold** — uses existing FCM infra, but
  intentionally postponed.
- **Month navigation on the budgets page** — current month only.
- **Budget templates** ("default budget" applied to new categories).
