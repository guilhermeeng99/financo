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

## Firestore

**Collection:** `transactions/{id}`

**Indexes:**
- `userId` + `date` (descending)
- `accountId` + `userId` + `date` (descending)
