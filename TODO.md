# TODO — Deferred Items

Tracked follow-ups that are intentionally not being done right now, with the
reason each one is parked. Last reviewed: 2026-08-04.

## Backend / dependencies

- [ ] **7 moderate `uuid` advisories (GHSA-w5hq-g745-h8pq) survive
      transitively.** Path: `gaxios` / `teeny-request` → `@google-cloud/storage`
      → `firebase-admin` → `firebase-functions`. Our direct `uuid` is already
      11.1.1 (patched); the vulnerable copies are nested. **Do not run
      `npm audit fix --force`** — it "fixes" this by downgrading
      firebase-admin to 10.3.0. An `overrides` entry like the existing `rimraf`
      one is the shape to try; verify the nested consumers still resolve.
- [ ] **`uuid` pinned to 11.x** while functions emit CJS — 12+ is ESM-only.
- [ ] **typescript 6 → 7 in `functions/`.** `site/` is already on 7, so the two
      Node projects disagree. Major bump; check `tsc` output before adopting.

## Flutter dependencies

- [ ] **record 6 → 7.** Blocker is build-side: it needs AGP 9 and the project
      is on AGP 8.11.1 (`android/settings.gradle.kts`). Needs a real Android
      build to clear.
- [ ] **package_info_plus 9 → 10.** Still blocked (re-checked 2026-08-04):
      10.1+ needs `win32 ^6`, `file_picker` <12 stable pins `win32 ^5`.
      Careful: `flutter pub upgrade --major-versions --dry-run` *reports* both
      as resolvable — only because it would drag `file_picker` to a 12.x beta.
      A plain `pub get` with the bump fails.
- [ ] **sqlite3 3.5.0 → 3.5.1 is not a free patch.** The Drift web assets are
      pinned by tag in both `README.md` and `.github/workflows/deploy.yml`, and
      README states both must match the resolved `pubspec.lock` versions.
      Bumping the package without re-downloading the matching `sqlite3.wasm`
      ships a worker built against a different schema surface.

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

- [ ] **`notification_background_handler`** — FCM background routing is not
      unit-testable as-is; extract the routing logic behind a testable seam.

## Product / UX

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

- [x] **firebase-admin 14, `@google/genai`, eslint 10 flat config.** All three
      shipped in `9b90c6d`; the entries here claiming them as blocked were
      stale. Note firebase-admin 14 did **not** clear the `uuid` advisories as
      that entry predicted — see the open item above.
- [x] **Drift DAO tests.** `AppDatabase.forTesting(QueryExecutor)` exists and
      13 DAO test files live in `test/core/database/daos/`.
- [x] **Standardize enum-from-string parsing.** ~~Four idioms across the
      codebase.~~ Shipped as `lib/core/utils/enum_parse.dart`
      (`enumByNameOrNull` / `enumByName`): 34 call sites in `lib/`, and zero
      remaining `.values.byName` — no read path can throw on an unknown stored
      value any more.
- [x] **Routine safe dependency bumps.** `flutter pub upgrade` (in-constraint
      minors/patches) landed in `b78bacc`.
- [x] **F8.6 — removed `AccountType.investment`.** ~~Blocked on retiring
      `lib/features/data_migration/`.~~ Unblocked once the last account of that
      type left Firestore (a test user's, deleted from the master panel). Both
      went together: the enum value, its ~15 usages, and the whole guided
      migration feature + spec. The transfer-pairing leg of `_netSavingsFlow`
      went with it, so `compute50_30_20Overview` no longer takes `accounts`.
- [x] **Decided the payables settlement confirmation sheet.** ~~Either
      implement the sheet or commit to one-tap permanently.~~ Committed to
      one-tap: the sheet is dropped from the spec, and the same `SettleButton`
      now also sits on pending rows of the account statement. A retroactive
      settlement date is set by editing the row.
