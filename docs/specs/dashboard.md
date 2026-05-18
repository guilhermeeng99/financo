# Dashboard Feature Spec

Monthly financial summary view. Aggregates account balances, income/expenses, and category breakdowns for a selected month.

## Entities

### CategoryAmount

| Field | Type | Notes |
|-------|------|-------|
| categoryId | String | Aggregation key (parent category id, or original id when category is missing) |
| categoryName | String | Display name, fallback: "No Category" |
| categoryColor | int | Material color int, fallback: 0xFF9E9E9E |
| amount | double | Aggregated total |

Extends `Equatable`.

### DashboardSummary

| Field | Type | Notes |
|-------|------|-------|
| totalBalance | double | Sum of all adjusted account balances |
| totalIncome | double | Period income only (selected month) |
| totalExpenses | double | Period expenses only (selected month) |
| netResult | double | `totalIncome - totalExpenses` |
| accounts | List\<AccountEntity\> | Adjusted with cumulative transactions |
| expensesByCategory | List\<CategoryAmount\> | Sorted descending by amount |
| incomeByCategory | List\<CategoryAmount\> | Sorted descending by amount |
| fiftyThirtyTwenty | FiftyThirtyTwentyOverview | Per-period 50/30/20 split, computed via `compute50_30_20Overview`. See [fifty_thirty_twenty.md](fifty_thirty_twenty.md). |

Extends `Equatable`.

## Repository: DashboardRepository

| Method | Parameters | Return |
|--------|-----------|--------|
| getDashboardSummary | userId, month, forceRefresh? | `Either<Failure, DashboardSummary>` |

### DashboardRepositoryImpl

**Dependencies**: TransactionRepository, AccountRepository, CategoryRepository.

**Algorithm**:
1. Fetch accounts (all), transactions (all up to end of month), categories (all) — in sequence
2. If any fetch fails → return Left(failure)
3. Compute cumulative account adjustments from ALL transactions (income adds, expense subtracts)
4. Adjust each account's `initialBalance` with cumulative adjustment via `copyWith`
5. Filter transactions to selected month only (period = startOfMonth to endOfMonth)
6. Compute `totalBalance` (sum of adjusted accounts), `totalIncome`, `totalExpenses` from period transactions — **excluding transfers**
7. Compute `netResult = totalIncome - totalExpenses`
8. Aggregate expenses and income by category (sorted descending by amount) — **excluding transfers**
9. Compute `fiftyThirtyTwenty` by calling the pure function `compute50_30_20Overview(periodTransactions, categories, accounts)` — single pass, no extra IO. See [fifty_thirty_twenty.md](fifty_thirty_twenty.md) for the algorithm.
10. Return Right(DashboardSummary)

### Business Rules

1. **Cumulative balance**: Account balances reflect ALL transactions up to the end of the selected month, not just the selected month's transactions. This gives the "running balance" at that point in time.
2. **Period income/expenses**: Only transactions within the selected month (startOfMonth..endOfMonth) count toward income and expense totals.
3. **Transfer exclusion**: Transfers (`isTransfer = true`, i.e. `linkedTransactionId != null`) are excluded from `totalIncome`, `totalExpenses`, `netResult`, and all category aggregations. They still contribute to cumulative account balance adjustments.
4. **Category aggregation**: Transactions grouped by categoryId, summed. Sorted descending by amount. Missing categories use fallback name "Sem categoria" and color 0xFF9E9E9E.
5. **Error propagation**: Triple-nested fold — any upstream failure short-circuits to Left.

## Use Case

`GetDashboardSummaryUseCase.call(userId, month, forceRefresh?)` — thin delegator to repository.

## DashboardBloc State Machine

### Events

| Event | Fields | Notes |
|-------|--------|-------|
| DashboardLoadRequested | forceRefresh, year?, month? | year/month default to now |
| DashboardRefreshRequested | — | Forces refresh of current month |

### States

| State | Fields |
|-------|--------|
| DashboardInitial | — |
| DashboardLoading | — |
| DashboardLoaded | summary, periodTransactions (full list for the selected month), selectedYear, selectedMonth |
| DashboardError | failure |

### Transitions

**DashboardLoadRequested:**
1. If already `DashboardLoaded` with same year/month and !forceRefresh → no-op (return)
2. Emit `DashboardLoading`
3. Call `getDashboardSummary(userId, month, forceRefresh)`
4. Call `getTransactions(userId, startDate, endDate, forceRefresh)` for period
5. If summary fails → emit `DashboardError`
6. If transactions fail → emit `DashboardError`
7. Otherwise → emit `DashboardLoaded` with the full list of period transactions (used by the per-category drill-down dialog)

**DashboardRefreshRequested:**
1. Use current year/month if loaded, else DateTime.now()
2. Call `_loadDashboard` with forceRefresh: true
3. (No Loading state emitted — goes directly to Loaded/Error)

## Edge Cases

1. **Empty accounts**: totalBalance = 0, accounts list empty.
2. **Empty transactions**: all totals = 0, no category breakdowns.
3. **Missing category**: uses "Sem categoria" fallback with grey color.
4. **Same month no-op**: DashboardLoadRequested with same year/month skipped unless forceRefresh.
5. **Account with no transactions**: adjustment = 0, balance stays as initialBalance.

## Account selection (dashboard "Total")

The dashboard's "Total Balance" is no longer shown as a hero number on top of the page. Instead, the **Account Balances** section (checking + investment combined — both share the positive-sign convention and represent money held) trails a **Total** row that lives below the list and reflects the sum of the **selected** accounts. Credit cards stay in their own section because their sign convention is inverted.

`DashboardAccountSelectionCubit` (in `lib/features/dashboard/presentation/cubit/dashboard_account_selection_cubit.dart`) owns the selection:

- State: `Set<String> excludedIds` — accounts the user has muted from the total.
- `toggle(accountId)` — flips inclusion and persists immediately.
- Persistence: `SharedPreferences`, keyed by `dashboard.excluded_accounts:<userId>` so two users on the same device don't share selections.
- Default: empty set (every account counts toward the total). Newly created accounts therefore opt-in automatically.

Each row in the checking section renders a leading `Checkbox`. Unticking it adds the account to `excludedIds` and visually mutes the row (50% opacity) without removing it from the list — the user can see what they hid and re-enable it without leaving the page. Credit card rows do not show the checkbox; they have no live total.

The `summary.totalBalance` field on `DashboardSummary` is still computed (sum of all adjusted accounts) for the entity contract, but it is no longer displayed.

## Category drill-down dialog

Tapping a row in the **Expenses by Category** list opens a modal dialog scoped to that parent category. The dialog has two tabs:

- **Lista de lançamentos** — every period transaction whose `categoryId` equals the parent category id, OR whose category's `parentId` equals the parent category id. Sorted by date descending. Transfers are excluded. A `Total` row aggregates the listed amounts.
- **Subcategorias** — subcategory bar chart + list with per-subcategory percentage. Aggregation key is each transaction's `categoryId`. Transactions booked directly on the parent category are intentionally skipped (they only appear in the transactions tab).

The dialog title displays `<categoryName> (<percentage of totalExpenses>%)`. The dialog reads category metadata from `CategoriesCubit` and account names from `AccountsCubit`.
