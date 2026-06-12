# TODO — Deferred Items

Tracked follow-ups that are intentionally not being done right now, with the
reason each one is parked. Last reviewed: 2026-06-12.

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

- [ ] **`FirestoreCrudDataSource` base class.** The 7 Firestore remote
      datasources still repeat the same CRUD + `ServerException` shape;
      deferred twice (2026-05-28, 2026-06-12) because the per-collection
      differences make the abstraction low-value vs churn. Revisit if an
      8th datasource appears.

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
- [ ] **`fifty_thirty_twenty_card.dart:418`** pushes the add-account route
      without refreshing on return — newly created accounts can render stale
      until the next dashboard reload (minor staleness).
