# Accounts Feature Spec

## Entity Contract

```dart
AccountEntity {
  id:              String   (required, Firestore doc ID)
  userId:          String   (required, owner)
  name:            String   (required, non-empty)
  type:            AccountType (required: checking | creditCard)
  bank:            BankType (required: see BankBrand registry — Brazilian banks + others)
  initialBalance:  double   (required, seed balance at account creation)
  creditLimit:     double?  (null for checking, required for creditCard)
  closingDay:      int?     (null for checking, required for creditCard, 1–31)
  dueDay:          int?     (null for checking, required for creditCard, 1–31)
  linkedAccountId: String?  (null for checking, required for creditCard — the checking account that pays the bill)
  createdAt:       DateTime (required, set on creation)
  currentBalance:  double?  (runtime-only, populated by AccountsCubit from live transactions; null = not yet loaded)
}
```

### Live balance semantics

`initialBalance` is the immutable seed entered when the account was created — it lives in Firestore. `currentBalance` is a runtime-only field set by `AccountsCubit.loadAccounts` after fetching all-time transactions (it is **not** persisted). Sign convention is type-specific so the same getter works for both:

- **Checking**: `currentBalance = initialBalance + Σincome − Σexpense`. Positive means money in the account.
- **Credit card**: `currentBalance = initialBalance + Σexpense − Σincome`. Positive means the amount currently owed; spending raises it, payments (transfers in, refunds) lower it.

The pure helper `applyTransactionsToAccounts(accounts, transactions)` in `lib/features/accounts/domain/account_balance_calculator.dart` is the single source of truth for the math. Transactions that target an unknown `accountId` are ignored.

**Computed properties:**
- `effectiveBalance` → `currentBalance ?? initialBalance` — the value widgets should display.
- `usedCredit` → for credit cards, `effectiveBalance.clamp(0, creditLimit)`; 0 for checking.
- `availableCredit` → `(creditLimit - usedCredit).clamp(0, creditLimit)`. When `currentBalance` is null this collapses to the legacy `creditLimit - initialBalance` formula, preserving the previous behavior on stale entities.
- `bankLabel` → delegates to `BankBrand.of(bank).label` so the entity has no hardcoded copy of bank names.

The credit usage bar on the accounts list reads `account.usedCredit`, so it now updates as expenses post to the card instead of staying frozen on the seed value.

### BankBrand registry

`BankBrand` (in `lib/features/accounts/domain/bank_brand.dart`) is the single source of truth for every bank's display identity:

- `label` — human-readable name (`"Itaú"`, `"Banco do Brasil"`, `"Others"`).
- `abbreviation` — 2–4 chars rendered inside the avatar circle. Foreground text color is auto-picked from background luminance, so light brands (yellow, lime) get black text and dark brands get white.
- `color` — ARGB int with the brand color used as the avatar background.

`BankAvatar` always renders the same way: a solid coloured circle with the abbreviation. `BankType.others` is the one exception — it shows a generic `buildingColumns` icon instead of a letter abbreviation.

Adding a new bank means: append a value to `BankType`, add a matching entry in `BankBrand._registry`, and append it to `_BankPickerSheet._displayOrder` so it appears in the picker.

`BankBrand.resolveAlias(input)` parses free-text bank labels (CSV cells, AI tool calls, user typing in the picker search field) into a `BankType?`. Matching is case- and accent-insensitive against the registry label, the `enum.name` string, and a hand-curated alias map (`"nu"` → Nubank, `"bb"` → Banco do Brasil, `"cef"` → Caixa, etc.). Returns `null` when nothing matches; callers default to `BankType.others`.

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
    → for each transfer in period: fetch linked transaction to resolve
      its accountId (the "other side"). Build
      transferCounterpartAccountIds: Map<transactionId, linkedAccountId>.
      A failed lookup leaves the entry absent — the view falls back to
      no label.
    → Loaded { account, runningBalance, transactions (sorted desc by date),
               totalIncome, totalExpenses, year, month,
               transferCounterpartAccountIds }
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

## CSV Import

The accounts list lets the user import accounts in bulk from a CSV. The flow has two stages: **parse + preview** and **confirm**. The preview is rendered on a dedicated page so the user can review and adjust each row before committing.

### CSV Format

The parser locates each field by **header name** (accent- and case-insensitive), not by column position — extra/reordered columns are tolerated, and unknown columns are ignored. The first row must include each required header below.

| Logical field | Accepted headers (any of) | Description / Format |
|---|---|---|
| name (required) | `Nome`, `Name`, `Account Name`, `Apelido` | Free text, required |
| balance (required) | `Saldo inicial`, `Saldo`, `Initial balance`, `Balance`, `Opening balance` | Number — accepts both Brazilian (`421,95`, `1.234,56`) and English (`421.95`, `1,234.56`) decimal styles. The rightmost separator is treated as the decimal point. |
| type (required) | `Tipo`, `Type`, `Kind` | `Conta Corrente` / `Checking` for checking, `Cartão de Crédito` / `Credit Card` for credit card. Accent- and case-tolerant. **Empty or unrecognized values reject the whole import** with a `ValidationFailure` whose message points to the offending row and lists accepted values. |
| bank (required) | `Banco`, `Bank` | Resolved via `BankBrand.resolveAlias` — case- and accent-insensitive, accepts labels (`"Banco do Brasil"`), enum names (`"bancoDoBrasil"`) and curated short aliases (`"nu"`, `"bb"`, `"cef"`). Anything unresolved defaults to `BankType.others`. |
| limit (optional) | `Limite`, `Credit limit`, `Limit` | Number, same format rules as balance. Only used for credit cards. |
| due (optional) | `Próximo Vencimento`, `Vencimento`, `Due date`, `Due day`, `Next due` | `DD/MM/YYYY` or a bare day number. Only the day is used, populating `dueDay`. Only used for credit cards. |
| closing (optional) | `Fechamento`, `Closing day`, `Closing`, `Closing date` | Integer 1–31. Only used for credit cards. |

If a required header is missing, the parser raises `ValidationFailure: CSV is missing the required "X" column.` — the dialog surfaces this in an `AlertDialog` so the user can read the full detail.

The dialog surfaces parse failures as an `AlertDialog` (not a snackbar) so the user can read the full row/value detail.

### Preview item

```
AccountImportPreviewItem {
  name:               String          (required)
  type:               AccountType     (required, parsed from CSV)
  bank:               BankType        (required, default others)
  initialBalance:     double          (required, default 0)
  creditLimit:        double?         (set for credit cards)
  closingDay:         int?            (set for credit cards)
  dueDay:             int?            (set for credit cards)
  linkedAccountName:  String?         (CSV does not carry this — null until user picks)
}
```

### Page-level rules

12. **Tabs split by type**: the page presents Checking and Credit card tabs (counts in labels). Items from the other tab are hidden but kept in state.
13. **Per-item edit**: tapping a row opens a sheet with name, type pill toggle, bank pill toggle, initial balance, and the credit-card group (limit, closing day, due day, linked checking account) when applicable.
14. **Type is editable**: switching Checking ↔ Credit card cleans up the conditional fields:
    - Going to Checking clears `creditLimit`, `closingDay`, `dueDay`, `linkedAccountName`.
    - Going to Credit card requires the user to fill all four before submit.
15. **Linked account picker**: surfaces both existing checking accounts under this user AND checking accounts being imported in the same batch (by name, since IDs aren't assigned yet). Returns the picked account's name, which is later resolved to an ID at import time.
16. **Renaming a checking account cascades**: when the user renames a checking account in the preview, every credit card whose `linkedAccountName` matched the old name is updated to the new name so the link still resolves.
17. **Removing a checking account cascades**: when the user removes a checking account, every credit card whose `linkedAccountName` matched it is unlinked (set to null), causing them to surface in the missing-link banner until re-linked or removed.
18. **Missing-link banner**: credit cards with no resolvable `linkedAccountName` (existing or in-import) appear in a red banner at the top; the submit bar is disabled until the list is empty.
19. **Duplicates are read-only**: items the preview marked as duplicates (existing user accounts with the same lowercase name) are listed in a muted "Will be skipped" section per tab and cannot be edited or removed.
20. **Submit calls `confirmImport`**: the cubit's `confirmImport(items, duplicateCount)` delegates to `ImportAccountsCsvUseCase.importItems`, which creates checking accounts first (so credit cards can reference them by name), then credit cards. Credit cards whose link cannot be resolved at import time are silently skipped — the page-level guard above is expected to prevent this case.

### Cubit contract addition

```
previewCsv(String csvContent) → Either<Failure, AccountImportPreview>
  delegates to ImportAccountsCsvUseCase.preview()

confirmImport({
  required List<AccountImportPreviewItem> items,
  int duplicateCount = 0,
}) → AccountsImporting(processed: 0, total: items.length)
   → AccountsImporting(processed: i, total: items.length)  // for each i
   → AccountsImported(accounts, importedCount, duplicateCount)
   | AccountsError(failure)
```

### Progress reporting

21. **`importItems` accepts an optional `onProgress(processed, total)` callback** invoked after every processed item (created or skipped). `total` equals `items.length`; orphan credit cards skipped because their `linkedAccountName` cannot be resolved still tick the counter so the bar reaches 100%.
22. **The cubit translates progress into `AccountsImporting` states** so the import-accounts page renders a determinate `LinearProgressIndicator` overlay (with a `processed of total` counter and percentage) until the import resolves. The accounts list page treats `AccountsImporting` as a loading state.

## Firestore

**Collection:** `accounts/{id}`

**Indexes:**
- `userId` + `isActive` + `createdAt` (existing query pattern — note: isActive will be removed)

After isActive removal, query becomes: `where('userId', isEqualTo: userId).orderBy('createdAt')`
