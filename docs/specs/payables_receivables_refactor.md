# Payables / Receivables Refactor Spec

This spec defines the replacement for the current `bills` feature. The goal is
to make scheduled money movements first-class transactions instead of keeping a
separate, duplicate bill model.

Current problem:

- `BillEntity` is an intent that later creates or links a `TransactionEntity`.
- `TransactionEntity.date` currently rejects future dates.
- The user has to think in two concepts: bills and transactions.
- The UI does not match the mental model of "I have a future transaction, but
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

## V1 Implementation Scope

The first implementation ships the core transaction-based behavior:

- `settlementStatus`, `dueDate`, `settledAt`, and `recurrence` on transactions.
- Future dates allowed through `AddTransactionPage` when the transaction is
  pending.
- `BillsPage` reads transactions and renders `A pagar`, `A receber`, `Pagas`,
  and `Recebidas`.
- The shell navigation exposes two Dashboard child entries:
  `A pagar e receber` and `Pagas e recebidas`.
- `A pagar e receber` has two internal tabs: `A pagar` and `A receber`.
- `Pagas e recebidas` has two internal tabs: `Pagas` and `Recebidas`.
- Planning no longer hosts a bills/accounts sub-tab.
- Settlement updates the same transaction.
- Financial calculations ignore pending transactions.
- `notifyBillsDue` queries pending transactions.

Deferred from V1:

- `parentTransactionId` and `sourceBillId`.
- Automatic next occurrence creation for monthly recurrence.
- Full `[BILL_ACTION]` chat migration.
- One-time migration from the legacy `bills` collection.

## Entity Contract

`TransactionEntity` gains scheduling and settlement fields:

```dart
enum TransactionSettlementStatus { pending, paid }
enum TransactionRecurrence { oneShot, monthly }

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
  dueDate:               DateTime?       // required when pending; defaults to date when paid
  settledAt:             DateTime?       // set when status becomes paid
  recurrence:            TransactionRecurrence // oneShot | monthly
  parentTransactionId:   String?         // previous occurrence for monthly chains
  sourceBillId:          String?         // legacy migration trace only

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
bool get isPayable => type == TransactionType.expense && !isTransfer;
bool get isReceivable => type == TransactionType.income && !isTransfer;
DateTime get effectiveDueDate => dueDate ?? date;

bool get isOverdue =>
  isPending && startOfDay(effectiveDueDate).isBefore(startOfToday());

bool get isDueToday =>
  isPending && isSameDay(effectiveDueDate, DateTime.now());
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

Monthly recurrence moves from `BillEntity` to `TransactionEntity`.

When a monthly pending transaction is settled:

1. Update the current transaction to `paid`.
2. Create the next pending transaction with:
   - same `userId`, `accountId`, `categoryId`, `type`, `amount`,
     `description`, `notes`
   - `settlementStatus = pending`
   - `recurrence = monthly`
   - `parentTransactionId = paidTransaction.id`
   - `dueDate = nextMonthlyDueDateAfter(paidTransaction.effectiveDueDate, today)`
   - `date = dueDate`
3. The monthly date helper should reuse the existing `monthly_due_date.dart`
   rules from the bills feature.

Virtual projected monthly bills are not part of this refactor's V1. V1 should
materialize the next occurrence only after settlement, matching the current
practical behavior.

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
  bool includePending = true,
  bool forceRefresh = false,
});
```

New use cases:

```dart
class MarkTransactionSettledUseCase {
  Future<Either<Failure, TransactionEntity>> call({
    required String transactionId,
    required DateTime settlementDate,
  });
}

class GetPayablesReceivablesUseCase {
  Future<Either<Failure, PayablesReceivablesOverview>> call({
    required String userId,
    required int year,
    required int month,
    required PayablesReceivablesMode mode,
    required TransactionType type,
    bool forceRefresh = false,
  });
}
```

`BillRepository` becomes legacy-only during migration and should not be used by
new UI flows after the refactor lands.

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
recurrence: "oneShot" | "monthly"
parentTransactionId: string?
sourceBillId: string?
```

Default when missing:

- `settlementStatus = paid`
- `dueDate = date`
- `settledAt = null`
- `recurrence = oneShot`
- `parentTransactionId = null`
- `sourceBillId = null`

Indexes:

```text
transactions: userId + settlementStatus + dueDate asc
transactions: userId + settlementStatus + type + dueDate asc
transactions: userId + settlementStatus + date desc
transactions: accountId + userId + settlementStatus + date desc
```

The existing `bills/{id}` collection remains during migration, then becomes
read-only / deprecated.

## Drift

`LocalTransactions` gains:

```dart
TextColumn get settlementStatus =>
    text().withDefault(const Constant('paid'))();
DateTimeColumn get dueDate => dateTime().nullable()();
DateTimeColumn get settledAt => dateTime().nullable()();
TextColumn get recurrence => text().withDefault(const Constant('oneShot'))();
TextColumn get parentTransactionId => text().nullable()();
TextColumn get sourceBillId => text().nullable()();
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
   - Chips:
     - `Pendentes`: overdue + due today
     - `Agendados`: future due date
2. `Pagas e recebidas`
   - Tabs: `Pagas`, `Recebidas`
   - Shows only `settlementStatus = paid`

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

Behavior:

- If date is future, force pending.
- If pending, label date field as due date.
- If paid, label date field as transaction date.
- Account and category remain required in V1.
- Transfer mode disables scheduled/pending in V1.

### Settlement Flow

Tapping "mark as paid/received" on a pending row opens a confirmation sheet:

- Title: `Confirmar pagamento` or `Confirmar recebimento`
- Fields:
  - settlement date, default today
  - optional account adjustment if the user picked the wrong account
- Confirm updates the existing transaction; it does not create a second record.

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

Pending transactions may be used only in cash-flow forecast / payables
receivables contexts.

## Notifications

Replace `notifyBillsDue` with a transaction-based function.

Query:

```text
transactions
where settlementStatus == "pending"
where dueDate <= endOfToday
where type in ["expense", "income"]
```

Grouping:

- group by `userId`
- split counts into overdue and due today
- optionally split by payable/receivable for body copy

FCM data:

```json
{
  "type": "payables_receivables_due",
  "route": "/bills",
  "userId": "...",
  "count": "3",
  "title": "...",
  "body": "..."
}
```

Route may stay `/bills` as a compatibility alias, but the visible page should be
the new payables/receivables UI.

## AI Chat

The AI should stop emitting `[BILL_ACTION]` for new flows.

Transaction actions gain:

```json
{
  "action": "create",
  "type": "expense",
  "amount": 200,
  "description": "Internet",
  "date": "2026-07-10",
  "settlementStatus": "pending",
  "recurrence": "monthly",
  "category": "Moradia/Internet",
  "accountName": "Nubank"
}
```

For compatibility, the client may keep parsing `[BILL_ACTION]` temporarily and
translate it into scheduled transaction creation.

AI context should include:

- overdue pending transactions
- due-today pending transactions
- upcoming pending transactions for the current month

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

1. Remodel `BillsPage` into `PayablesReceivablesPage` or keep the filename
   temporarily but change the contract.
2. Replace `BillsBloc` data source with transaction queries.
3. Implement tabs:
   - `A pagar`
   - `A receber`
   - `Pagas`
   - `Recebidas`
4. Implement pending status chips:
   - `Pendentes`
   - `Agendados`
5. Add settlement confirmation sheet.
6. Keep route `/bills` as alias.

### Phase 4 - Create/Edit Flow

1. Extend `AddTransactionPage` and `TransactionFormCubit` with pending/paid
   controls.
2. Future date should automatically make the transaction pending.
3. Marking a pending transaction paid should update the existing transaction.
4. Monthly recurrence should create the next pending occurrence after
   settlement.

### Phase 5 - Notifications

1. Replace `functions/src/bills/notifyBillsDue.ts` query with pending
   transactions query.
2. Update notification type and body copy.
3. Keep client-side cross-account filtering unchanged.
4. Route taps to the new page through `/bills` alias.
5. Add backend unit tests for message grouping.

### Phase 6 - Legacy Bills Migration

1. One-time migration script:
   - Pending bill -> create pending transaction with `sourceBillId = bill.id`.
   - Paid bill with `paidTransactionId` -> update existing transaction with
     `settlementStatus = paid`, `dueDate = bill.dueDate`, `settledAt = bill.paidAt`.
   - Paid bill without `paidTransactionId` -> create a paid transaction only if
     manual review confirms it is not already duplicated.
2. After migration, UI stops reading `bills`.
3. Keep `bills` collection for rollback until verified.
4. Remove or archive `BillRepository` only after production data is migrated.

### Phase 7 - Cleanup

1. Remove deprecated bill-only use cases and match suggestion flow if no longer
   needed.
2. Update README and feature docs.
3. Update CSV samples and import docs.
4. Update AI prompt/actions to prefer scheduled transactions.

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
- Monthly pending transaction creates next occurrence after settlement.
- Notification function sends only for pending due/overdue transactions.
- Legacy transaction without `settlementStatus` loads as paid.
- Legacy bill migration does not duplicate linked paid transactions.

## Open Questions

1. Should pending transactions require an account, or should the user be able to
   schedule a payable before knowing which account will pay it?
2. Should settlement allow partial payment, or is V1 strictly full amount only?
3. Should `Pagas/Recebidas` live in the same page as `A pagar/A receber`, or be
   a second sidebar item like the reference app?
4. Should future pending transactions appear in the normal Transactions tab, or
   only in the payables/receivables page?
5. Should overdue badges count receivables and payables together, or show
   separate counts?
