# Accounts Feature Spec

## Entity Contract

```dart
AccountEntity {
  id:              String   (required, Firestore doc ID)
  userId:          String   (required, owner)
  name:            String   (required, non-empty)
  type:            AccountType (required: checking | creditCard)
  bank:            BankType (required: nubank | others)
  initialBalance:  double   (required, seed balance at account creation)
  creditLimit:     double?  (null for checking, required for creditCard)
  closingDay:      int?     (null for checking, required for creditCard, 1–31)
  dueDay:          int?     (null for checking, required for creditCard, 1–31)
  linkedAccountId: String?  (null for checking, required for creditCard — the checking account that pays the bill)
  createdAt:       DateTime (required, set on creation)
}
```

**Computed properties:**
- `availableCredit` → `creditLimit - initialBalance` (0 if no creditLimit)
- `bankLabel` → human-readable bank name ("Nubank", "Others")

## Business Rules

1. **Name is required** — cannot be empty.
2. **Account type is immutable after creation** — checking ↔ creditCard cannot be changed.
3. **Credit card fields are conditional:**
   - `creditLimit`, `closingDay`, `dueDay`, `linkedAccountId` — required when `type == creditCard`, null when `type == checking`.
   - `linkedAccountId` must reference an existing checking account.
4. **Validation for credit cards:** an account form is valid when `name.isNotEmpty && (type != creditCard || linkedAccountId.isNotEmpty)`.
5. **All accounts are deletable** — no concept of system/default accounts.
6. **Deleting an account cascades** — all transactions linked to the account are also deleted.
7. **Accounts are ordered by creation date** (ascending) in both Firestore and local cache.
8. **Default bank is Nubank** for new accounts.
9. **Default type is checking** for new accounts.
10. **Default closingDay is 1, default dueDay is 10** for credit card forms.
11. **initialBalance represents the seed balance** — running balance is calculated from transactions.

## Repository Contract

```dart
abstract class AccountRepository {
  Future<Either<Failure, List<AccountEntity>>> getAccounts({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, AccountEntity>> getAccount(String id);

  Future<Either<Failure, AccountEntity>> createAccount(AccountEntity account);

  Future<Either<Failure, AccountEntity>> updateAccount(AccountEntity account);

  Future<Either<Failure, void>> deleteAccount(String id);
}
```

**Cache strategy (same as categories):**
- `forceRefresh: false` → read from local Drift cache only.
- `forceRefresh: true` → fetch from Firestore, replace local cache, then read local.
- `getAccount` → try local first, fallback to remote + cache.
- Create/update → write to remote, then upsert local cache.
- Delete → delete from remote, then delete from local cache.

## Model Serialization

**Firestore → Model (`fromMap`):**

| Firestore field | Dart field | Type cast |
|---|---|---|
| `userId` | `userId` | `String` |
| `name` | `name` | `String` |
| `type` | `type` | `AccountType.values.byName(String)` |
| `bank` | `bank` | `BankType` with fallback to `others` |
| `balance` | `initialBalance` | `(num).toDouble()` |
| `creditLimit` | `creditLimit` | `(num?)?.toDouble()` |
| `closingDay` | `closingDay` | `int?` |
| `dueDay` | `dueDay` | `int?` |
| `linkedAccountId` | `linkedAccountId` | `String?` |
| `createdAt` | `createdAt` | `Timestamp → DateTime` |

Note: Firestore field is `balance`, Dart field is `initialBalance`.

**Model → Firestore (`toJson`):**
- Serializes all fields except `id` (Firestore doc ID is separate).
- `createdAt` serialized as `Timestamp`.
- `type` and `bank` serialized as `.name` string.

## State Machines

### AccountsCubit

```
Initial ──loadAccounts──→ Loading ──success──→ Loaded
                                  ──failure──→ Error

Loaded ──loadAccounts(forceRefresh: false)──→ (no-op, stays Loaded)
Loaded ──loadAccounts(forceRefresh: true)──→ Loading → ...
```

### AccountFormCubit

```
State: { userId, name, type, bank, balance, creditLimit,
         closingDay, dueDay, linkedAccountId, status, existingId?, failure? }

isEditing = existingId != null
isValid   = name.isNotEmpty && (type != creditCard || linkedAccountId.isNotEmpty)

Field update methods:
  updateName, updateType, updateBalance, updateCreditLimit,
  updateClosingDay, updateDueDay, updateBank, updateLinkedAccountId

submit():
  if !isValid → no-op
  → emit(submitting)
  → isEditing ? updateAccount : createAccount
  → success: emit(success)
  → failure: emit(failure + Failure)

Credit card fields stripped on submit when type == checking:
  creditLimit, closingDay, dueDay, linkedAccountId → null
```

### AccountStatementCubit

```
Initial ──load(account, year, month)──→ Loading
  → parallel fetch: allTimeTransactions + periodTransactions
  → either fails → Error
  → both succeed:
    runningBalance = initialBalance + Σ(income) − Σ(expense)  [all time]
    totalIncome    = Σ(income)  [period]
    totalExpenses  = Σ(expense) [period]
    → Loaded { account, runningBalance, transactions (sorted desc by date),
               totalIncome, totalExpenses, year, month }
```

## Edge Cases

- **Empty account list** — Loaded with empty list, not error.
- **Credit card without linked account** — form validation blocks submit.
- **Balance parsing** — `double.tryParse` with fallback to 0.
- **Unknown bank type from Firestore** — fallback to `BankType.others`.
- **Unknown account type from Firestore** — `AccountType.values.byName` throws on invalid value (no fallback currently).
- **Delete with transactions** — cascades to delete all linked transactions.
- **Statement with no transactions** — runningBalance = initialBalance, zero totals.
- **Statement fetch failure** — first failing result short-circuits to error.

## Firestore

**Collection:** `accounts/{id}`

**Indexes:**
- `userId` + `isActive` + `createdAt` (existing query pattern — note: isActive will be removed)

After isActive removal, query becomes: `where('userId', isEqualTo: userId).orderBy('createdAt')`
