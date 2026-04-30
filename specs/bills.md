# Bills Feature Spec

Bills are user-defined reminders for upcoming money movements with a due date. A bill can be either **payable** (Conta a Pagar — e.g. internet, rent) or **receivable** (Conta a Receber — e.g. salary, freelance invoice). They live separately from `transactions` — a bill represents an *intent* to pay/receive; once settled it produces a real `TransactionEntity` (expense for payable, income for receivable) that is linked back via `paidTransactionId`.

The feature is reachable from the main navigation (bottom bar on mobile, sidebar on web) — it is no longer nested under Profile/Settings.

## Entity Contract

```dart
BillEntity {
  id:                  String          (required, Firestore doc id)
  userId:              String          (required, owner)
  type:                BillType        (required: payable | receivable)
  description:         String          (required, non-empty)
  amount:              double          (required, > 0)
  dueDate:             DateTime        (required, time normalized to 00:00 local)
  status:              BillStatus      (required: pending | paid)
  recurrence:          BillRecurrence  (required: oneShot | monthly)
  categoryId:          String?         (optional category — must match type)
  notes:               String?         (optional free-text)
  paidAt:              DateTime?       (set when status = paid)
  paidTransactionId:   String?         (set when status = paid)
  parentBillId:        String?         (id of the previous occurrence for monthly)
  createdAt:           DateTime        (set on creation)
  updatedAt:           DateTime        (set on creation and update)
}

bool get isOverdue =>
    status == BillStatus.pending && dueDate.isBefore(_startOfToday());

bool get isDueToday =>
    status == BillStatus.pending && _isSameDay(dueDate, DateTime.now());
```

## Business Rules

1. **Description is required** — must be non-empty after trim.
2. **Amount must be positive** — `amount > 0`.
3. **dueDate is date-only** — time component is normalized to `00:00` local before persisting.
4. **Recurrence is immutable after creation** — same pattern as `TransactionType`. Editing a bill cannot change `recurrence`.
5. **Type is immutable after creation** — `BillType` (payable | receivable) is chosen at creation time and cannot be changed later. Default for new bills is `payable`.
6. **Editing a paid bill is blocked** — only `status == pending` bills are editable. The form rejects submit; the AI handler returns an error message.
7. **categoryId is required for new bills** and must reference a category whose type matches the bill type:
   - `BillType.payable` → category must be `expense`
   - `BillType.receivable` → category must be `income`
   The form blocks submit when no category is picked. Validation happens at the form/UI layer (dropdown only shows the matching category type, including subcategories visually indented under their parent) — repository does not re-validate. The entity field stays nullable to keep legacy bills (created before this rule) loadable; only new/edited bills must satisfy it.
7. **Bills are ordered by `dueDate` ascending** in queries (overdue first, then today, then upcoming).
8. **Default sort groups for the UI**:
   - Overdue: `pending` and `dueDate < today`
   - Today: `pending` and `isSameDay(dueDate, today)`
   - Upcoming: `pending` and `dueDate > today`
   - Paid: `status == paid` (most recent first by `paidAt`, last 90 days)
9. **Default recurrence** is `oneShot` for new bills.
10. **Default status** is `pending` for new bills. AI cannot create a bill already paid — must go through `payBill`.

### Settlement Rules

11. **Marking a bill as settled creates a real `TransactionEntity`** whose `type` mirrors the bill type:
    - `BillType.payable` → `TransactionType.expense`
    - `BillType.receivable` → `TransactionType.income`
    Other fields:
    - `amount = bill.amount`
    - `accountId = chosen by user`
    - `categoryId = chosen by user (defaults to bill.categoryId if set)`
    - `description = bill.description`
    - `date = today`
    - `notes = bill.notes`
12. **Bill becomes paid atomically** with transaction creation: `status = paid`, `paidAt = now`, `paidTransactionId = transaction.id`. The `paid` status applies to both payable (was paid) and receivable (was received) — we keep a single status enum for simplicity; the UI label adapts to the type.
13. **Monthly recurrence on settlement** — when a `monthly` bill is settled, the repository **creates a new pending bill** with the same `type`, `description`, `amount`, `categoryId`, `notes`, `recurrence = monthly`, `parentBillId = paidBill.id`, and `dueDate = nextMonthDueDate(paidBill.dueDate)`.
14. **`nextMonthDueDate` clamps to last valid day** — Jan 31 → Feb 28/29 (leap year aware). Implementation: `DateTime(d.year, d.month + 1, min(d.day, lastDayOfMonth(d.year, d.month + 1)))`.
15. **Deleting a paid bill does NOT delete the linked transaction** — the transaction is independent.
16. **Deleting a pending bill** is a simple Firestore + Drift delete, no cascades.

## Repository Contract

```dart
abstract class BillRepository {
  Future<Either<Failure, List<BillEntity>>> getBills({
    required String userId,
    BillStatus? status,
    bool forceRefresh = false,
  });

  Future<Either<Failure, BillEntity>> getBill(String id);

  Future<Either<Failure, BillEntity>> createBill(BillEntity bill);

  Future<Either<Failure, BillEntity>> updateBill(BillEntity bill);

  Future<Either<Failure, void>> deleteBill(String id);

  Future<Either<Failure, BillPaymentResult>> payBill({
    required String billId,
    required String accountId,
    required String categoryId,
  });
}

class BillPaymentResult {
  final BillEntity paidBill;
  final TransactionEntity transaction;
  final BillEntity? nextOccurrence;  // non-null iff the paid bill was monthly
}
```

**Cache strategy:**
- `forceRefresh: false` → read from local Drift cache only (with filters).
- `forceRefresh: true` → fetch from Firestore (with filters), upsert into local cache (`insertAllOnConflictUpdate`), then read local.
- `getBill` → try local first, fallback to remote + cache.
- `createBill` / `updateBill` → write to remote, then upsert local cache.
- `deleteBill` → remote first, then local.
- `payBill` (non-trivial):
  1. Load the bill (remote if not in cache).
  2. Reject if already paid.
  3. Create a `TransactionEntity` via `TransactionRepository.createTransaction(...)`.
  4. Update the bill: `status=paid`, `paidAt=now`, `paidTransactionId=tx.id`, `updatedAt=now`. Persist via `updateBill` (write to remote + upsert local).
  5. If `recurrence == monthly`, create the next occurrence via `createBill(...)`.
  6. Return `BillPaymentResult`.

The `payBill` flow is implemented in `BillRepositoryImpl` and depends on injected `TransactionRepository`. It is **not** atomic across collections — if step 3 succeeds and step 4 fails, the transaction will exist without a paid bill. Acceptable for MVP; in practice the user can re-mark as paid (UI must handle "already-has-tx" case by skipping creation).

## Model Serialization

**Firestore → Model (`BillModel.fromMap`):**

| Firestore field | Dart field | Type cast |
|---|---|---|
| `userId` | `userId` | `String` |
| `type` | `type` | `BillType.values.byName(String)` — defaults to `payable` if missing (legacy docs) |
| `description` | `description` | `String` |
| `amount` | `amount` | `(num).toDouble()` |
| `dueDate` | `dueDate` | `Timestamp → DateTime` |
| `status` | `status` | `BillStatus.values.byName(String)` |
| `recurrence` | `recurrence` | `BillRecurrence.values.byName(String)` |
| `categoryId` | `categoryId` | `String?` |
| `notes` | `notes` | `String?` |
| `paidAt` | `paidAt` | `Timestamp? → DateTime?` |
| `paidTransactionId` | `paidTransactionId` | `String?` |
| `parentBillId` | `parentBillId` | `String?` |
| `createdAt` | `createdAt` | `Timestamp → DateTime` |
| `updatedAt` | `updatedAt` | `Timestamp → DateTime` |

**Model → Firestore (`toJson`):**
- Serializes all fields except `id`.
- DateTime fields → `Timestamp`.
- Enums → `.name` strings.

## State Machines

### BillsBloc (event-driven)

```
Events:
  BillsLoadRequested { forceRefresh, status? }
  BillDeleteRequested { id }
  BillPaymentRequested { billId, accountId, categoryId }

States:
  Initial → Loading → Loaded { bills, statusFilter? }
                    → Error { failure }
  Loaded → BillPaid { paidBill, transaction, nextOccurrence? } → Loaded (re-load)

Load behavior:
  - If already Loaded for same statusFilter AND !forceRefresh → no-op
  - Otherwise → Loading → fetch with optional status filter → Loaded or Error

Delete behavior:
  - Delete the bill → on success, re-dispatch LoadRequested(forceRefresh: true)
  - On failure → Error

Pay behavior:
  - Call payBill(...) → on success emit transient BillPaid (so chat/dashboard can refresh) →
    immediately re-dispatch LoadRequested(forceRefresh: true)
  - On failure → Error
```

### BillFormCubit

```
State: { userId, description, amount, dueDate, recurrence, categoryId,
         notes, status, isPaid, existingId?, failure? }

isEditing = existingId != null
isValid:
  description.trim().isNotEmpty && amount > 0 &&
  (!isEditing || !isPaid)   // paid bills cannot be edited

Default values for new bills:
  recurrence = oneShot
  dueDate    = DateTime.now() (start of day)
  status     = submitting/idle/success/failure (form lifecycle)

Field update methods:
  updateDescription, updateAmount, updateDueDate, updateRecurrence,
  updateCategoryId, updateNotes

submit():
  if !isValid → no-op
  → emit(submitting)
  → isEditing ? updateBill : createBill
  → success: emit(success)
  → failure: emit(failure + Failure)
```

## Edge Cases

- **Empty bills list** — `Loaded` with empty list, not error.
- **Amount parsing** — `double.tryParse` with fallback to 0; UI shows the BR-formatted string.
- **Pay a bill that is already paid** — repository returns `ValidationFailure('Bill already paid')`; UI shows snackbar.
- **Pay a monthly bill on Jan 31** — next occurrence dueDate = Feb 28 (or Feb 29 in leap years).
- **Delete a paid bill** — only the bill record is removed; the linked transaction stays.
- **Edit a paid bill** — form rejects submit before remote call; AI handler returns error message.
- **AI tries to mark unknown bill as paid** — handler returns "Bill not found".
- **Filter `status: paid`** — Drift query restricts; sorted by `paidAt` desc when set, else by `updatedAt` desc.
- **Offline create** — same as transactions: write fails, returns `ServerFailure`. Sync layer doesn't queue (out of scope).

## Firestore

**Collection:** `bills/{id}`

**Indexes:**
- `userId` + `dueDate` (ascending)
- `userId` + `status` + `dueDate` (ascending)

## AI Chat Integration

The AI emits an `[BILL_ACTION]` block. The Flutter `ChatBloc` parses metadata and dispatches to use cases. Same Confirm-button pattern as transactions/accounts/categories.

**Action shapes** (mirror `[TRANSACTION_DATA]` style):

```
[BILL_ACTION]
{"action": "create", "type": "payable", "description": "Conta de luz", "amount": 200.00, "dueDate": "2026-05-05", "recurrence": "monthly", "category": "Moradia", "notes": "..."}
[/BILL_ACTION]

[BILL_ACTION]
{"action": "create", "type": "receivable", "description": "Salário", "amount": 5000.00, "dueDate": "2026-05-05", "recurrence": "monthly", "category": "Salário"}
[/BILL_ACTION]

[BILL_ACTION]
{"action": "update", "billId": "...", "amount": 210.00, "dueDate": "2026-05-15"}
[/BILL_ACTION]

[BILL_ACTION]
{"action": "markPaid", "billId": "...", "accountName": "Nubank", "category": "Moradia"}
[/BILL_ACTION]

[BILL_ACTION]
{"action": "delete", "billId": "..."}
[/BILL_ACTION]
```

The Cloud Function `chat/context.js` injects the user's overdue + due-today bills into the USER CONTEXT block so the AI can mention them proactively in every conversation:

```
⚠ Contas em atraso:
- Internet (R$120, venceu 2026-04-22)
- Aluguel (R$1500, venceu 2026-04-20)

📌 Vencem hoje:
- Luz (R$200)
```

## Notifications

A scheduled Cloud Function (`notifyBillsDue`, `onSchedule('every day 09:00', timeZone: 'America/Sao_Paulo')`) queries `bills` where `status == pending AND dueDate <= today`, groups by `userId`, fetches each user's `users/{userId}/fcmTokens` subcollection, and sends a multicast FCM message:

- Title: "Você tem N contas a pagar"
- Body: "{firstBillDescription} de R${amount} vence hoje" (or "venceu há X dias" if overdue)
- Data: `{ type: 'bills_due', count: N }` — used by the app to deep-link to the Bills page.

The Flutter `NotificationService`:
- Initializes `firebase_messaging` and `flutter_local_notifications`.
- On sign-in: saves the FCM token to `users/{userId}/fcmTokens/{tokenId}`.
- On sign-out: deletes the token.
- Foreground messages: displays via `flutter_local_notifications`.
- Background tap: routes to `/bills`.
