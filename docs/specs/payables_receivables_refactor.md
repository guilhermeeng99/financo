# Payables / Receivables Refactor Spec

This spec documents the replacement of the legacy `bills` feature. Scheduled
money movements are first-class transactions instead of a separate, duplicate
bill model.

Original problem:

- `BillEntity` was an intent that later created or linked a
  `TransactionEntity`.
- `TransactionEntity.date` rejected future dates.
- The user had to think in two concepts: bills and transactions.
- The UI did not match the mental model of "I have a future transaction, but
  it is not paid/received yet".

Target model:

- `transactions` becomes the single source of truth for cash-flow items.
- A transaction can be `pending` or `paid`.
- Pending transactions can have future dates.
- Pending transactions due before today are overdue.
- Pending transactions due today or overdue are actionable and should trigger
  badges / notifications.
- Paid transactions remain the only records that affect balances, reports,
  budgets, investments, and 50/30/20 calculations.

## Terminology

| Term | Meaning |
|---|---|
| Payable | Pending or paid expense. UI label: `A pagar` / `Paga`. |
| Receivable | Pending or paid income. UI label: `A receber` / `Recebida`. |
| Pending transaction | A planned transaction that has not moved money yet. |
| Paid transaction | A settled transaction that affects account balance and reports. |
| Due date | Expected payment/receipt date. |
| Settlement date | Date the user marked the pending transaction as paid/received. |
| Overdue | Pending transaction with `dueDate < today`. |
| Due today | Pending transaction with `dueDate == today`. |
| Scheduled | Pending transaction with `dueDate > today`. |

## Product Decision

Replace the current `bills` domain with scheduled transactions.

The app should no longer create a separate bill and then create/link a
transaction. Creating a future payable/receivable creates one transaction row
with `settlementStatus = pending`. Marking it as paid/received updates that same
transaction to `settlementStatus = paid`.

Production migration status: legacy `bills` data was migrated to
transaction-backed records on 2026-06-10. The `bills` collection remains for
rollback/audit only; new UI flows must use `transactions`.

## V1 Implementation Scope

The implementation ships the core transaction-based behavior:

- `settlementStatus`, `dueDate`, `settledAt`, and `recurrence` on transactions.
- Recurrence modes are `single`, `installment`, and `fixed`; legacy
  `oneShot`/`monthly` values are accepted only as migration-compatible input.
- Future dates allowed through `AddTransactionPage` when the transaction is
  pending.
- `PayablesReceivablesPage` reads transactions and renders `A pagar`,
  `A receber`, `Pagas`, and `Recebidas`.
- The shell navigation exposes two Dashboard child entries:
  `A pagar e receber` and `Pagas e recebidas`.
- `A pagar e receber` has two internal tabs: `A pagar` and `A receber`.
- `Pagas e recebidas` has two internal tabs: `Pagas` and `Recebidas`.
- Planning no longer hosts a bills/accounts sub-tab.
- Settlement updates the same transaction.
- Financial calculations ignore pending transactions.
- `notifyTransactionsDue` queries pending transactions.
- Legacy `bills` production data has been migrated to `transactions`.
- Fixed recurrence is materialized as a rolling 12-month window, filled
  opportunistically when Dashboard/Transactions load.
- Installments are created as multiple pending/paid transaction rows in one
  batch.
- AI chat no longer has a bill action; future payables and receivables are
  created as regular transaction actions with future dates.
- The legacy Bills domain/data/repository/bloc/form code was removed from the
  app on 2026-06-10. Only the `/bills` route alias remains for backwards
  compatibility.

## Entity Contract

`TransactionEntity` gains scheduling and settlement fields:

```dart
enum TransactionSettlementStatus { pending, paid }
enum TransactionRecurrence { single, installment, fixed }

TransactionEntity {
  id:                    String
  userId:                String
  accountId:             String
  categoryId:            String
  type:                  TransactionType      // income | expense
  amount:                double
  description:           String

  // Existing field. For paid records this remains the cash-flow date used by
  // reports. For pending records this should mirror `dueDate` for ordering and
  // legacy query compatibility, but calculations must still ignore pending rows.
  date:                  DateTime

  settlementStatus:      TransactionSettlementStatus // pending | paid
  dueDate:               DateTime        // defaults to date for legacy paid rows
  settledAt:             DateTime?       // set when status becomes paid
  recurrence:            TransactionRecurrence // single | installment | fixed
  recurrenceGroupId:     String?
  recurrenceIntervalMonths: int
  recurrenceIndex:       int?
  recurrenceTotal:       int?
  recurrenceBaseDescription: String?
  recurrenceEndDate:     DateTime?

  notes:                 String?
  linkedTransactionId:   String?         // existing transfer support
  createdAt:             DateTime
  updatedAt:             DateTime
}
```

Computed properties:

```dart
bool get isPending => settlementStatus == TransactionSettlementStatus.pending;
bool get isPaid => settlementStatus == TransactionSettlementStatus.paid;
bool get isPayable => type == TransactionType.expense;
bool get isReceivable => type == TransactionType.income;

bool get isOverdue =>
  isPending && startOfDay(dueDate).isBefore(startOfToday());

bool get isDueToday =>
  isPending && isSameDay(dueDate, DateTime.now());
```

## Business Rules

1. Existing transactions migrate as `settlementStatus = paid`.
2. New transactions dated in the future default to `pending`.
3. New transactions dated today or in the past default to `paid`, but the form
   must allow the user to explicitly save them as `pending`.
4. A `paid` transaction cannot have a future `date`.
5. A `pending` transaction can have `dueDate` in the past, today, or future.
6. `dueDate` is date-only and normalized to local midnight.
7. `settledAt` is date-only when used as a reporting date; timestamp precision
   is not required for V1.
8. Marking a pending payable as paid sets:
   - `settlementStatus = paid`
   - `settledAt = chosen settlement date` (default today)
   - `date = chosen settlement date`
   - `updatedAt = now`
9. Marking a pending receivable as received uses the same rule as payable.
10. Pending transactions do not affect:
    - account balances
    - dashboard income/expense totals
    - budgets
    - 50/30/20
    - account statement running balances
    - investment allocation calculations
11. Pending transactions do appear in the payables/receivables view.
12. Paid transactions appear in regular transaction history and in the paid /
    received section of the payables/receivables view.
13. Transfers are out of scope for V1 scheduled payables/receivables. A transfer
    must remain paid-only until scheduled transfer semantics are designed.
14. Recurrence is immutable after creation.
15. Type is immutable after creation.
16. Editing a paid transaction can change ordinary transaction fields, but cannot
    revert it to `pending` in V1.
17. Deleting a pending transaction deletes only that transaction.
18. Deleting a paid transaction follows current transaction deletion rules,
    including transfer cascade.

## Recurrence

Recurring cash-flow now belongs to `TransactionEntity`.

Modes:

1. `single` — one transaction row.
2. `installment` — creates one row per installment. The form amount is the
   total purchase value; generated rows split cents so the row sum equals the
   original amount. Descriptions append `1/N`, `2/N`, etc.
3. `fixed` — represents a permanent recurring intent, but the app materializes
   only a rolling 12-month window to avoid unbounded Firestore writes.

Rules:

- Recurrence is month-based only.
- `recurrenceIntervalMonths` controls the cadence.
- Generated future rows are always `settlementStatus = pending`; only the first
  row follows the user's current paid/pending toggle.
- Editing/deleting a sequence asks for scope: only the selected row, or the
  selected row and following pending rows. Paid rows are not mutated by the
  following scope.
- Deleting "this and following" on a fixed sequence writes
  `recurrenceEndDate` on earlier sequence rows so the rolling generator does
  not recreate the removed future rows.
- Fixed rows are topped up by `EnsureFixedRecurrencesUseCase` when Dashboard or
  Transactions load.

## Repository Contract Changes

`TransactionRepository.getTransactions` gains status and due-date filters:

```dart
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
```

New use cases:

```dart
class SettleTransactionUseCase {
  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction, {
    DateTime? settledAt, // defaults to now
  });
}

Future<Either<Failure, List<TransactionEntity>>> createTransactions(
  List<TransactionEntity> transactions,
);

Future<Either<Failure, List<TransactionEntity>>> updateTransactions(
  List<TransactionEntity> transactions,
);

Future<Either<Failure, void>> deleteTransactions(List<String> ids);
```

The transaction-backed payables/receivables page currently builds its overview
directly from `TransactionRepository.getTransactions`; there is no separate
`GetPayablesReceivablesUseCase` in V1.

The legacy `BillRepository` and bill-only use cases have been removed.

## Firestore

Collection remains:

```text
transactions/{id}
```

New fields:

```text
settlementStatus: "pending" | "paid"
dueDate: Timestamp?
settledAt: Timestamp?
recurrence: "single" | "installment" | "fixed"
recurrenceGroupId: string?
recurrenceIntervalMonths: number?
recurrenceIndex: number?
recurrenceTotal: number?
recurrenceBaseDescription: string?
recurrenceEndDate: Timestamp?
```

Migration-only Firestore fields may exist on migrated records:

```text
sourceBillId: string?
parentTransactionId: string?
```

These are audit/rollback traces written by the migration script. They are not
part of the Dart `TransactionEntity` or Drift cache in V1.

Default when missing:

- `settlementStatus = paid`
- `dueDate = date`
- `settledAt = null`
- `recurrence = single`

Indexes (transaction entries in `firestore.indexes.json`):

```text
transactions: userId + date desc
transactions: accountId + userId + date desc
transactions: userId + recurrence + date desc
transactions: userId + recurrenceGroupId + dueDate desc
transactions: settlementStatus + dueDate asc   (cross-user notifyTransactionsDue query)
```

The existing `bills/{id}` collection remains after migration as read-only /
deprecated rollback/audit data.

## Drift

`LocalTransactions` gains:

```dart
TextColumn get settlementStatus =>
    text().withDefault(const Constant('paid'))();
DateTimeColumn get dueDate => dateTime().nullable()();
DateTimeColumn get settledAt => dateTime().nullable()();
TextColumn get recurrence => text().withDefault(const Constant('single'))();
TextColumn get recurrenceGroupId => text().nullable()();
IntColumn get recurrenceIntervalMonths =>
    integer().withDefault(const Constant(1))();
IntColumn get recurrenceIndex => integer().nullable()();
IntColumn get recurrenceTotal => integer().nullable()();
TextColumn get recurrenceBaseDescription => text().nullable()();
DateTimeColumn get recurrenceEndDate => dateTime().nullable()();
```

Because local cache is disposable and the database migration already drops and
recreates tables on version mismatch, bump `schemaVersion` and regenerate Drift.

## UI Contract

### Navigation

Replace the visible "Bills" concept with:

- Portuguese: `Contas`
- Page title: `Contas a pagar e receber`
- Legacy route `/bills` remains as an alias so notifications and bookmarks keep
  working.

### Main View

The page has two primary sections:

1. `A pagar e receber`
   - Tabs: `A pagar`, `A receber`
   - Shows only `settlementStatus = pending`
   - Pending rows are grouped into list sections by due status:
     - `Atrasadas` (overdue) — expense accent
     - `Hoje` (due today) — warning accent
     - `Próximas` (future due date) — warning accent
   - Empty sections are hidden.
2. `Pagas e recebidas`
   - Tabs: `Pagas`, `Recebidas`
   - Shows only `settlementStatus = paid`, in a single `Pagas`/`Recebidas`
     section

For desktop/tablet, follow the reference layout:

- Left rail/card column:
  - month/year selector
  - period summary
  - account filters with totals
- Main list:
  - status dot
  - due/settlement date
  - account chip
  - category chip
  - description
  - amount
  - row actions

For mobile:

- Keep the same information hierarchy, but use stacked cards/list tiles and the
  existing bottom navigation rules.

### Row Status

Pending payable/receivable:

| State | Dot | Label |
|---|---|---|
| Overdue | expense color | `Atrasada` / `Atrasado` |
| Due today | warning color | `Hoje` |
| Future | muted/warning color | `Agendada` / `Agendado` |

Paid/received:

| Type | Label |
|---|---|
| expense | `Paga` |
| income | `Recebida` |

### Create / Edit Form

Reuse `AddTransactionPage`, but add a settlement control:

- `Pago/Recebido agora`
- `Agendar / deixar pendente`
- Recurrence toggle: `Única`, `Parcelada`, `Fixa`
- Recurrence settings: month-based cadence and installment count, capped by the
  rolling 12-month window.

Behavior:

- If date is future, force pending.
- If pending, label date field as due date.
- If paid, label date field as transaction date.
- Account and category remain required in V1.
- Transfer mode disables scheduled/pending in V1.
- Transfer mode disables recurrence.
- Existing sequence rows keep recurrence immutable. Editing/deleting a recurring
  row opens a scope dialog.

### Settlement Flow

Tapping "mark as paid/received" on a pending row settles it in one tap:

- The row action immediately calls `SettleTransactionUseCase(transaction)`
  with today as the settlement date — there is no confirmation sheet and no
  date/account adjustment step in V1.
- On success the page shows a paid/received snackbar and refreshes itself plus
  dependent state (`TransactionsBloc`, `DashboardBloc`, `AccountsCubit`).
- Settling updates the existing transaction; it does not create a second
  record.

## Dashboard / Reports / Balances

All financial calculations must explicitly use paid transactions only.

Affected areas:

- `AccountsCubit` and account running balance
- account statement page
- dashboard repository
- budgets overview
- 50/30/20 computation
- category drill-down
- CSV import totals
- any AI context summaries that mention real monthly spending

Rule:

```dart
final paidTransactions = transactions.where((tx) => tx.isPaid);
```

Pending transactions may be used in cash-flow forecast / payables receivables
contexts and as visual rows in account statements. They must still be excluded
from financial totals and running balances.

## Notifications

`notifyBillsDue` was deleted from Firebase on 2026-06-10 and replaced by
`notifyTransactionsDue`.

Query:

```text
transactions
where settlementStatus == "pending"
where dueDate <= endOfToday
```

Grouping:

- group by `userId`
- split counts into overdue and due today
- optionally split by payable/receivable for body copy

FCM data:

```json
{
  "type": "transactions_due",
  "route": "/payables-receivables",
  "userId": "...",
  "count": "3",
  "title": "...",
  "body": "..."
}
```

The Flutter client also drops already-queued legacy pushes with
`type == "bills_due"` or `route == "/bills"` so old Bills reminders do not
surface after the migration.

## AI Chat

Future payable/receivable requests are represented as normal
`[TRANSACTION_DATA]` blocks with a future `date`; the app stores them as
pending transactions. There is no separate bill/reminder action.

Transaction actions gain:

```json
{
  "action": "create",
  "type": "expense",
  "amount": 200,
  "description": "Internet",
  "date": "2026-07-10",
  "settlementStatus": "pending",
  "recurrence": "fixed",
  "category": "Moradia/Internet",
  "accountName": "Nubank"
}
```

The backend extractor and Flutter chat handler registry only support
transaction-backed scheduled movements.

## Migration Plan

### Phase 1 - Schema and Domain

1. Update `TransactionEntity`, model serialization, Firestore mapping, Drift
   table, DAO, and generated code.
2. Add `TransactionSettlementStatus` and `TransactionRecurrence`.
3. Default legacy transactions to `paid`.
4. Remove the blanket "date cannot be in the future" rule and replace it with:
   - paid cannot be future
   - pending can be future
5. Add unit tests for serialization, copyWith, computed status helpers, and
   form validation.

### Phase 2 - Paid-Only Calculations

1. Audit every consumer of `getTransactions`.
2. Update balances, dashboard, budgets, and 50/30/20 to exclude pending rows.
3. Add regression tests proving pending rows do not affect financial totals.

### Phase 3 - Payables / Receivables UI

1. Keep the page contract transaction-backed in `PayablesReceivablesPage`.
2. Query transactions directly instead of using the removed legacy `BillsBloc`.
3. Implement tabs:
   - `A pagar`
   - `A receber`
   - `Pagas`
   - `Recebidas`
4. Group pending rows into `Atrasadas` / `Hoje` / `Próximas` sections.
5. One-tap settle action on each pending row (no confirmation sheet shipped
   in V1).
6. Keep route `/bills` as alias.

### Phase 4 - Create/Edit Flow

1. Extend `AddTransactionPage` and `TransactionFormCubit` with pending/paid
   controls.
2. Future date should automatically make the transaction pending.
3. Marking a pending transaction paid should update the existing transaction.
4. Installment/fixed recurrence should create generated pending occurrences in
   one batch, limited by the 12-month window.

### Phase 5 - Notifications

Status: completed on 2026-06-10.

1. `functions/src/bills/notifyBillsDue.ts` was replaced with
   `functions/src/transactions/notifyTransactionsDue.ts`.
2. The deployed `notifyBillsDue` function was deleted from Firebase project
   `financo-app-2026`.
3. The new notification type is `transactions_due`.
4. Notification taps route to `/payables-receivables`.
5. Client-side cross-account filtering remains unchanged.
6. Client-side legacy push filtering drops `bills_due` and `/bills` payloads.
7. Backend unit tests cover message grouping.

### Phase 6 - Legacy Bills Migration

Status: completed on 2026-06-10.

1. One-time migration script was added at
   `scripts/migrate_bills_to_transactions.js`.
2. Pending bills created pending transactions with deterministic ids
   `legacy_bill_<billId>` and `sourceBillId = bill.id`.
3. Paid bills with `paidTransactionId` updated existing transactions with
   `settlementStatus = paid`, `dueDate = bill.dueDate`, and
   `settledAt = bill.paidAt ?? bill.dueDate`.
4. Production result: 22 bills processed, 12 transactions created, 10 existing
   transactions updated, 0 skipped, 0 errors.
5. A final dry-run confirmed idempotency: 0 creates, 0 updates, 22 already
   migrated.
6. The app UI no longer reads `bills`; keep the collection for rollback/audit
   until explicitly archived.

### Phase 7 - Cleanup

Status: completed on 2026-06-10.

1. Removed deprecated bill-only entities, models, repository, use cases,
   form cubit, bloc, match suggestion flow, CSV import UI, and navigation
   badge.
2. Removed `AddBillPage`, `/bill/add`, and `/bill/edit`; users create
   scheduled payables/receivables through `AddTransactionPage`.
3. Removed `BillRepository`, `BillRemoteDataSource`, and `BillsDao` from DI.
4. Removed `local_bills` from the Drift schema. App startup/migration drops the
   old local table if it still exists.
5. Removed `bills` from startup sync so Firestore legacy documents no longer
   repopulate local cache.
6. Removed `BillChatActionHandler` and obsolete bill-handler i18n strings.
7. AI prompt/actions now use scheduled transactions and no longer support a
   separate bill action.

## Testing Checklist

- Future pending transaction can be created.
- Future paid transaction is rejected.
- Past/today pending transaction can be created and appears as overdue/due today.
- Pending expense does not reduce account balance.
- Pending income does not increase account balance.
- Pending rows do not affect dashboard totals.
- Pending rows do not affect budgets or 50/30/20.
- Marking payable as paid updates the same transaction.
- Marking receivable as received updates the same transaction.
- Installment transaction splits the total amount across generated rows.
- Fixed transaction keeps a rolling 12-month window without unbounded writes.
- Sequence edit/delete scope does not mutate already paid rows.
- Notification function sends only for pending due/overdue transactions.
- Legacy transaction without `settlementStatus` loads as paid.
- Legacy bill migration does not duplicate linked paid transactions.

## Open Questions

1. Should pending transactions require an account, or should the user be able to
   schedule a payable before knowing which account will pay it?
2. Should settlement allow partial payment, or is V1 strictly full amount only?
3. Should future pending transactions appear in the normal Transactions tab, or
   only in the payables/receivables page?
4. Should overdue badges count receivables and payables together, or show
   separate counts?
