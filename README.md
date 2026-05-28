# Financo

Personal finance manager for Android and Web. Natural-language data entry powered by an AI assistant inside the app.

## What it does

- **Dashboard** — month/year filter, income vs. expenses summary, category breakdown, monthly evolution chart.
- **Accounts** — checking and credit card; credit cards link to a paying checking account (closing/due day, available credit).
- **Categories** — income and expense, with optional parent (sub-category) hierarchy and Material icons.
- **Transactions** — single-account or **transfers** (linked expense/income across two own accounts), with running balance per account.
- **Bills** — payable or receivable, one-shot or monthly recurring; "Mark as paid" generates the corresponding transaction automatically.
- **AI chat** — Vertex AI Gemini accessed through Cloud Functions. The model proposes structured actions (transactions, transfers, accounts, categories, bills) that the user confirms via an action card. Supports text, image (receipts/notification screenshots/invoices), and voice (audio transcription).
- **CSV import** — bulk-create accounts, categories, transactions, bills, and budgets from CSV files (samples shipped in `lib/app/assets/samples/`).
- **Notifications** — Firebase Cloud Messaging foreground rendering, plus a scheduled Cloud Function that pings users about overdue / due-today bills.

## Architecture

[Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) with feature-first organization:

```
lib/
├── app/          # App shell — DI, routing, theme, shared widgets
├── core/         # Database, errors, extensions, utils, notifications
├── features/     # Feature modules (each: data / domain / presentation)
└── gen/          # Generated code (slang i18n)

functions/
└── src/
    ├── chat/     # Gemini pipeline, action extractor
    └── bills/    # Scheduled bill-due notifier

docs/specs/       # Per-feature contracts (entities, business rules, state machines)
test/
└── harness/      # Centralized mocks, factories, helpers
```

Each `features/<x>/` module follows:

- `domain/` — entities, repository interfaces, use cases
- `data/` — models, datasources, repository implementations
- `presentation/` — cubits/blocs, pages, widgets

## Tech stack

| Concern | Tool |
|---|---|
| State management | `flutter_bloc` (Cubits for simple state, Blocs for event-driven flows) |
| DI | `get_it` |
| Routing | `go_router` (declarative shell route) |
| Local cache | `drift` (SQLite) |
| Remote sync | Firebase Firestore |
| Auth | Firebase Auth + `google_sign_in` |
| Push | Firebase Cloud Messaging + `flutter_local_notifications` |
| AI | Vertex AI Gemini, accessed via Firebase Cloud Functions |
| Error model | `dartz` `Either<Failure, T>` |
| i18n | `slang` (type-safe, generated) |
| UI charts | `fl_chart` |
| Lints | `very_good_analysis` (strict) |
| Testing | `flutter_test`, `bloc_test`, `mocktail`, `fake_cloud_firestore` |

Backend (`functions/`):

- **Node.js 22**, TypeScript, `firebase-functions` v7
- Vertex AI Gemini via `@google-cloud/vertexai`

## Spec-driven development

Each feature has a contract at `docs/specs/<feature>.md` covering entities, business rules, repository interfaces, state machines, and edge cases. Tests are written against the spec; code follows. See `CLAUDE.md` for the full project conventions.

## Running locally

Prerequisites: Flutter SDK ≥ 3.11, Dart ≥ 3.11, Node.js ≥ 22 (only for the backend), Firebase CLI (for the backend).

```bash
# 1. Install Dart deps and generate code
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run slang

# 2. Configure Firebase (one-time, generates lib/firebase_options.dart and platform configs)
flutterfire configure

# 3. Run the app
flutter run
```

For web builds you also need the Drift web assets:

```bash
curl -L -o web/sqlite3.wasm \
  https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.1/sqlite3.wasm
curl -L -o web/drift_worker.dart.js \
  https://github.com/simolus3/drift/releases/download/drift-2.32.1/drift_worker.js
```

## Backend (Cloud Functions)

```bash
cd functions
npm install
npm run lint
npm test
npm run build

# Deploy (requires Firebase CLI auth + project selected)
firebase deploy --only functions
```

The callables `chatSend`, `transcribeChatAudio`, and `deleteUserAsAdmin` are defined in `functions/src/index.ts`; the scheduled bill notifier `notifyBillsDue` lives in `functions/src/bills/notifyBillsDue.ts` and is re-exported from `index.ts`.

## Testing

```bash
flutter analyze                                # Must be zero issues
flutter test                                    # All tests must pass
flutter test test/features/categories/          # Single feature
cd functions && npm test                        # Backend unit tests
```

Tests follow F.I.R.S.T principles. Mocks live in `test/harness/mocks.dart`; factories in `test/harness/factories/`. Mock at boundaries: repositories for cubits/blocs, datasources for repositories.

## Post-change checklist

After every code change:

1. `dart run slang` — if any i18n JSON changed
2. `dart run build_runner build` — if Drift tables/DAOs changed
3. `flutter analyze` — zero errors, warnings, info-level issues
4. `flutter test` — all tests pass
5. (Backend) `npm run lint && npm test && npm run build` from `functions/`

## Deploy

GitHub Actions automates the client release on every push to `main` ([`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)):

- Builds the Web release with the Drift web assets bundled
- Builds and signs the Android APK (uses `ANDROID_KEYSTORE_*` secrets)
- Bundles the APK alongside the web build at `/financo.apk`
- Publishes the result to GitHub Pages

Cloud Functions deploys are manual: `firebase deploy --only functions` from the repo root, or `firebase deploy --only functions:<name>` for a single function.
