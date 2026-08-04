# Transactions Feature Spec

## Entity Contract

```dart
TransactionEntity {
  id:                    String          (required, Firestore doc ID)
  userId:                String          (required, owner)
  accountId:             String          (required, linked account)
  categoryId:            String          (required for income/expense; empty for transfers)
  type:                  TransactionType (required: income | expense)
  amount:                double          (required, > 0)
  description:           String          (required, may be empty)
  date:                  DateTime        (required; future allowed only when pending)
  settlementStatus:      TransactionSettlementStatus (pending | paid, default paid)
  dueDate:               DateTime        (defaults to date)
  settledAt:             DateTime?       (set when paid)
  recurrence:            TransactionRecurrence (single | installment | fixed)
  recurrenceGroupId:     String?         (same value for a generated sequence)
  recurrenceIntervalMonths: int          (defaults to 1, monthly cadence)
  // No `currency` field: a transaction's currency IS its account's currency
  // (multi_currency_accounts.md D1/§3.2). The two legs of a cross-currency
  // transfer are each native to their own account.
  recurrenceIndex:       int?            (1-based occurrence index)
  recurrenceTotal:       int?            (installment total; null for fixed)
  recurrenceBaseDescription: String?     (description without installment marker)
  recurrenceEndDate:     DateTime?       (fixed series stop boundary)
  notes:                 String?         (optional free-text)
  linkedTransactionId:   String?         (optional, non-null for transfers)
  institutionId:         String?         (F8 — set on an investment aporte/resgate)
  linkedInvestmentTransactionId: String? (F8 — the buy/sell that generated this row)
  createdAt:             DateTime        (required, set on creation)
  updatedAt:             DateTime        (required, set on creation and update)
}

bool get isTransfer => linkedTransactionId != null
bool get isInvestmentCashFlow => institutionId != null
bool get isRecurring => recurrence != single
bool get isPending => settlementStatus == pending
bool get isPaid => settlementStatus == paid
bool get isPayable => type == expense
bool get isReceivable => type == income
bool get isOverdue => isPending && day(dueDate) < day(now)
bool get isDueToday => isPending && day(dueDate) == day(now)

// Scope selector passed to sequence-aware edit/delete flows (rule 18):
enum TransactionSequenceScope { onlyThis, thisAndFollowing }

```

## Business Rules

1. **Description is optional** — may be empty.
2. **Amount must be positive** — `amount > 0`.
3. **Account is required** — `accountId` must be non-empty.
4. **Category is required for income/expense** — `categoryId` must be non-empty. Transfers have empty categoryId.
5. **Paid date cannot be in the future** — pending transactions can use a future `dueDate`.
6. **Transaction type (income/expense) is immutable after creation** — same pattern as categories/accounts.
7. **Transactions are ordered by date descending** in both Firestore and local cache queries.
8. **Transactions support filtering** by: date range (startDate/endDate), accountId, categoryId.
9. **Default type is expense** for new transactions.
10. **Reassign transactions** — bulk operation that moves all transactions from one category to another (used when deleting a category).
11. **Pending transactions do not affect financial totals** — balances, dashboard, budgets, account statements, investments, and 50/30/20 use `tx.isPaid`.
12. **Future dates auto-schedule** — the form switches to `pending` when the selected date is in the future.
13. **Repetition modes** — normal transactions support `single`, `installment`, and `fixed`. Transfers are always single and paid.
14. **Installments use the total purchase amount** — the form amount is split into per-installment rows. Cents are distributed from the first installment onward so the row sum equals the original total.
15. **Installment descriptions include markers** — generated rows append `1/N`, `2/N`, ... to the base description.
16. **Fixed transactions are materialized as a rolling window** — the user intent is permanent, but the app only creates occurrences through the next 12 months. `EnsureFixedRecurrencesUseCase` tops up the window on each transactions/dashboard load, so the series stays filled without creating unbounded Firestore documents.
17. **Only the first occurrence follows the current paid/pending toggle** — generated future occurrences are always pending/scheduled.
18. **Sequence edits/deletes are scoped** — editing/deleting a sequence row asks whether to affect only this row or this row and following rows. The following scope only changes pending rows with `dueDate >= selected.dueDate`; paid rows are not changed financially.

### Transfer Rules

19. **Transfers create two linked transactions** — an expense on the source account and an income on the destination account, linked by `linkedTransactionId`. Each leg's `amount` is **native to its own account's currency** (see Cross-Currency Rules below); for the same-currency case — every transfer before F9.5 — the two amounts are equal.
20. **Transfers have no category** — `categoryId` is empty string for both sides.
21. **Deleting one side of a transfer deletes both** — cascading delete at the repository level.
22. **Editing a transfer updates both legs** — amount (and, cross-currency, the destination amount), date, description, notes, **source account, and destination account** can all be changed; type stays immutable (the pill toggle is disabled in edit mode). Both the expense and income legs are rewritten so they never diverge. Each leg keeps its own `createdAt` (audit trail). The two writes are sequential, not atomic — a failure between them can leave the legs inconsistent (mirrors the non-batched create path; a repository-level transfer update is the proper fix).
23. **Transfer edit resolves the counterpart leg on open** — the form receives only the tapped leg. It fetches the linked leg (`GetTransactionUseCase`) to populate both source (expense leg) and destination (income leg) accounts **and both leg amounts**, regardless of which leg was tapped. `existingId` is normalized to the expense leg, `linkedTransactionId` to the income leg. On fetch failure the unknown account stays empty (form invalid) rather than guessing.
24. **Source and destination accounts must differ** — validated in form state.

### Cross-Currency Transfer Rules (F9.5)

A transfer between accounts in different currencies is the only place where the
two legs legitimately carry different numbers. See
[multi_currency_accounts.md](multi_currency_accounts.md) D4 / rule 6 for the
money model; these are the transaction-side contracts.

25. **`amount` always means the source (expense-leg) amount; `destinationAmount` always means the far side.** `TransactionFormState._forTransferEdit` routes the tapped leg into the matching field — tapping the **income** leg seeds `destinationAmount` and leaves `amount` at 0 until the counterpart arrives. Without this the form would submit the tapped leg's figure on both sides and silently rewrite the other currency's stored value.
26. **`isCrossCurrency = isTransfer && accountCurrency != destinationCurrency`.** Currencies are resolved from the account list, not from the transaction (a `TransactionEntity` has no currency field — its currency *is* its account's, see [multi_currency_accounts.md](multi_currency_accounts.md) §3.2).
27. **The received amount is required when the currencies differ** — `isValid` adds `isCrossCurrency && destinationAmount > 0`. A same-currency transfer ignores `destinationAmount` entirely and reuses `amount` on both legs (`_assembleTransferLeg` is called with `amount: state.isCrossCurrency ? state.destinationAmount : null`, and `null` falls back to `state.amount`).
28. **Currency resolution is best-effort and order-independent.** `_loadAccountCurrencies` maps account id → currency once via `GetAccountsUseCase`; a miss (or a failed load) defaults to `Currency.brl`, so cross-currency simply isn't detected rather than blocking the form. `_resolveTransferCounterpart` re-resolves **both** currencies itself, because the account it fills in is half of the cross-currency test — the two async paths may land in either order and both converge on the same answer.
29. **No FX rate is stored.** Only the two leg amounts are persisted; the implied rate is whatever the user entered. This is the one place in the app where a specific conversion is recorded (`multi_currency_accounts.md` §1, "Key simplification").

## Repository Contract

```dart
abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueStartDate,
    DateTime? dueEndDate,
    String? categoryId,
    String? accountId,
    TransactionSettlementStatus? settlementStatus,
    TransactionRecurrence? recurrence,
    String? recurrenceGroupId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, TransactionEntity>> getTransaction(String id);

  Future<Either<Failure, TransactionEntity>> createTransaction(TransactionEntity transaction);

  Future<Either<Failure, List<TransactionEntity>>> createTransactions(List<TransactionEntity> transactions);

  Future<Either<Failure, TransactionEntity>> updateTransaction(TransactionEntity transaction);

  Future<Either<Failure, List<TransactionEntity>>> updateTransactions(List<TransactionEntity> transactions);

  Future<Either<Failure, void>> deleteTransaction(String id);

  Future<Either<Failure, void>> deleteTransactions(List<String> ids);

  Future<Either<Failure, List<TransactionEntity>>> createTransfer({
    required TransactionEntity expense,
    required TransactionEntity income,
  });

  Future<Either<Failure, void>> reassignTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  });
}
```

Settlement use case:

```dart
class SettleTransactionUseCase {
  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction, {
    DateTime? settledAt,
  });
}
```

It rejects transfers with a `TransferNotSettleableFailure`, then updates the
same transaction to `paid`, stamps `settledAt` and `updatedAt` with the
confirmation instant (`settledAt ?? DateTime.now()`), and **leaves `date` on
the row's `dueDate`** — the movement keeps belonging to the month it was
scheduled for. Writing goes through `TransactionRepository.updateTransaction`.
See [payables_receivables_refactor.md](payables_receivables_refactor.md)
rule 8 for why, and rule 4 for the paid-with-a-future-date consequence.

**Cache strategy:**
- `forceRefresh: false` → read from local Drift cache only (with filters).
- `forceRefresh: true` → fetch from Firestore (with filters), **upsert** into local cache (not replace-all), then read local.
- `getTransaction` → try local first, fallback to remote + cache.
- Create/update → write to remote, then upsert local cache.
- Batch create/update/delete → Firestore batch, then mirror the changed rows in Drift.
- Delete → if linked (transfer), delete both sides from remote + local. Otherwise delete single.
- `createTransfer` → create both in Firestore (batch), link them by ID, upsert both locally.
- `reassignTransactions` → batch update in Firestore only (Drift cache becomes stale; caller must force-refresh).

**Key difference from accounts/categories:** `getTransactions` with `forceRefresh` uses `insertAllOnConflictUpdate` (upsert), NOT delete-then-insert.

## Model Serialization

**Firestore → Model (`fromMap`):**

| Firestore field | Dart field | Type cast |
|---|---|---|
| `userId` | `userId` | `String` |
| `accountId` | `accountId` | `String` |
| `categoryId` | `categoryId` | `String` |
| `type` | `type` | `TransactionType.values.byName(String)` |
| `amount` | `amount` | `(num).toDouble()` |
| `description` | `description` | `String` |
| `date` | `date` | `Timestamp → DateTime` |
| `settlementStatus` | `settlementStatus` | `String → TransactionSettlementStatus`, default `paid` |
| `dueDate` | `dueDate` | `Timestamp → DateTime`, fallback to `date` |
| `settledAt` | `settledAt` | `Timestamp? → DateTime?` |
| `recurrence` | `recurrence` | `String → TransactionRecurrence`, default `single`; legacy `oneShot` loads as `single`, legacy `monthly` as `fixed` |
| `recurrenceGroupId` | `recurrenceGroupId` | `String?` |
| `recurrenceIntervalMonths` | `recurrenceIntervalMonths` | `int`, default `1` |
| `recurrenceIndex` | `recurrenceIndex` | `int?` |
| `recurrenceTotal` | `recurrenceTotal` | `int?` |
| `recurrenceBaseDescription` | `recurrenceBaseDescription` | `String?` |
| `recurrenceEndDate` | `recurrenceEndDate` | `Timestamp? → DateTime?` |
| `notes` | `notes` | `String?` |
| `linkedTransactionId` | `linkedTransactionId` | `String?` |
| `createdAt` | `createdAt` | `Timestamp → DateTime` |
| `updatedAt` | `updatedAt` | `Timestamp → DateTime` |

**Model → Firestore (`toJson`):**
- Serializes all fields except `id`.
- DateTime fields serialized as `Timestamp`.
- `type`, `settlementStatus`, and `recurrence` serialized as `.name` strings.

## State Machines

### TransactionsBloc (event-driven)

```
Events:
  TransactionsLoadRequested { forceRefresh, year, month }
  TransactionDeleteRequested { id }

States:
  Initial → Loading → Loaded { transactions, selectedYear, selectedMonth }
                    → Error { failure }

Load behavior:
  - If already Loaded for same year/month AND !forceRefresh → no-op
  - Otherwise → Loading → EnsureFixedRecurrencesUseCase tops up the fixed
    rolling window (optional dep; awaited before the fetch, result ignored)
    → fetch with date range [startOfMonth, endOfMonth] → Loaded or Error

Delete behavior:
  - Delete the transaction (cascades if transfer) → on success, re-dispatch LoadRequested(forceRefresh: true)
  - On failure → Error

Default year/month: DateTime.now() when not specified in event.
```

### TransactionFormCubit

```
State: { userId, type, amount, description, date, accountId, categoryId,
         destinationAccountId, notes, status, settlementStatus, recurrence,
         recurrenceGroupId?, recurrenceIntervalMonths, recurrenceIndex?,
         recurrenceTotal?, recurrenceBaseDescription?, recurrenceEndDate?,
         installmentCount,
         isTransfer,
         accountCurrency, destinationCurrency, destinationAmount,
         existingId?, linkedTransactionId?,
         originalDueDate?, originalTransaction?,
         originalCreatedAt?, destinationCreatedAt?,
         savedTransactionId?, continueAfterSave, failure? }

  // accountCurrency      = source account's currency  (default brl)
  // destinationCurrency  = destination account's currency (default brl)
  // destinationAmount    = amount landing on the far side, in destinationCurrency
  //                        (cross-currency transfers only — Transfer Rules 25–29)
  // originalDueDate      = the edited row's dueDate at form-open time
  // originalTransaction  = the whole edited entity; backs isSequenceMember and
  //                        the "this and following" sequence update
  // originalCreatedAt    = expense-leg createdAt (preserved on update)
  // destinationCreatedAt = income-leg createdAt (preserved on transfer update)

Deps: createTransaction, updateTransaction, createTransfer, getTransaction,
      getAccounts (GetAccountsUseCase — resolves account id → currency)
Deps also include batch recurring create/update/delete use cases
      (createTransactions?, updateTransactionSequence?).

isEditing        = existingId != null
isTransfer       = state.isTransfer flag (or linkedTransactionId != null on existing)
isSequenceMember = originalTransaction?.isRecurring ?? recurrence != single
isCrossCurrency  = isTransfer && accountCurrency != destinationCurrency

On construct (always):
  _loadAccountCurrencies() → getAccounts → map id → currency, then re-emit
  only if a resolved currency actually differs (a no-op first emit would
  surface as a spurious duplicate state).

On construct (editing a transfer):
  fetch the linked leg via getTransaction → fill the unknown account, the
  unknown leg *amount*, and re-resolve both currencies, so accountId =
  source (expense leg), destinationAccountId = destination (income leg).
  See Transfer Rules 23, 25, 28.

isValid (normal):
  amount > 0 && accountId.isNotEmpty && categoryId.isNotEmpty
  && (settlementStatus == pending || !date.isAfter(endOfToday))

isValid (transfer):
  amount > 0 && accountId.isNotEmpty && destinationAccountId.isNotEmpty
  && accountId != destinationAccountId && !date.isAfter(endOfToday)
  && !(isCrossCurrency && destinationAmount <= 0)

Field update methods:
  updateType, updateAmount, updateDescription, updateDate,
  updateAccountId, updateCategoryId, updateDestinationAccountId,
  updateDestinationAmount, updateNotes,
  updateSettlementStatus, updateRecurrence, updateRecurrenceIntervalMonths,
  updateInstallmentCount, setTransferMode

`updateAccountId` / `updateDestinationAccountId` also stamp that account's
currency onto `accountCurrency` / `destinationCurrency`, so picking a foreign
account is what flips `isCrossCurrency`.
`updateDestinationAmount` parses BR/EN decimals via `parseDecimalAmount` and is
ignored by submit when the currencies match.

`prepareForNext()` emits `clearedForNextEntry()`: every user-entered field
(including the three currency fields) survives; only `status`,
`savedTransactionId`, `continueAfterSave` and `failure` reset.

`updateType` clears the selected category on any expense↔income switch (the two
category sets are disjoint), mirroring the import-preview "switching type clears
category" rule.

Date behavior:
  - updateDate switches non-transfer future dates to pending automatically.
  - updateSettlementStatus(paid) moves future dates back to today.
  - Transfers are always paid-only in V1.

submit():
  if !isValid → no-op
  → emit(submitting)
  → if isTransfer
      → isEditing ? updateTransfer(both legs) : createTransfer(expense, income)
  → else if creating recurring → createTransactions(generated occurrences)
  → else if editing sequence with following scope → update pending future rows
  → else → isEditing ? updateTransaction : createTransaction
  → success: emit(success)
  → failure: emit(failure + Failure)
```

## Edge Cases

- **Empty transaction list** — Loaded with empty list, not error.
- **Amount parsing** — `double.tryParse` with fallback to 0.
- **Future date** — allowed only when `settlementStatus == pending`; paid future dates are blocked.
- **Recurring future rows** — generated rows after the first occurrence are pending even when the first occurrence is paid.
- **Fixed recurrence end** — deleting "this and following" stops the fixed sequence at the selected due date so the rolling generator does not recreate deleted future rows.
- **Delete transfer** — deletes both linked transactions.
- **Delete then reload** — after successful delete, bloc re-dispatches load for current month.
- **Reassign with no matching transactions** — Firestore batch is empty, succeeds silently.
- **Filter combinations** — all filter params are optional and additive (AND logic).
- **Transfer with same source/destination** — blocked by validation.

## CSV Import

### CSV Format

The parser locates each field by **header name** (accent- and case-insensitive), not by column position — extra/reordered columns are tolerated, and unknown columns are ignored. The first row must include each required header below.

| Logical field | Accepted headers (any of) | Description / Format |
|---|---|---|
| type (required) | `Tipo`, `Type`, `Kind` | `Despesa` / `Expense` (expense), `Receita` / `Income` (income), `Transferência` / `Transfer` (transfer), `Pagamento` / `Payment` (credit card payment → transfer). Accent- and case-tolerant. **Empty or unrecognized values reject the whole import** with a `ValidationFailure` whose message points to the offending row and lists accepted values. |
| date (required) | `Data`, `Date` | `DD/MM/YYYY`. Invalid values reject the whole import with row detail. |
| amount (required) | `Valor`, `Value`, `Amount` | Number — accepts both Brazilian (`"-9,99"`, `"1.234,56"`) and English (`-9.99`, `1,234.56`) decimal styles. Stored as `abs()` since the type column carries the sign. Zero or non-numeric values reject the whole import with row detail. |
| description (optional) | `Descrição`, `Description`, `Memo`, `Notes` | Free text, may be empty |
| category (optional) | `Categoria`, `Category` | `ParentName/SubcategoryName` or `CategoryName`. Ignored for Transferência/Pagamento. |
| account (required) | `Conta`, `Account`, `Origem` | Account name (must exist at import time). Empty value rejects with row detail. |
| destination (optional) | `Conta transferência`, `Conta destino`, `Destination`, `Transfer Account` | Only used for Transferência/Pagamento (must exist at import time) |

### Parsing Rules

16. **Category notation** — `"Saúde/Plano de saúde"` means parent category "Saúde" and subcategory "Plano de saúde". Split on first `/` not surrounded by spaces, trim both parts. `"Mercado / Almoço"` (spaces around `/`) is treated as a single category name.
17. **Amount is always stored positive** — `abs()` of parsed value. Type is determined by the `Tipo` column.
18. **Decimal flexibility** — the rightmost separator (`,` or `.`) is treated as the decimal point; the other one as a thousands grouper and stripped. Quotes are removed before parsing.
19. **Date format** — `DD/MM/YYYY` parsed to `DateTime`.
20. **Pagamento = transfer** — creates a linked expense+income pair, same as Transferência.
21. **Transfers have empty categoryId** — the `Categoria` column is ignored for Transferência and Pagamento rows.
22. **Category and account matching is case-insensitive**.

### Validation Rules

23. **Entire import is blocked** if ANY referenced category, subcategory, or account does not exist — no partial imports.
24. **Too-short rows** (fewer cells than the largest required-column index) are skipped silently and counted in `skippedRows` — handles trailing blank lines / ragged CSVs.
25. **Bad data inside otherwise complete rows** (unknown type, invalid date, zero/non-numeric amount, empty account) rejects the whole import with `ValidationFailure: Row N: ...` so the user can fix the source.
26. **CSV must have at least one valid data row** after the header — otherwise `ValidationFailure`.
27. **Missing required header** (`type`, `date`, `amount`, `account`) raises `ValidationFailure: CSV is missing the required "X" column.` The dialog surfaces parse failures as an `AlertDialog` so the user can read the full detail.
28. **Mirror transfers are deduplicated**: many exporters (Mobills, etc.) emit each transfer twice — a negative leg on the source row and a positive mirror on the destination row (same date, same `|amount|`, accounts swapped). Both legs collapse to a single import row. Pairing is 1:1 by canonical key `(date, |amount|, sorted account pair)`, so three real transfers of the same amount/day still come through as three rows. The negative leg wins (its `Conta` is already the source); each discarded mirror is counted in `skippedRows`.
29. **Unpaired positive transfer rows have their account fields swapped**: a lone positive row's `Conta` is the destination (where money landed), `Conta transferência` is the source. The parser flips them so the rest of the pipeline can keep treating `accountName` as the source.

### Import Flow

26. **Preview step** — parses CSV, fetches existing categories and accounts, returns `TransactionImportPreview` with: parsed rows, missing categories, missing accounts, skipped row count, and a `canImport` flag.
27. **Import step** — validates via preview; if `!canImport`, returns `ValidationFailure` listing missing items. Otherwise creates each transaction/transfer via repository.

### Use Case Contract

```dart
class ImportTransactionsCsvUseCase {
  ImportTransactionsCsvUseCase(
    TransactionRepository transactionRepository,
    CategoryRepository categoryRepository,
    AccountRepository accountRepository,
  );

  Future<Either<Failure, TransactionImportPreview>> preview({
    required String csvContent,
    required String userId,
  });

  Future<Either<Failure, TransactionImportResult>> call({
    required String csvContent,
    required String userId,
  });
}
```

### State Machine (Bloc integration)

```
Events:
  TransactionsImportCsvRequested { csvContent }
  TransactionsImportRowsConfirmed { rows, skippedCount }

States:
  TransactionsImportCsvRequested
    → Loading → TransactionsImported | TransactionsError

  TransactionsImportRowsConfirmed
    → TransactionsImporting(processed: 0, total: rows.length)
    → TransactionsImporting(processed: i, total: rows.length)  // for each i
    → TransactionsImported { importedCount, skippedCount } | TransactionsError
```

### Progress Reporting

33. **`importRows` accepts an optional `onProgress(processed, total)` callback** invoked after every processed row (created or skipped). `total` equals the input `rows.length`; rows whose account/category cannot be resolved still tick the counter so the bar reaches 100%.
34. **The bloc translates progress into `TransactionsImporting` states** so the import-transactions page renders a determinate `LinearProgressIndicator` overlay (with a `processed of total` counter and percentage) until the import resolves. The list page treats `TransactionsImporting` as a loading state.

Public method on bloc: `previewCsv(String csvContent)` — delegates to use case `preview()`, returns `Either` directly (same pattern as `CategoriesCubit.previewCsv`).

### CSV Import Preview Editing

The CSV import flow has two stages: **parse + preview** and **confirm**. The preview is rendered on a dedicated page (not a dialog) so the user can review and adjust each row before committing.

28. **Tabs split by type**: the page presents Expense / Income / Transfer tabs (counts in labels). Rows from the other tabs are hidden but kept in state.
29. **Per-row edit**: tapping a row opens a sheet with type (Expense/Income/Transfer pill toggle), date, amount, description, account, and category (or destination account for transfers) editors. Changing the type clears mismatched fields:
   - Switching to Transfer clears category/subcategory and destination account (user must re-pick destination).
   - Switching from Transfer to Expense/Income clears destination and category (user must pick a category).
   - Switching Expense ↔ Income clears category (income/expense use different categories).
   - Source account (`accountName`) is preserved across all transitions so the user keeps their account context.
   This is the escape hatch for CSVs that misclassified rows — e.g. a credit-card bill payment imported as a `Despesa` with category "Pagamento de cartão" can be converted in-place to a Transfer.
30. **Account/category overrides**: when the user picks a different account or category in the sheet, the row's `accountName`/`categoryName` strings are rewritten to the picked entity's name. Resolution at import time happens against the latest categories/accounts state.
31. **On-the-fly missing recomputation**: the page derives `missingAccounts` and `missingCategories` from the *current* edited rows + the latest categories/accounts cubits. The submit bar disables (and a red banner shows the unresolved names) until everything resolves; this means the preview's original `missingAccounts`/`missingCategories` may already be stale — the page does not rely on them.
32. **Submit**: dispatches `TransactionsImportRowsConfirmed(rows, skippedCount)` → bloc calls `ImportTransactionsCsvUseCase.importRows`, which uses the same per-row creation logic as `call(csvContent)`. Rows whose account or category cannot be resolved at import time are silently skipped (the page-level guard above is expected to prevent this case).

## Firestore

**Collection:** `transactions/{id}`

**Scheduling fields:**
- `settlementStatus`: `"pending"` or `"paid"`; missing values load as `paid`.
- `dueDate`: due date for pending rows; missing values load from `date`.
- `settledAt`: settlement date for paid rows.
- `recurrence`: `"single"`, `"installment"`, or `"fixed"`; missing values load as `single`; legacy `"oneShot"`/`"monthly"` are accepted.
- `recurrenceGroupId`: sequence identifier shared by all generated rows.
- `recurrenceIntervalMonths`: month interval between occurrences.
- `recurrenceIndex`: 1-based generated occurrence index.
- `recurrenceTotal`: total number of installments, null for fixed.
- `recurrenceBaseDescription`: user-entered description without installment marker.
- `recurrenceEndDate`: exclusive stop boundary for fixed sequences ended by deleting "this and following".
**Investing link fields (F8):**
- `institutionId`: set on an aporte/resgate cash row; makes it invisible to the
  month's income/expense summary and visible to the 50/30/20 savings bucket.
- `linkedInvestmentTransactionId`: the `investment_transactions` buy/sell that
  generated the row. Written and reconciled **only** by
  `SyncInvestmentCashFlowUseCase` — see
  [investing_transactions.md](investing_transactions.md) rules 9–12.

**Legacy audit fields:**
- `sourceBillId` and `parentTransactionId` exist on the documents written by
  the 2026-06-10 bills migration (`scripts/migrate_bills_to_transactions.js`,
  see [bills_migration.md](bills_migration.md)). They are **not** part of
  `TransactionEntity`, the model, or the Drift cache, and no code in `lib/`
  reads or writes them — they survive only because the migration never deletes.

**Indexes** (the `transactions` composites in `firestore.indexes.json`):
- `userId` ASC + `date` DESC
- `accountId` ASC + `userId` ASC + `date` DESC
- `userId` ASC + `recurrence` ASC + `date` DESC
- `userId` ASC + `recurrenceGroupId` ASC + `dueDate` DESC
- `settlementStatus` ASC + `dueDate` ASC — serves the cross-user
  `notifyTransactionsDue` scheduled function (`settlementStatus == 'pending'`
  + `dueDate <= end of today`; deliberately not scoped by `userId`)

**Query ordering** — the remote query orders by `dueDate` whenever it filters
on a due-date range **or** on `recurrenceGroupId` without a `date` range;
otherwise it orders by `date`. Firestore needs a composite index for every
`(equalities…, orderBy)` shape, so a `recurrenceGroupId` lookup ordered by
`date` would demand a fifth index; ordering it by `dueDate` rides the declared
one above. The ordering is not otherwise observable — the repository upserts
the remote rows into Drift and re-reads them through the DAO, which applies
its own sort.
