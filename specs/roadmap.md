# Financo — Product Roadmap

> **Status**: Living document
> **Last updated**: 2026-05-02
> **Owner**: Guilherme Passos

A prioritized backlog of features being considered for Financo. Each item has a
**why**, a **scope summary**, an **effort estimate** (S/M/L), and a link to its
spec when one exists.

Priority tiers:

- **P0** — actively being implemented. Only one feature should sit here at a time.
- **P1** — next up. Specs may exist, implementation has not started.
- **P2** — explored, deferred. Captured so the idea isn't lost.
- **P3** — speculative / requires external dependencies (CNPJ, paid APIs, etc).

Effort scale (rough order of magnitude in dev days, single dev):

- **S** — 1–3 days
- **M** — 1–2 weeks
- **L** — 3+ weeks

---

## P0 — In Flight

### Budgets (orçamento por categoria)

> **Spec**: [budgets.md](budgets.md) · **Effort**: M

Monthly cap per root expense category, with current-month progress (spent /
remaining / % used) shown on a dedicated tab. No rollover, expense-only,
parent-level only (subcategory spend rolls up into its parent's cap, mirroring
the dashboard's existing aggregation rule).

**Why**: the most-requested gap in personal-finance apps. Reuses the entire
existing transactions + categories pipeline; the only new persistence is a
flat `budgets` collection. High user value at moderate cost.

**Acceptance**:

- New `Orçamento` tab in the main nav (bottom bar mobile, sidebar web).
- CRUD over budgets (one per root expense category).
- Per-budget progress bar with safe / warning (≥80%) / exceeded (>100%) states.
- Cascade-delete budget when its category is deleted.
- Tests: use cases, cubit, repository, edge cases per spec.

---

## P1 — Next Up

### Recurring transactions

> **Spec**: TBD · **Effort**: M

First-class recurring transactions (salary, gym, streaming) — distinct from
bills. Today only `bills` has recurrence; transfers and incomes that repeat
have to be entered manually each month.

**Why**: prerequisite for cash-flow forecasting and "subscription detection"
features below. Closes a UX gap that users hit on day one.

**Open questions**:

- Materialize forward or project virtually like bills?
- Recurrence options: monthly, weekly, yearly, custom?
- Edit "this and following" semantics (already solved for bills — reuse pattern).

### Auto-categorization (AI)

> **Spec**: TBD · **Effort**: S–M

When the user types a transaction description manually, suggest a category
based on (a) prior transactions with similar descriptions or (b) a Gemini
prompt. The chat already classifies — extend to manual entry.

**Why**: the AI infra is already paid for and wired (Vertex AI via Cloud
Functions). Killer feature for free with low marginal cost.

**Open questions**:

- Local heuristic first (frequency map of `description → categoryId`) or
  always call the model?
- Confidence threshold to auto-fill vs. just suggest?

### Installments (parcelamento)

> **Spec**: TBD · **Effort**: M

Buying R$ 1.200 in 12× creates 12 linked future transactions, each displayed
on its respective month and counted toward future credit-card invoices.

**Why**: Brazilian credit cards default to installments. Without this, credit
card balance projections are wrong.

**Open questions**:

- Same model as transfers (`linkedTransactionId`) or a new `installmentGroupId`?
- Edit / cancel semantics (cancelling an installment chain mid-way).

### Dashboard year-over-year

> **Spec**: extension to [dashboard.md](dashboard.md) · **Effort**: S

Compare current month vs. same month last year, per category. Already have
all the data — purely a presentation feature.

**Why**: low effort, high perceived value, unlocks the "am I spending more
this year?" question that the current dashboard cannot answer.

---

## P2 — Backlog

### Spending insights & anomaly detection

Detect "you spent 3× the usual on delivery this week" via simple rolling
averages. Push notification or weekly digest. **Effort**: S.

### Subscription detection

Find recurring same-amount charges from the same description / counterparty
and surface a "Your subscriptions: R$ X/month" widget. **Effort**: S.

### Cash-flow forecast

Project balance 30/60/90 days out using bills + recurring transactions.
Depends on recurring transactions (P1). **Effort**: S after P1.

### Tags

Free-form tags on transactions (`#viagem-bahia`, `#trabalho`) that cross
categories. Cheap to add at the entity level; the value is in the
filter/report UI. **Effort**: M.

### Receipt attachments

Persist photos of receipts on the transaction (the chat already extracts
data from photos — we drop the image after parsing). Firebase Storage
required. **Effort**: M.

### Expense splits

Split a transaction across people (cônjuge, amigos), track who owes whom.
**Effort**: M.

### PDF report export

Monthly summary PDF for archival / printing. Reuses dashboard summary +
period transactions. **Effort**: S.

### Offline write queue

Today, remote failures block writes. Queue them locally and replay on
reconnect. **Effort**: L (conflict resolution, idempotency, UI for pending
state).

### Quick-add home screen widget

Native widgets (Android + iOS) to add a transaction without opening the app.
**Effort**: M (per platform).

### Custom recurrence for bills

Beyond `oneShot | monthly`: weekly, yearly, semi-monthly, every-N-weeks.
**Effort**: S after the recurrence engine in P1 lands.

---

## P3 — Aspirational / External Dependencies

### Open Finance integration (Pluggy / Belvo)

Sync extratos automatically from Brazilian banks via Open Finance. The single
biggest UX upgrade — eliminates CSV import. **Blocker**: requires CNPJ and
recurring API costs; only viable if the app is commercialized.

### Boleto OCR

Camera reads boleto barcode → creates a bill prefilled with amount, due date,
beneficiary. The image pipeline already exists in the chat; the missing piece
is a barcode reader. **Effort**: S–M, **Blocker**: none, just hasn't been
prioritized.

### Pix recurring categorization

Auto-categorize Pix transactions by destination key — "Pix para padaria João"
always becomes `Alimentação`. Depends on a richer transaction model (pix key
field) and Open Finance feeds.

### IRPF tax report export

Export annual income + deductible expenses (saúde, educação) in DIRPF-ready
format. **Effort**: M, **Blocker**: needs validation against actual DIRPF
import format.

### MEI / freelancer mode

Separate PJ vs PF transactions, estimate DAS, auto-reserve % to a tax
account. **Effort**: L.

### Multi-user / shared wallets

Casal compartilha contas/categorias específicas, mantém pessoais separadas.
Firestore rules already scope by `userId`; extending to `sharedWith[]` is the
right model. **Effort**: L (security rules, conflict resolution, UX for
"whose transaction is this?").

### Telegram channel

A 3rd chat channel alongside in-app and WhatsApp, reusing the same
`chatSend` Cloud Function. The architecture supports it; just hasn't been
built. **Effort**: S.

### Theme customization

User picks primary color, applied across the app. Existing `AppColors` is
already structured for this. **Effort**: S.

---

## Out of Scope (for now)

These came up during brainstorming but are explicitly **not** on the roadmap:

- **Multi-currency** — single-user, Brazilian context, BRL only.
- **Investment tracking** — out of scope for a personal-finance manager;
  there are dedicated tools.
- **Bank-grade security audits** — single-user app, no shared data, MFA
  through Google Sign-In is enough.
- **Web SaaS / commercial offering** — the app is built for personal use.
  P3 items would need to land before this conversation makes sense.
