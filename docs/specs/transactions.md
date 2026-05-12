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
  date:                  DateTime        (required, not in the future)
  notes:                 String?         (optional free-text)
  linkedTransactionId:   String?         (optional, non-null for transfers)
  createdAt:             DateTime        (required, set on creation)
  updatedAt:             DateTime        (required, set on creation and update)
}

bool get isTransfer => linkedTransactionId != null
```

## Business Rules

1. **Description is optional** — may be empty.
2. **Amount must be positive** — `amount > 0`.
3. **Account is required** — `accountId` must be non-empty.
4. **Category is required for income/expense** — `categoryId` must be non-empty. Transfers have empty categoryId.
5. **Date cannot be in the future** — validated as `!date.isAfter(endOfToday)`.
6. **Transaction type (income/expense) is immutable after creation** — same pattern as categories/accounts.
7. **Transactions are ordered by date descending** in both Firestore and local cache queries.
8. **Transactions support filtering** by: date range (startDate/endDate), accountId, categoryId.
9. **Default type is expense** for new transactions.
10. **Reassign transactions** — bulk operation that moves all transactions from one category to another (used when deleting a category).

### Transfer Rules

11. **Transfers create two linked transactions** — an expense on the source account and an income on the destination account, linked by `linkedTransactionId`.
12. **Transfers have no category** — `categoryId` is empty string for both sides.
13. **Deleting one side of a transfer deletes both** — cascading delete at the repository level.
14. **Editing a transfer** — only amount, date, description, and notes can be changed. Accounts and type are immutable.
15. **Source and destination accounts must differ** — validated in form state.

## Repository Contract

```dart
abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, TransactionEntity>> getTransaction(String id);

  Future<Either<Failure, TransactionEntity>> createTransaction(TransactionEntity transaction);

  Future<Either<Failure, TransactionEntity>> updateTransaction(TransactionEntity transaction);

  Future<Either<Failure, void>> deleteTransaction(String id);

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

**Cache strategy:**
- `forceRefresh: false` → read from local Drift cache only (with filters).
- `forceRefresh: true` → fetch from Firestore (with filters), **upsert** into local cache (not replace-all), then read local.
- `getTransaction` → try local first, fallback to remote + cache.
- Create/update → write to remote, then upsert local cache.
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
| `notes` | `notes` | `String?` |
| `linkedTransactionId` | `linkedTransactionId` | `String?` |
| `createdAt` | `createdAt` | `Timestamp → DateTime` |
| `updatedAt` | `updatedAt` | `Timestamp → DateTime` |

**Model → Firestore (`toJson`):**
- Serializes all fields except `id`.
- DateTime fields serialized as `Timestamp`.
- `type` serialized as `.name` string.

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
  - Otherwise → Loading → fetch with date range [startOfMonth, endOfMonth] → Loaded or Error

Delete behavior:
  - Delete the transaction (cascades if transfer) → on success, re-dispatch LoadRequested(forceRefresh: true)
  - On failure → Error

Default year/month: DateTime.now() when not specified in event.
```

### TransactionFormCubit

```
State: { userId, type, amount, description, date, accountId, categoryId,
         destinationAccountId, notes, status, isTransfer,
         existingId?, linkedTransactionId?, failure? }

isEditing  = existingId != null
isTransfer = state.isTransfer flag (or linkedTransactionId != null on existing)

isValid (normal):
  amount > 0 && accountId.isNotEmpty && categoryId.isNotEmpty && !date.isAfter(endOfToday)

isValid (transfer):
  amount > 0 && accountId.isNotEmpty && destinationAccountId.isNotEmpty
  && accountId != destinationAccountId && !date.isAfter(endOfToday)

Field update methods:
  updateType, updateAmount, updateDescription, updateDate,
  updateAccountId, updateCategoryId, updateDestinationAccountId, updateNotes,
  setTransferMode

submit():
  if !isValid → no-op
  → emit(submitting)
  → if isTransfer && !isEditing → createTransfer(expense, income)
  → else → isEditing ? updateTransaction : createTransaction
  → success: emit(success)
  → failure: emit(failure + Failure)
```

## Edge Cases

- **Empty transaction list** — Loaded with empty list, not error.
- **Amount parsing** — `double.tryParse` with fallback to 0.
- **Future date** — form validation blocks submit.
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

**Indexes:**
- `userId` + `date` (descending)
- `accountId` + `userId` + `date` (descending)
