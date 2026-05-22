# Financo — General Code Review (2026-05-22)

Full-codebase review against `CLAUDE.md` conventions. Scope: documentation accuracy,
test coverage, code cleanliness, duplication, architecture. 366 non-generated Dart
files in `lib/`, 94 test files, 14 specs in `docs/specs/`.

**Overall health: good.** Domain and data layers are clean and well-tested at the
core. The debt clusters in four places: (1) documentation drift in `CLAUDE.md` and a
few specs, (2) under-tested newer features (investments, bills use cases,
access_control, master_panel), (3) copy-paste in the CSV import + import-page +
repository layers, and (4) business logic that leaked into a handful of widgets.

Severity legend: **HIGH** = wrong/misleading or rule violation · **MEDIUM** =
stale/incomplete · **LOW** = nit. Items marked ✅ were verified directly during review.

---

## 1. Documentation drift

### HIGH
- ✅ **`CLAUDE.md:69` — `firebase_ai` does not exist.** The tech table claims AI Chat
  uses "Firebase AI Logic (`firebase_ai`, Vertex AI backend)". There is no `firebase_ai`
  package in `pubspec.yaml` and zero imports. Chat actually runs server-side via Cloud
  Functions callables (`chatSend`, `transcribeChatAudio`). Fix: change to "Firebase
  Cloud Functions (`cloud_functions`) → Vertex AI Gemini server-side".
- ✅ **`CLAUDE.md` — `cloud_functions` missing from Key Technologies.** `cloud_functions: ^6.0.0`
  (`pubspec.yaml:30`) powers all AI chat + the `deleteUserAsAdmin` admin flow. Add a row.
- **`CLAUDE.md:201` — `ChatBloc` mislabeled.** Listed as session-scoped/shell-created;
  it's actually page-scoped (`chat_page.dart:43` `BlocProvider`, not in the shell
  `MultiBlocProvider`). Move to the page-scoped bullet.
- **`CLAUDE.md:199-203` — lifecycle list omits 3 session-scoped cubits** the shell mounts:
  `FiftyThirtyTwentyTargetsCubit`, `DashboardAccountSelectionCubit`, `InvestmentsCubit`
  (`app_router.dart:152-250`). Add them.
- **`CLAUDE.md:244` — `accounts` field wrong.** Documented `initialBalance`; Firestore
  field is `balance` (`account_model.dart:72` `toJson`, `:41` `fromMap`). `initialBalance`
  is the Dart-side name only. `accounts.md` documents the mapping correctly — CLAUDE.md
  contradicts both.
- **`docs/specs/master_panel.md` broadly stale** vs implemented code:
  - Repo methods: spec `listAll()`/`deleteUser(userId)` → actual `listAllUsers()`/`deleteUserAsAdmin(targetUid)`.
  - `AllowedEmail.addedBy` field (spec) doesn't exist on entity/model.
  - `MasterPanelState` spec shows one class w/ `isLoading`; actual is sealed
    `Initial/Loading/Loaded/Error` + `busy` flag.
  - Cubit `loadAll()` → actual `load()`.
- **`docs/specs/startup.md:94` wrong DI.** Says `registerFactory<StartupCubit>`; actual
  is `registerLazySingleton` (`injection_container.dart:541`). CLAUDE.md is correct here.

### MEDIUM
- ✅ **Spec path is `docs/specs/`, not `specs/`.** `CLAUDE.md:105` (Spec-Driven workflow)
  and intra-spec links (`categories.md:61`, `investments.md:74`, `fifty_thirty_twenty.md`)
  all say `specs/<feature>.md`; the directory is `docs/specs/`. Fix path everywhere.
- **`CLAUDE.md:239-249` — Firestore Collections omits 3 live collections:** `budgets`,
  `asset_classes`, `asset_holdings` (datasources + `firestore.rules:93/102/111`). Document them:
  - `budgets/{id}` → userId, categoryId, amount, createdAt, updatedAt
  - `asset_classes/{id}` → userId, name, icon, color, targetPercent, parentId?, createdAt
  - `asset_holdings/{id}` → userId, accountId, assetClassId, amount, notes?, updatedAt
- **`CLAUDE.md:218-228` — Firestore Rules block lists 7 paths; actual `firestore.rules`
  covers 12.** Add the three above.
- **`CLAUDE.md:242` — `users` doc missing `fiftyThirtyTwentyTargets`** (`user_model.dart:44-50`).
- **`CLAUDE.md:245` — `categories` doc missing `bucket` and `countsIn50_30_20`**
  (`category_model.dart:81,84`) — core 50/30/20 fields.
- **`CLAUDE.md:247` — `bills` doc missing `rejectedTransactionIds`** (`bill_model.dart:98`).
- **`docs/specs/auth.md:167` & `profile.md`** — duplicate/overlapping Profile coverage;
  auth.md carries a stale Profile section that omits `fiftyThirtyTwentyTargets`. De-dupe.
- **`docs/specs/investments.md:543-552` — index claims contradict code.** Spec lists
  composite indexes that `firestore.indexes.json` does NOT define; the datasource
  deliberately avoids them (`asset_class_remote_datasource.dart:25-28`). Correct to
  "single-field userId queries, no composite index".
- **`docs/specs/fifty_thirty_twenty.md` internally inconsistent.** Header + Rule 5 still
  say custom targets are a "V1 non-goal", while §12 specs them as shipped (and they are
  implemented). Reconcile.
- **`docs/specs/budgets.md:23,326` (+ `profile.md:13`, `bills.md:5`) — stale navigation.**
  Predate the Planning shell: Budgets is now Tab 2 of `PlanningPage`, top-level nav renamed
  "Planejamento". Update.

### LOW
- `docs/specs/chat.md:152-156` — `ChatActionConfirmed` routing list omits `bill`/`budget`/`transfer`
  (handlers exist in DI `:451-476`).
- `docs/specs/categories.md:268` — `toJson` sub-section omits `bucket`/`countsIn50_30_20`
  (entity table at top has them).
- `docs/specs/master_panel.md` — `isMaster` flag phrasing is self-contradictory; there is
  no `isMaster` field, mastership derives from `kMasterEmail`. Scrub.
- `docs/specs/accounts.md:264` — references removed `isActive` field as "will be removed"
  (already gone).

Non-issue: every `lib/features/*` dir has a matching spec. Core deps (`flutter_bloc`,
`get_it`, `go_router`, `drift`, `dartz`, `very_good_analysis`, `slang`, `intl`) all verified
present.

---

## 2. Test coverage gaps

Rule (CLAUDE.md): "Every use case must have tests"; "one test file per source file". No
orphan tests found (every test resolves to a live source).

| Category | Untested | Total | Priority |
|---|---|---|---|
| Use cases | **26** | 62 | HIGH |
| Cubits | **4** | 19 | HIGH |
| Blocs | 0 | 5 | — |
| Repository impls | **2** | 13 | HIGH |
| Models | **3** | 10 | MEDIUM |
| Datasources | **10** | 12 | MEDIUM |
| Domain services | 0 | 3 | — |
| Chat action handlers | **5** | 7 | MEDIUM |
| Utils w/ logic | **4** | ~9 | LOW |

**Hotspots:**
- **bills** — 10 of 16 use cases untested: `get/create/update/delete_bill`, `pay_bill`,
  `link_bill_to_transaction`, `reject_bill_match`, `update_bill_scoped`, `import_bills_csv`.
- **investments** — least covered overall: 6 use cases (`get_asset_classes/holdings`,
  `delete_asset_holding`, `get_investment_overview`, `update_asset_class/holding`),
  2 cubits (`asset_holding_form`, `asset_class_form`), 2 repos, 2 models, 2 datasources.
- **access_control** — all 4 use cases untested (`is_email_allowed`, `list/add/remove_allowed_email`).
- **master_panel** — both use cases untested (`list_all_users`, `delete_user_as_admin`).
- **budgets** — `get_budgets`, `update_budget`, `import_budgets_csv` untested.
- **dashboard cubits** — `fifty_thirty_twenty_targets_cubit`, `fifty_thirty_twenty_detail_cubit`.
- **chat action handlers** — ~790 lines of untested business logic: `category` (108),
  `transfer` (132), `bill` (256), `budget` (220), `account_resolver` (75, fuzzy-match logic).
- **utils** — `validators.dart`, `date_helpers.dart`, `string_normalize.dart`,
  `category_query_filter.dart` have real logic, no tests.

**Hygiene:** `access_control` + `master_panel` repo tests sit at
`test/features/<f>/data/*_test.dart` instead of `…/data/repositories/` — breaks the
mirror-lib rule.

---

## 3. Duplication

- ✅ **D1 — CSV parsing helpers copy-pasted across the 5 import use cases (~250 lines).**
  `_normalize` (byte-identical in transactions/bills/budgets — a shared
  `core/utils/string_normalize.dart#normalizeForMatch` already exists and only accounts
  uses it), `_parseAmount` (×4), `_parseDate` (×2), `_readCell` (×4), `_mapHeaderColumns`
  (×5), `_buildCategoryLookup`/`_resolveCategoryId` (×2). Fix: `core/utils/csv_parsing.dart`
  with `parseCsvAmount`, `parseDmyDate`, `readCsvCell`, `resolveHeaderColumns`, a category
  lookup helper; delete the three `_normalize` copies. **Biggest win.**
- **D2 — Repository CRUD caching dance repeated across ~13 repos (~150 lines).** Same
  `try { model→remote→dao.upsert→Right } on ServerException { Left(ServerFailure) }`
  skeleton, plus the `getX` forceRefresh→insert→read-local pattern. Fix: a
  `guardServer(() async {...})` helper + write-through helper, or a `CachedCrudRepository`
  base. (Leave `bill_repository_impl.payBill` propagation — genuinely unique.)
- **D3 — The 3 import preview pages share copy-pasted widgets (~300 lines).**
  `_ImportProgressOverlay`, `_RemoveButton`, `_EmptyTab`, `_PickerRow`, `_Indexed`,
  `_MissingBanner` re-declared in `import_transactions_page`, `import_accounts_page`,
  `import_categories_page`. Fix: extract to `app/widgets/import/`.
- ✅ **D4 — `_AppBarIconButton` duplicated in 7 files (~180 lines), 4 byte-identical.**
  `add_category_page:878`, `add_bill_page:437`, `add_account_page:514`,
  `add_transaction_page:630`, `categories_page`, `accounts_page`, `bills_page:688`
  (renamed `_BillsAppBarIconButton`). Fix: one `FinancoAppBarIconButton` in `app/widgets/`.
- **D5 — "Labeled tappable row" primitive reimplemented ~12×** (`_PickerRow`, `_RowSelector`,
  `_CategoryRowField`, `_ParentRow`, `_AccountRow`×3, `_CategoryRow`×6). The 6 `_CategoryRow`
  picker copies are the tightest sub-cluster. Fix: shared `FinancoSelectRow` + `FinancoCategoryListRow`.
- **D6 — Two amount parsers:** `core/utils/amount_parser.dart#parseDecimalAmount` (UI) vs
  the use-case `_parseAmount` (D1). Same job — fold into one.

Items D1–D4 remove ~1,500 lines with no behavior change.

---

## 4. Dead code & oversized files

### Dead code — ✅ all confirmed unreferenced (8 files, ~705 lines), safe to delete
- Widgets in `lib/app/widgets/`: `balance_card.dart` (`BalanceCard`), `category_chip.dart`,
  `empty_state.dart` (features use their own `*_empty_state.dart`), `financo_app_bar.dart`,
  `financo_button.dart`, `financo_card.dart`.
- Pages: `accounts/.../account_detail_page.dart` (`AccountDetailPage`, 229 lines — the
  `accountDetail` route renders `AccountStatementPage` instead) and
  `transactions/.../transactions_page.dart` (`TransactionsPage`, 228 — not in the router).

> Note: `account_detail_page.dart` was edited in the prior dialog refactor (and shows as
> modified in git). Harmless since it's dead, but it's wasted churn — delete the file
> rather than keep the migrated dialog.

No meaningful commented-out code blocks found (clean on that axis).

### Oversized files (>600 lines; guideline is <400-600)
10 files exceed the limit. Worst, with concrete split boundaries:
1. `import_transactions_page.dart` (1130) → extract `_EditRowSheet`+`_PickerRow` (~475) to
   `import_transaction_edit_sheet.dart`; shared widgets to D3 → ~400.
2. `import_accounts_page.dart` (1098) → extract `_EditItemSheet`+`_LinkedAccountPicker` (~497).
3. `chat_input.dart` (950) → `_ChatInputState` is ~353 lines; extract a `ChatRecordingController`
   + `chat_image_attachment.dart` (mime/encode, 138-293).
4. `add_category_page.dart` (910) → extract bucket-picker cluster (691-814) + `_PreviewTile`.
5. `import_categories_page.dart` (784) → extract `_EditItemSheet`; shared widgets to D3.
6. `import_transactions_csv_usecase.dart` (777) → move row/preview/result entities (14-119)
   to `transaction_import_models.dart`; helpers to D1.
7. `bills_page.dart` (720) → extract `_BillsContent`/`_BillGroups` to `bills_list_view.dart`.
8. `chat_action_card.dart` (670) → already well-factored; lowest priority.
9. `asset_class_detail_page.dart` (663) → extract `_HeroCard` + `_SubclassCard`.
10. `add_transaction_page.dart` (662) → extract rows to D5; appbar button to D4.

Just over the line (touch when editing): `investments_page.dart` (587),
`category_details_dialog.dart` (582), `app_router.dart` (568), `injection_container.dart`
(561), `add_account_page.dart` (546), `financo_sidebar.dart` (534),
`fifty_thirty_twenty_card.dart` (530).

---

## 5. i18n & formatting

Overall disciplined: no `Text('literal')` in mainline UI, parity is clean (746 keys both
locales, zero placeholder mismatch). Violations:

### HIGH
- **`chat_action_card.dart:451,504,544` — 3 visible English literals** with keys already
  available: `'Credit card'/'Checking'` (→ `accounts.creditCard`/`checkingShort`),
  `'Income'/'Expense'` (→ `transactions.income`/`expense`), `'Monthly'/'One-time'`
  (→ `bills.monthly`/`oneShot`).
- **`category_form_cubit.dart:122-135` — Portuguese `ValidationFailure` strings** surfaced
  via SnackBar (`add_category_page.dart:323`). Hardcoded PT breaks EN locale.
- **`category_details_dialog.dart:387` — `?? 'Sem categoria'`** hardcoded PT fallback.
- **`core/errors/failures.dart:8-28` — every Failure has a hardcoded English default**
  shown untranslated via `ErrorView` at 11 sites. Systemic: error states are English in
  any locale. Fix: map Failure *type* → `t.*` at the UI boundary, drop copy from Failure.

### MEDIUM
- Investments use-case `ValidationFailure`s hardcoded EN + raw money:
  `create_asset_holding_usecase.dart:96-97` / `update_asset_holding_usecase.dart:85-86`
  use `toStringAsFixed(2)` for a currency value (→ `formatCurrency`), key
  `investments.amountOverflow` exists. Same for `create_asset_class_usecase.dart:97-102`.

### LOW
- **51 unused i18n keys** in both JSONs (e.g. `accounts.deleted/saved`, `bills.payDialogTitle`,
  `dashboard.recentTransactions/seeAll/thisMonth`, `transactions.importReview`,
  `general.yes/or`, …). Prune. (Full list available; harmless but noise.)

Money display is otherwise consistently routed through `formatCurrency()` / `AmountText` —
no `Text('R$ $x')` found.

---

## 6. Architecture & conventions

Data/domain layers are clean: **all 14 repo interfaces return `Future<Either<Failure,T>>`**,
no `throw` in impls, every datasource sits behind an abstract interface, every entity is
`Equatable`, every model extends its entity, all state classes are immutable. No `print`,
no TODO/FIXME in `lib`. The real issues are logic-in-UI:

### HIGH — business logic in widgets
- **`add_category_page.dart:173-277`** — `_confirmDelete`/`_deleteBudgetsForCategory`
  orchestrate a cross-feature "delete category + reassign transactions + cascade-delete
  budgets" workflow inside a `State` class, with partial-failure handling in UI **and** a
  direct `GetIt.I<TransactionRepository>()` call (`:26,176,231`) — the only repository
  reached from presentation anywhere. Fix: `DeleteCategoryWithReassignmentUseCase` in domain;
  page calls it via the cubit.
- **`bills_page.dart:354-588`** — carry-over month filtering, settleability window, type/
  candidate filtering, and overdue/today/upcoming/paid grouping all live in widgets (the
  code even cites `specs/bills.md` rules). Fix: move to a domain service or a `BillsView`
  projection on `BillsBloc` state (mirror how dashboard uses `compute50_30_20`).
- **`category_details_dialog.dart:102-194,377-408`** — filters/aggregates/percentages inside
  `build()`. Fix: a `computeCategoryDrillDown(parent, txns, categories)` domain service.

### MEDIUM
- **Cross-feature presentation coupling for a shared enum:** `asset_class_form_page.dart:22`
  and `asset_holding_sheet.dart:21` import `transaction_form_cubit.dart` only to reuse
  `enum FormStatus`. Meanwhile budgets/bills each defined their own `*FormStatus`. Hoist one
  shared `FormStatus` into `app/` or `core/`.
- **`import_categories_page.dart:45-124,382-430`** — category-tree ordering + hierarchy-
  integrity mutation rules in a widget. Move to the cubit/domain.
- **`dashboard_page.dart:182-191,370-372`** — bank/credit partition + sort + total in
  `build()`. Have `DashboardSummary`/bloc expose pre-split groups.

### LOW
- Domain imports Flutter: `category_icon_option.dart:1`, `category_icon_catalog.dart:8`
  pull `IconData` into domain. Pragmatic, but `core/utils/dynamic_icon.dart#materialIconFor`
  already exists — store `int codePoint` in domain, build `IconData` in presentation.
- `account_statement_cubit.dart:116` — `tx.linkedTransactionId!` force-unwrap relies on an
  unguarded `isTransfer ⟹ linkedTransactionId != null` invariant. Add a guard/assert.
- Read-only projection entities lack `copyWith` (`CategoryAmount`, `DashboardSummary`,
  `BillMatchCandidate`, `InvestmentOverview`, `BudgetOverview`) — fine for read models,
  noted only against the blanket "entities provide copyWith" rule.
- The one hand-written `// ignore` (`dynamic_icon.dart:18`) is justified by a nearby comment.

---

## Recommended action plan (ROI order)

**Quick wins (low risk, high signal):**
1. Delete 8 dead files (~705 lines). Zero behavior change — also removes the 8th
   `_AppBarIconButton` copy. *(Do this before any dedup so you don't refactor dead code.)*
2. Fix the 3 `chat_action_card` English literals + `'Sem categoria'` fallback (keys exist).
3. Correct `CLAUDE.md`: `firebase_ai`→`cloud_functions`, spec path `docs/specs/`, add
   budgets/asset_classes/asset_holdings collections+rules, fix the lifecycle list,
   `balance` field, missing entity fields.

**Medium (mechanical refactors):**
4. D1 — shared `core/utils/csv_parsing.dart` (and adopt the existing `normalizeForMatch`).
5. D3 + D4 — shared import widgets + `FinancoAppBarIconButton`.
6. Split the two 1000+ line import pages (extract edit sheets).
7. Refresh stale specs: master_panel, startup, investments indexes, fifty_thirty_twenty
   V1 framing, navigation (budgets/profile/bills).

**Larger (design changes):**
8. Move logic out of UI: `add_category` delete-orchestration + repo leak → use case;
   `bills_page` filtering/grouping → domain; `category_details_dialog` aggregation → service.
9. Translate the Failure layer (type→`t.*` at the `ErrorView` boundary).
10. D2 — repository CRUD base/helper.
11. Backfill tests for the hotspots: bills use cases, investments (use cases/cubits/repos),
    access_control + master_panel use cases, chat action handlers.

No code was changed during this review — findings only.
