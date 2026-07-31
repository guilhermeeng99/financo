# TODO — Deferred Items

Tracked follow-ups that are intentionally not being done right now, with the
reason each one is parked. Last reviewed: 2026-07-31.

## Backend / dependencies

- [ ] **Migrate `functions/src` to firebase-admin 14 modular API.** Clears the
      9 moderate `uuid` advisories; v14 removes the legacy namespace API the
      code currently uses, so this is a code migration, not just a bump.
- [ ] **Migrate `@google-cloud/vertexai` → `@google/genai`.** The Vertex
      generative SDK is frozen after 2026-06-24; the pinned 1.12.0 keeps
      working in the meantime.
- [ ] **eslint 8 → 10 (flat config).** Blocked: `eslint-config-google` has no
      flat-config release. `typescript-eslint` is already on 8.
- [ ] **`uuid` pinned to 11.x** while functions emit CJS — 12+ is ESM-only.

## Flutter dependencies

- [ ] **record 6 → 7.** Blocked: needs AGP 9; the project is on AGP 8.11.1.
- [ ] **package_info_plus 9 → 10.** Blocked: requires `win32 ^6` which
      conflicts with `file_picker ≤ 11`; revisit when file_picker 12 is
      stable.

## Code quality

- [ ] **Finish migrating datasources onto `FirestoreCrudDataSource`.** The
      base class now exists (`lib/core/database/firestore_crud_data_source.dart`,
      2026-07-31) after the "revisit if an 8th appears" trigger fired at 13.
      `institution_remote_datasource` and `asset_remote_datasource` are
      migrated and covered by tests. The remaining CRUD-shaped ones
      (`access_control`, `accounts`, `auth`, `budgets`, `categories`,
      `asset_transaction`, `snapshot`, `investments`, `master_panel`,
      `profile`, `transactions`) still hand-roll the try/catch. Move them one
      at a time — each is a small, independently verifiable change, and a few
      have extra query methods that stay in the subclass.

- [ ] **Investing import pages on `ImportPreviewScaffold`.** Considered and
      declined 2026-07-31: `import_investing_assets_page` and
      `import_investing_transactions_page` build their own `Scaffold` while
      accounts/categories/transactions use the shared one. Making them fit
      would mean loosening the scaffold's contract (`typeToggle` optional,
      inline progress instead of an overlay) for two outliers whose shape
      genuinely differs — that usually makes the shared widget worse, not
      better. Revisit if a third import page wants the same shape.

## Testing gaps needing small lib changes

- [ ] **Drift DAO tests** — `AppDatabase` only has a no-arg constructor wired
      to `driftDatabase()`; add an `AppDatabase.forTesting(QueryExecutor)`
      constructor to enable in-memory DAO tests (transactions_dao first).
- [ ] **`notification_background_handler`** — FCM background routing is not
      unit-testable as-is; extract the routing logic behind a testable seam.

## Product / UX

- [ ] **Decide the payables settlement confirmation sheet.** A sheet
      (settlement date + account adjustment) was spec'd earlier but never
      implemented; the current UX is one-tap settle with today's date
      (re-spec'd 2026-06-12 in `docs/specs/payables_receivables_refactor.md`).
      Either implement the sheet or commit to one-tap permanently.
- [ ] **50/30/20 "add institution" CTA does not refresh on return.**
      `fifty_thirty_twenty_card.dart` (`_adviceFor`, the
      `AppRoutes.addInstitution` branch — ~line 420) pushes the route without
      awaiting it, so a freshly created institution can leave the card showing
      the "cadastre a corretora" tip until the next dashboard reload. Minor
      staleness. *(The old note pointed at line 418 and at the add-**account**
      route; both were stale — the CTA now targets
      `/investing/institution/add`.)*

## From the 2026-07-31 audit

- [ ] **Chat and the investing CSV importer never set `fundingAccountId`.**
      `SyncInvestmentCashFlowUseCase` gives any writer the paired cash row for
      free, but only `InvestingTransactionFormPage` supplies the funding
      account. Consequences: (a) `ImportInvestingTransactionsCsvUseCase` imports
      every buy as "cash already at the broker", so imported purchases never
      reach the 50/30/20 savings bucket — needs a `funding`/`conta` column and a
      name→account resolution step; (b) `lib/features/chat/` has **no**
      investing action at all, which matches `investing.md` §9 (out of scope for
      V2) — the claim in `investing_account_unification.md` F8.4 that
      "Chat/CSV updated" was simply wrong and has been corrected. Decide whether
      the CSV column is worth it; leave chat alone until V2 lands.
- [ ] **F8 decision O1 ("cash parked at a broker") is unimplemented.**
      `RecordInstitutionCashFlowUseCase` was deleted in this audit for having
      zero callers. The workaround (create a `cash` asset, record a funded
      `buy` against it) works today. Reinstating it means a find-or-create for
      the per-currency `cash` asset delegating to `SaveAssetTransactionUseCase`
      — **plus a real entry point in the same change**, or it is dead again.
      See `docs/specs/investing_account_unification.md` §2 O1.
- [ ] **Stale dartdoc on `AssetTransactionRepository.saveTransaction`.** It
      claims to enforce "the institution-match, non-positive-quantity, oversell
      and future-date rules before writing"; those all live in
      `SaveAssetTransactionUseCase`. One-line comment fix (docs corrected in
      `investing_transactions.md`).
- [ ] **Misattributed dartdoc in `transaction_form_cubit.dart`.** The doc
      comment describing `_resolveTransferCounterpart` sits above
      `_loadAccountCurrencies` (two comments ran together around lines 210–219),
      so the wrong method carries it. Comment-only fix.

## From deep review (2026-07-26)

- [ ] **F8.6 — remove `AccountType.investment`.** Investment accounts are
      retired in data (all migrated to institutions), but the enum value + ~15
      usages remain: `add_account_page` pill, `account_balance_calculator`,
      `account_card`, `accounts_page`, `dashboard_account_row`,
      `transaction_account_picker_sheet`, the two payables pages' filters,
      `compute_fifty_thirty_twenty._netSavingsFlow` (the legacy transfer leg —
      see `fifty_thirty_twenty.md` rule 9's caveat), and the migration
      planner/cubit. Real work, not a delete. **Blocked on retiring
      `lib/features/data_migration/`**, which is built entirely around the enum
      value — see `docs/specs/data_migration.md` §9.
- [ ] **Dashboard row scaffold + avatar helper.** `DashboardAccountRow` and
      `DashboardInstitutionRow` still share a near-identical `Material>InkWell>
      Padding>Row` scaffold, and `_InstitutionAvatar` re-implements
      `BankAvatar`'s luminance foreground pick. (Checkbox + pill were extracted
      to `dashboard_row_parts.dart`.) Extract a shared row scaffold + an
      `initials` mode on `BankAvatar` if a 3rd row type appears.
- [ ] **Merge `lib/features/investments/` into `investing/`.** Two near-homonym
      feature folders; allocation code is split across both. Rename hazard.
- [ ] **Decompose oversized build/parse methods.** `add_transaction_page.build`
      (~208 lines), `import_transactions_csv_usecase._parseCsv` (~155),
      `dashboard_page.build` (~171) exceed the 5-25 line rule.

## Done since the last review

- [x] **Standardize enum-from-string parsing.** ~~Four idioms across the
      codebase.~~ Shipped as `lib/core/utils/enum_parse.dart`
      (`enumByNameOrNull` / `enumByName`): 34 call sites in `lib/`, and zero
      remaining `.values.byName` — no read path can throw on an unknown stored
      value any more.
- [x] **Routine safe dependency bumps.** `flutter pub upgrade` (in-constraint
      minors/patches) landed in `b78bacc`.
