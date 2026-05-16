# Bills Feature Spec

Bills are user-defined reminders for upcoming money movements with a due date. A bill can be either **payable** (Conta a Pagar — e.g. internet, rent) or **receivable** (Conta a Receber — e.g. salary, freelance invoice). They live separately from `transactions` — a bill represents an *intent* to pay/receive; once settled it produces a real `TransactionEntity` (expense for payable, income for receivable) that is linked back via `paidTransactionId`.

The feature is reachable from the main navigation (bottom bar on mobile, sidebar on web) — it is no longer nested under Profile/Settings.

## Entity Contract

```dart
BillEntity {
  id:                       String           (required, Firestore doc id)
  userId:                   String           (required, owner)
  type:                     BillType         (required: payable | receivable)
  description:              String           (required, non-empty)
  amount:                   double           (required, > 0)
  dueDate:                  DateTime         (required, time normalized to 00:00 local)
  status:                   BillStatus       (required: pending | paid)
  recurrence:               BillRecurrence   (required: oneShot | monthly)
  categoryId:               String?          (optional category — must match type)
  notes:                    String?          (optional free-text)
  paidAt:                   DateTime?        (set when status = paid)
  paidTransactionId:        String?          (set when status = paid)
  parentBillId:             String?          (id of the previous occurrence for monthly)
  rejectedTransactionIds:   List<String>     (transaction ids the user said are NOT this bill — see Match Suggestions)
  createdAt:                DateTime         (set on creation)
  updatedAt:                DateTime         (set on creation and update)
}

bool get isOverdue =>
    status == BillStatus.pending && dueDate.isBefore(_startOfToday());

bool get isDueToday =>
    status == BillStatus.pending && _isSameDay(dueDate, DateTime.now());
```

## Business Rules

1. **Description is optional** — empty strings are allowed and render as blank (no fallback label). The category and date in the subtitle already convey enough context.
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
13. **Monthly recurrence on settlement** — when a `monthly` bill is settled, the repository **creates a new pending bill** with the same `type`, `description`, `amount`, `categoryId`, `notes`, `recurrence = monthly`, `parentBillId = paidBill.id`, and `dueDate = nextMonthlyDueDateAfter(paidBill.dueDate, now)` — i.e., the first canonical monthly tick that is **not before today**.
14. **`nextMonthlyDueDate` clamps to last valid day** — Jan 31 → Feb 28/29 (leap year aware). Implementation: `DateTime(d.year, d.month + 1, min(d.day, lastDayOfMonth(d.year, d.month + 1)))`. Used by the virtual projection (which models the calendar exactly, one tick at a time).
15. **`nextMonthlyDueDateAfter` fast-forwards stale chains** — settling a late monthly bill (original `dueDate` already several months in the past) must not produce an occurrence whose `dueDate` is **also** in the past, otherwise the next-day `notifyBillsDue` Cloud Function would fire for a bill the user has *just* taken action on, and each subsequent settlement would create yet another born-overdue child. The helper iterates `nextMonthlyDueDate` until the candidate is `>= startOfToday`, preserving the original day-of-month preference (`day = min(originalDay, lastDayOfMonth(year, month))`) at every step. Examples (today = May 8):
    - base Apr 1  → returns May 1 (still actionable today, not overdue).
    - base Mar 1  → returns Jun 1 (May 1 is in the past, skip).
    - base Jan 31 → returns May 31 (day-31 preference preserved).
    - base May 8  → returns Jun 8 (no fast-forward; on-time payment).
   Trade-off: a user who genuinely owes multiple months will lose the intermediate occurrences (they won't see a May bill if they paid an Apr bill on May 8). They can recreate them manually if needed. The default optimizes for the common case — paying late is usually book-keeping catch-up, not actual unpaid months.
16. **Deleting a paid bill does NOT delete the linked transaction** — the transaction is independent.
17. **Deleting a pending bill** is a simple Firestore + Drift delete, no cascades.

### Settlement UI Flow

Tapping the check button on a bill tile no longer opens a quick dialog with two dropdowns. The user is sent to the regular `AddTransactionPage` with the bill's data prefilled — they confirm or adjust the transaction details before saving. The "create a transaction implicitly" path (`payBill` use case) stays in the repository for the AI chat handler, but the UI prefers the form-based confirmation.

- **Prefilled fields**: `description = bill.description`, `amount = bill.amount`, `type` = `expense` (payable) or `income` (receivable), `categoryId = bill.categoryId`, `date = today`. The user picks the account and reviews the rest.
- **Type toggle is locked** when prefilling from a bill — switching to "Transfer" (or flipping income↔expense) would invalidate the bill link, so the toggle disables to keep the intent clear.
- **App bar title** reads `Confirm payment` (payable) or `Confirm receipt` (receivable) instead of the generic `New Transaction`, signalling the bill-settlement context.
- **On submit success**, the page dispatches `BillMatchAccepted(billId, createdTx.id)` to the `BillsBloc`, which routes through `linkBillToExistingTransaction` — same code path the match-suggestion sheet uses. The bill becomes paid and the monthly chain advances exactly as in the legacy `payBill` flow.
- **If the user backs out** without saving, the bill stays pending. Nothing happens.

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

  /// Settles a pending bill against a transaction the user already
  /// recorded (no new transaction is created). Used by Match Suggestions
  /// when the user confirms "yes, that transaction was this bill".
  Future<Either<Failure, BillPaymentResult>> linkBillToExistingTransaction({
    required String billId,
    required String transactionId,
  });

  /// Records that the user said "no, that transaction is NOT this bill"
  /// for a Match Suggestion. The transaction id is appended to
  /// `bill.rejectedTransactionIds` so we never offer the same pair again.
  Future<Either<Failure, BillEntity>> rejectBillTransactionMatch({
    required String billId,
    required String transactionId,
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

## Future Occurrence Preview (Virtual Bills)

Monthly bills are not eagerly materialized. Instead, when the user navigates to a month where the chain doesn't yet have a real occurrence, the page projects a **virtual** preview of what that occurrence would be — without writing anything to Firestore or Drift. Materialization happens at settlement time (existing `payBill` / `linkBillToExistingTransaction` flow).

### Projection rule

For each monthly chain (`recurrence == monthly`), find the most recent real bill (by `dueDate`) that is *not* paid-and-already-followed-by-a-real-child. From that anchor, generate virtual occurrences forward by repeatedly applying `nextMonthlyDueDate` (clamping the day to the last valid day of each month) until either:

- `dueDate.year == targetYear && dueDate.month == targetMonth` is reached, OR
- a hard cap of **24 months ahead of the anchor** is hit (safety: prevents creating dozens of previews if the user jumps far into the future).

Each virtual bill copies `userId`, `type`, `description`, `amount`, `categoryId`, `notes`, `recurrence` from the anchor; gets `id = ''` (sentinel for "not persisted"), `status = pending`, `paidAt = null`, `paidTransactionId = null`, `parentBillId = null`, `rejectedTransactionIds = []`.

### `BillEntity.isVirtual` getter

```dart
bool get isVirtual => id.isEmpty;
```

The empty-string id is already the project's convention for "not yet persisted" (used at creation time before Firestore assigns one). The list-rendering layer treats `isVirtual` as the canonical signal.

### UI restrictions on virtual bills

Virtual bills are **read-only previews**:

- No "pay" button on the tile.
- Swipe-to-delete is disabled.
- Tap shows a snackbar: `t.bills.virtualBlocked` ("Pague a ocorrência atual primeiro") instead of opening the edit form.
- Match suggestions never include virtual bills (no id to link).
- `BillsSummary` ("This month") **does** include virtuals in its totals — the user wants to see the projected month total.

### Pay rule for real bills

A real (non-virtual) bill is settleable via the tile's pay button iff ALL:

1. `bill.status == BillStatus.pending`
2. `bill.dueDate < firstDayOfNextRealMonth` — i.e. the bill belongs to the current real-calendar month or earlier. Bills due in months *after the current real month* are not directly payable; the user has to wait or settle the prior occurrence first.

This rule is independent of the navigated month (`DateFilterCubit`) — the calendar boundary is what matters for whether a real-world payment can apply.

## Editing Recurrent Bills (Scope Dialog)

When the user edits a `monthly` bill (real, pending) and submits, a dialog asks:

- **Apenas esta** — only the edited bill is updated.
- **Esta e as subsequentes** — the edited bill PLUS every real bill in its chain whose `dueDate` is strictly after the edited bill's `dueDate` are updated.

Anteriores são intocáveis (regra: nunca reprocessar histórico).

### Propagation rule for "subsequentes"

For each real subsequent bill in the chain (descendants via `parentBillId`):

- `description`, `amount`, `categoryId`, `notes`, `type`: copied verbatim from the edited bill.
- `dueDate`: only the **day-of-month** is propagated. Each subsequent's year/month is preserved; its day becomes `min(edited.dueDate.day, lastDayOf(subsequent.year, subsequent.month))`.
- `recurrence` is immutable post-creation (existing rule), so it never changes.
- `status`, `paidAt`, `paidTransactionId`: preserved on each subsequent (recurrence has no impact on settlement state).

Virtual occurrences are **not** updated directly — they are projected from the most recent real bill in the chain, so updating the real subsequents automatically reflects on every projected preview.

If the chain has paid bills mixed in (e.g. bill paid in jul, pending in ago), paid bills are untouched (they are part of the immutable history). The propagation walks the chain and skips paid ones from being mutated, but their `id`s are still followed to find further descendants.

## Bills List Display

The Bills tab uses the global `DateFilterCubit` (year + month) to scope what's shown. The bloc still loads every bill (cache-only); the page filters the list before rendering.

### Visibility rule

A bill is visible in the list iff ANY:

1. `bill.dueDate` falls inside the selected month (year + month equality).
2. `bill.status == pending` AND `!bill.isVirtual` AND `bill.dueDate < firstDayOf(selectedYear, selectedMonth)` — overdue carry-over from earlier months stays visible until settled.

Bills with `dueDate` in months *after* the selected month are hidden — the user has to navigate forward to see them.

Virtual previews (projected occurrences) are never carried over: a virtual bill is only visible when its `dueDate` lands inside the selected month. A virtual from an earlier month would just duplicate information already conveyed by the overdue real bill that anchors the chain.

The `matchCandidates` banner respects the same visibility rule: if a candidate's bill is hidden (e.g. paid bill from a previous month), the banner doesn't surface it for the current month view.

### Tile layout

Each `BillTile` shows:

- Top: `bill.description`.
- Subtitle: `dd/MM · Categoria › Subcategoria · status`, where:
  - `dd/MM` is always present (the bill's `dueDate`).
  - Category is `category.displayPath(allCategories)` (omitted when no category or unresolved).
  - Status is the localized phrase: `Paid` / `Received` for settled, `Due today`, `tomorrow`, `in N days`, or `N days overdue` for pending. Monthly recurrence appends `· Monthly` for pending bills.

The `BillsSummaryCard` ("This month") computes its totals from the *filtered* list, so toggling the month also re-scopes the totals.

## Match Suggestions

When the user is in the Bills tab, the app cross-references existing transactions against pending bills and proposes "did you already pay this bill with that transaction?" matches. Confirming a match settles the bill against the existing transaction (no duplicate transaction is created); rejecting it remembers the rejection for that specific bill.

### Match rule

A `(BillEntity, TransactionEntity)` pair is a **match candidate** iff ALL hold:

1. `bill.status == BillStatus.pending` AND `bill.paidTransactionId == null`.
2. `bill.categoryId != null` AND `tx.categoryId != null` AND `tx.categoryId == bill.categoryId`.
3. `(tx.amount - bill.amount).abs() < 0.01` (cent-level tolerance — guards against double precision noise).
4. `isSameDay(tx.date, bill.dueDate)` — same calendar day (year + month + day; time of day ignored).
5. The transaction type matches the bill type:
   - `bill.type == payable` → `tx.type == expense`
   - `bill.type == receivable` → `tx.type == income`
6. `tx.id ∉ bill.rejectedTransactionIds` — the user has not already said "not this one" for this exact pair.
7. `tx.id` is not the `paidTransactionId` of any other bill in the dataset — so we don't keep suggesting an already-claimed transaction.

A single bill may have multiple candidate transactions; a single transaction may be a candidate for multiple bills. Both cases are surfaced — the user picks per pair.

### User actions

- **Confirm** (`linkBillToExistingTransaction`):
  - Marks `bill.status = paid`, `paidAt = now`, `paidTransactionId = tx.id`, `updatedAt = now`. **No new transaction is created** — that's the whole point.
  - Reuses the monthly recurrence rule from `payBill`: if the bill is `monthly`, creates the next occurrence with `parentBillId = bill.id` and clamped `dueDate`.
  - Returns `BillPaymentResult` with the existing transaction (not a new one) so callers can react identically to `payBill`.
- **Reject** (`rejectBillTransactionMatch`):
  - Appends `tx.id` to `bill.rejectedTransactionIds` (deduped) and persists via `updateBill`.
  - The pair is silently filtered out of all future match scans for this bill.
  - When a `monthly` bill is paid and a new occurrence is created, the new bill starts with `rejectedTransactionIds = []` — the user is asked again for the new month's coincidences. This is the expected behavior, by design.

### Edge cases

- **Bill missing `categoryId`** (legacy) — never produces a match (rule 2). The user has to pay it the normal way.
- **Confirmed but `tx.categoryId` differs from `bill.categoryId`** — can't happen (rule 2 already filters), but the resulting `BillPaymentResult.transaction` is the existing tx unchanged; we do NOT rewrite the transaction's category to the bill's category.
- **Same transaction confirmed for two bills sequentially** — after the first confirmation, the transaction becomes another bill's `paidTransactionId`, so rule 7 kicks in and the second bill's suggestion disappears.
- **User pays the bill via the normal `payBill` flow while a suggestion was open** — rule 1 fails on next scan; the suggestion disappears.

### UI flow (BillsPage)

- On page mount, `BillsBloc` loads bills AND transactions (cache-only, no date filter) so the candidate scan has full data.
- If `BillsLoaded.matchCandidates.isNotEmpty`, a banner renders above the summary card: "$count possível(s) pagamento(s) detectado(s)" → tapping opens a bottom sheet.
- Bottom sheet (`BillMatchSheet`) groups by bill; each bill shows its candidate transactions with **Sim** / **Não** buttons per candidate.
- Confirm dispatches `BillMatchAccepted(billId, transactionId)`; reject dispatches `BillMatchRejected(billId, transactionId)`. Both trigger a force-refresh on success.

## Navigation Badge

The Bills entry in the bottom bar (mobile) and sidebar (web/tablet) shows a red count badge when the user has actionable pending bills, so the pending state is visible from any tab without opening Bills.

**Rule**

* `actionablePendingCount` = number of bills with `status == pending` AND (`isOverdue` OR `isDueToday`).
* Same definition the Cloud Function `notifyBillsDue` uses to fire push notifications, kept in sync on purpose.
* `upcoming` (pending but `dueDate > today`) does **not** count — the badge is for things that need action *now*.
* `paid` bills do **not** count regardless of `dueDate`.

**Rendering**

* Count `0` → no badge (icon renders normally).
* Count `1..99` → red circle (`AppColors.expense`) with the number.
* Count `> 99` → display `99+`.
* Same widget for mobile and web; positioned at the top-right of the icon.

**Data flow**

* The count is derived from `BillsLoaded.actionablePendingCount`. The nav widgets `watch` `BillsBloc` and read the value off the loaded state.
* `BillsBloc` is created at the app shell level. To populate the badge before the user visits the Bills tab, the shell dispatches `BillsLoadRequested()` (no filter, cache read) when the bloc is created.
* After `BillPaymentRequested` / `BillDeleteRequested` / `BillsLoadRequested(forceRefresh: true)` completes, the bloc re-emits `BillsLoaded` and the badge updates automatically.
* When state is `Initial`, `Loading`, or `Error`, the badge is hidden.

## Notifications

A scheduled Cloud Function (`notifyBillsDue`, `onSchedule('every day 09:00', timeZone: 'America/Sao_Paulo')`) queries `bills` where `status == pending AND dueDate <= today`, groups by `userId`, fetches each user's `users/{userId}/fcmTokens` subcollection, and sends a **data-only** multicast FCM message:

- Data: `{ type: 'bills_due', count: N, route: '/bills', userId, title, body }`.
  - `title` and `body` carry the rendered strings ("Você tem N contas a pagar" / "X atrasada(s) e Y vencendo hoje"); they live in `data` instead of the `notification` block so the client has a chance to filter before display.
  - `userId` is the recipient — required so the client can enforce cross-account isolation (see below).

The Flutter `NotificationService`:
- Initializes `firebase_messaging` and `flutter_local_notifications`.
- On sign-in: saves the FCM token to `users/{userId}/fcmTokens/{tokenId}`.
- On sign-out: fetches the current token via `_messaging.getToken()` (not a cached value — that cache is empty after an app restart, which was the exact scenario that left orphan tokens behind) and deletes the doc.
- Foreground messages: dropped if `data.userId != FirebaseAuth.currentUser.uid`, otherwise displayed via `flutter_local_notifications`.
- Background/terminated messages: a top-level handler (`notificationBackgroundHandler`) re-initializes Firebase in the spawned isolate, applies the same uid filter, and displays via `flutter_local_notifications`. Lives outside the class on purpose — FCM background isolates can't capture instance state.
- Background tap: routes to `/bills`.

### Cross-account isolation

FCM tokens persist across sign-ins on a device. If account A and account B both ever signed in on the same physical device, the token ends up under both `users/A/fcmTokens` and `users/B/fcmTokens`. The daily Cloud Function pushes for *both* accounts to that token, so the device — currently signed in as only one of them — was receiving the other account's reminders.

The fix lives on both sides:

1. **Server** (`notifyBillsDue`) tags every push with `data.userId` and sends data-only (no `notification` field). Data-only is required because Android auto-displays anything in the `notification` block before the app sees it.
2. **Client** (`NotificationService.shouldDeliver`) compares `data.userId` against `FirebaseAuth.currentUser?.uid`:
   - Match → display.
   - Mismatch or no current user → drop silently and log.
   - Missing `data.userId` (legacy) → deliver, to stay backwards-compatible with untargeted pushes.

Note: the client cannot clean up the orphan token registration directly — Firestore rules block writes to another user's `fcmTokens` subcollection. The wasted push is acceptable in scale; a future cleanup trigger (`onCreate(users/{uid}/fcmTokens/{tokenId})` with a collection-group sweep) can dedup using admin SDK.

### Notification appearance (Android)

- App name in the notification header reads **`Financo`** (matches `android:label`).
- Small icon is a **monochrome silhouette** (`@drawable/ic_notification`) — Android requires the small icon to be opaque white on transparent so it can be tinted by the system. Using the colored launcher icon falls back to the generic placeholder bell on Android 5+.
- Tinted with the brand primary `#6366F1` via `<meta-data name="com.google.firebase.messaging.default_notification_color">`.
- Both the FCM-backed cloud notification and the foreground local notification reuse the same drawable + color so cold/warm/foreground deliveries look identical.

Body monetary values are formatted as BR currency (`R$ 2.000,00`) — the cloud function uses `Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' })`.
