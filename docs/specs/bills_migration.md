# Legacy Bills Migration Spec

This spec defines the one-time migration from legacy `bills/{id}` documents to
transaction-backed payables/receivables.

## Goal

Move production data to the new source of truth:

- `transactions/{id}` represents pending and paid money movements.
- `bills/{id}` stays available for rollback/audit, but the app UI no longer
  reads it.
- The migration must be idempotent and dry-run by default.

## Source Contract

Legacy bill documents contain:

```text
bills/{id}
userId
type                 payable | receivable
description
amount
dueDate
status               pending | paid
recurrence           oneShot | monthly
categoryId?
notes?
paidAt?
paidTransactionId?
parentBillId?
createdAt
updatedAt
```

Important limitation: legacy bills do not contain `accountId`.

## Target Contract

Migrated transactions write:

```text
transactions/{id}
userId
accountId
categoryId
type                 expense | income
amount
description
date
settlementStatus     pending | paid
dueDate
settledAt?
recurrence           oneShot | monthly
sourceBillId
parentTransactionId?
notes?
linkedTransactionId
createdAt
updatedAt
```

## Business Rules

1. Migration is dry-run unless `--apply` is passed.
2. A bill is already migrated when any transaction has `sourceBillId == bill.id`
   or when the deterministic target id `legacy_bill_<billId>` already exists.
3. `pending` bills create `pending` transactions only when the script can
   resolve an account from:
   - bill-specific mapping
   - user-specific mapping
   - the migrated/linked transaction of `parentBillId`
   - default account id
4. `pending` bills without a resolved account are skipped and reported as
   `missingAccount`.
5. `paid` bills with `paidTransactionId` update that existing transaction with:
   - `settlementStatus = paid`
   - `dueDate = bill.dueDate`
   - `settledAt = bill.paidAt ?? bill.dueDate`
   - `recurrence = bill.recurrence`
   - `sourceBillId = bill.id`
6. `paid` bills without `paidTransactionId` are skipped by default as
   `paidUnlinkedNeedsReview`.
7. `paid` unlinked bills are created only when both are true:
   - `--create-paid-unlinked` is passed
   - an account can be resolved
8. Created transaction ids are deterministic: `legacy_bill_<billId>`.
9. `parentTransactionId` is set when the legacy `parentBillId` can be mapped to
   a migrated transaction id or a `paidTransactionId`.
10. The script never deletes or mutates `bills/{id}`.

## Account Map File

Optional JSON file shape:

```json
{
  "defaultAccountId": "account-id-for-all-unmapped-bills",
  "users": {
    "user-id": "account-id-for-this-user"
  },
  "bills": {
    "bill-id": "account-id-for-this-bill"
  }
}
```

Priority is: `bills[billId]`, then `users[userId]`, then the parent bill's
linked/migrated transaction account, then `--default-account-id`, then
`defaultAccountId` from the file.

## CLI Contract

```bash
node scripts/migrate_bills_to_transactions.js                 # dry run
node scripts/migrate_bills_to_transactions.js --apply          # writes safe updates
node scripts/migrate_bills_to_transactions.js --user-id <uid>  # single user
node scripts/migrate_bills_to_transactions.js --account-map account-map.json
node scripts/migrate_bills_to_transactions.js --bill-account <billId=accountId>
node scripts/migrate_bills_to_transactions.js --default-account-id <accountId>
node scripts/migrate_bills_to_transactions.js --user-account <userId=accountId>
node scripts/migrate_bills_to_transactions.js --create-paid-unlinked
node scripts/migrate_bills_to_transactions.js --show-missing-accounts
```

## Acceptance Criteria

- Running dry-run prints planned writes and skipped rows without changing
  Firestore.
- Running apply twice does not create duplicates.
- Linked paid bills update the existing transaction rather than creating a new
  one.
- Pending bills with no account are reported instead of guessed.
- Missing account reports include available account ids and an account-map
  template for manual review.
- The migration output includes counts for created, updated, skipped, and
  errors.
