# Financo — Project Conventions

Personal finance manager built with Flutter. Supports Android and Web.

---

## Architecture

**Clean Architecture** with feature-first organization:

```
lib/
├── app/          # App shell: DI, routing, theme, shared widgets
├── core/         # Shared: database, errors, extensions, utils
├── features/     # Feature modules (each with data/domain/presentation)
└── gen/          # Generated code (i18n)
```

Each feature follows:

* `domain/` — entities, repository interfaces, use cases
* `data/` — models, datasources, repository implementations
* `presentation/` — cubits/blocs, pages, widgets

---

## Code Style

* Functions: 5–25 lines. Split if longer.
* Files: ideally under 400–600 lines.
* One responsibility per function/module (SRP).
* Prefer small, composable widgets over large ones.

### Naming

* Names must be specific and intention-revealing.
* Avoid generic names like `data`, `manager`, `handler`.
* Prefer names that are searchable and unique within the codebase.

### Control Flow

* Prefer early returns over nested conditionals.
* Maximum 2 levels of indentation.

---

## Comments

* Write **WHY**, not WHAT.
* Preserve important context and decisions.
* Do not remove meaningful comments during refactors.
* Public APIs must include:

  * intent
  * parameters
  * usage example

---

## Key Technologies

| Aspect               | Detail                                                            |
| -------------------- | ----------------------------------------------------------------- |
| **State management** | flutter_bloc (Cubits for simple state, Blocs for event-driven)    |
| **DI**               | get_it (service locator in `lib/app/di/injection_container.dart`) |
| **Routing**          | go_router (declarative, path-based, shell route)                  |
| **Database**         | Drift (local SQLite cache) + Firebase Firestore (remote)          |
| **Auth**             | Firebase Auth + Google Sign-In                                    |
| **AI Chat**          | Firebase Cloud Functions (`cloud_functions`) → Vertex AI Gemini server-side (callables `chatSend`, `transcribeChatAudio`) |
| **Error handling**   | dartz Either<Failure, T> pattern (UI localises via `localizedFailure`) |
| **Linting**          | very_good_analysis (strict)                                       |
| **i18n**             | slang (generated in `lib/gen/`)                                   |
| **Theme**            | Light + Dark Material 3, custom AppColors / AppTheme              |
| **Currency**         | BRL (Real brasileiro) via `intl`                                  |

---

## Commands

```bash
flutter test                            # Run all tests
flutter test test/features/categories/  # Run feature tests
flutter analyze                         # Static analysis (must be zero issues)
flutter run                             # Run the app
dart run build_runner build             # Generate code (Drift)
dart run slang                          # Generate i18n
```

---

## Post-Change Checklist

After every code change:

1. Run `dart run slang` if any i18n JSON was modified
2. Run `dart run build_runner build` if Drift tables or DAOs changed
3. Run `flutter analyze` — **zero** errors, warnings, and info-level issues
4. Run `flutter test` — all tests must pass
5. Never add `// ignore` without clear justification

---

## Spec-Driven Development

Every feature MUST have a spec at `docs/specs/<feature>.md` before writing new code or tests.

### Workflow

1. Write or update the spec (business rules, contracts, state machines)
2. Write tests based on the spec
3. Implement or modify code to pass the tests
4. Update the spec if requirements change

### Spec Structure

* Entity contract (fields, types, invariants)
* Business rules (numbered, testable)
* Repository contract (methods, parameters, return types)
* State machines (cubit/bloc states and transitions)
* Edge cases

---

## Testing Rules

* Every new use case must have tests
* Every bug fix must include a regression test
* Tests must follow F.I.R.S.T principles:

  * Fast
  * Independent
  * Repeatable
  * Self-validating
  * Timely

### Test Structure

* One test file per source file (mirrors `lib/`)
* Use `bloc_test` for cubit/bloc testing
* Use factories for test data — never hardcode entities
* Mock at boundaries:

  * repositories for cubits
  * datasources for repositories

---

## Harness Engineering

Test infrastructure lives in `test/harness/`:

* `mocks.dart` — centralized mock declarations (mocktail)
* `helpers.dart` — shared test setup and utilities
* `factories/` — test data factories per entity

---

## Dependencies

* Depend on abstractions, not implementations
* Inject dependencies via constructor or DI
* External libraries must be wrapped behind project-owned interfaces

---

## Code Conventions

* Entities use `Equatable` and provide `copyWith`
* Failures are sealed classes (`ServerFailure`, `AuthFailure`, etc.)
* Use cases are single-method classes with `call()` operator
* Models extend entities and handle serialization
* All repository methods return `Future<Either<Failure, T>>`
* Use package imports (`package:financo/...`)
* Apply `const` constructors wherever possible

### Shared helpers — reach for these instead of re-rolling

| Helper | Where | Use it for |
| ------ | ----- | ---------- |
| `enumByNameOrNull(values, raw)` / `enumByName(values, raw, orElse)` | `lib/core/utils/enum_parse.dart` | Parsing an enum from a persisted `enum.name`. **Never `Values.byName`** at a Firestore/Drift boundary — it throws on an unknown value, turning one bad row into a crashed screen. The fallback stays visible at the call site. |
| `context.popOrGo(fallbackRoute, {result})` | `lib/core/extensions/context_navigation_extensions.dart` | Closing a pushed sub-page. Every sub-page is URL-reachable on web, so a deep-linked route has an empty stack and a bare `pop()` strands the user. |
| `kUserScopedCollections` | `lib/core/database/user_scoped_collections.dart` | The Dart-side list of top-level collections carrying a `userId`. **Cross-language duplicate**: `functions/src/admin/deleteUser.ts` (`PER_USER_COLLECTIONS`) must match, and both are pinned by tests derived from `firestore.rules`. Adding a user-scoped collection means editing both, plus the rules and the map below. |
| `formatCurrency(value, [currency])` / `formatMoney(Money)` | `lib/core/utils/currency_formatter.dart` | Cash-side `double` vs investing `Money`. Separate names — Dart has no overloading. |
| `parseDecimalAmount(text)` | `lib/core/utils/amount_parser.dart` | Reading a typed amount; accepts BR (`1.234,56`) and EN (`1,234.56`). |

### UI & Formatting

* Every user-facing string via slang (`t.section.key`) — never hardcode
* Monetary values formatted with `formatCurrency()` — never display raw doubles.
  Pass the owning account's `Currency` when it isn't BRL by construction (F9).

---

## State Management

* **Bloc** for complex event-driven logic (Auth, Dashboard, Transactions, Chat)
* **Cubit** for simpler state (Accounts, Categories, Profile, Startup)

### Rules

* UI must not contain business logic
* Cubits/Blocs orchestrate, UseCases execute logic
* State must be immutable

### Lifecycle

* Session-independent blocs/cubits are singletons (`registerLazySingleton`):
  `AuthBloc`, `StartupCubit`, `ThemeCubit`, `LightPaletteCubit`,
  `DarkPaletteCubit`, `AppLocaleCubit`, `DateFilterCubit`, `NotificationService`.
* Session-scoped blocs/cubits that take `userId` (`DashboardBloc`,
  `TransactionsBloc`, `BudgetsCubit`, `AccountsCubit`,
  `CategoriesCubit`, `ProfileCubit`, `InstitutionsCubit`, `AssetsCubit`,
  `InvestingOverviewCubit`, `InvestingTransactionsCubit`,
  `InvestingAllocationCubit`, `FiftyThirtyTwentyTargetsCubit`,
  `DashboardAccountSelectionCubit`) are created by the shell route via
  `BlocProvider` — the `userId` is resolved from `AuthBloc.state` at mount
  time and never changes during the shell's lifetime.
* Form cubits and page-scoped cubits are created per use (`BlocProvider`).
  `ChatBloc` is page-scoped: created per visit by `ChatPage`, not by the
  shell.

---

## Performance

* Avoid unnecessary rebuilds (use `const`, selectors, split widgets)
* Prefer granular widgets over large rebuild scopes
* Lists must use lazy builders (`ListView.builder`, etc.)
* Avoid heavy work on UI thread

---

## Firestore Rules

```
users/{userId}
users/{userId}/fcmTokens/{tokenId}
accounts/{id}
categories/{id}
transactions/{id}
bills/{id}  # legacy/read-only after 2026-06-10 migration
budgets/{id}
asset_classes/{id}
asset_holdings/{id}  # legacy/read-only after the F7 V2 investing migration
institutions/{id}
investment_assets/{id}
investment_transactions/{id}
investment_snapshots/{id}
chat_messages/{id}
allowed_emails/{email}
```

### Guidelines

* Always scope queries by `userId`
* Avoid unbounded queries
* Use indexes explicitly when needed
* Prefer batched writes for multi-document updates

---

## Firebase — Firestore Collections

```
users/{userId}                       → name, email, photoUrl, createdAt, fiftyThirtyTwentyTargets? { needs, wants, savings }
users/{userId}/fcmTokens/{tokenId}   → token, platform, updatedAt
accounts/{id}                        → userId, name, type, bank, balance (Dart: initialBalance), currency (default 'brl'), creditLimit?, closingDay?, dueDay?, linkedAccountId?, createdAt
categories/{id}                      → userId, name, icon, color, type (income | expense), parentId?, bucket? (needs | wants), countsIn50_30_20
transactions/{id}                    → userId, accountId, categoryId, type, amount, description, date, settlementStatus (pending | paid), dueDate, settledAt?, recurrence (single | installment | fixed), recurrenceGroupId?, recurrenceIntervalMonths?, recurrenceIndex?, recurrenceTotal?, recurrenceBaseDescription?, recurrenceEndDate?, notes?, linkedTransactionId?, institutionId? (investment aporte/resgate tag — F8), linkedInvestmentTransactionId? (buy/sell that generated this cash-flow row), createdAt, updatedAt
                                       ⚠ `sourceBillId` / `parentTransactionId` also exist on rows written by the 2026-06-10 bills migration (`scripts/migrate_bills_to_transactions.js`), but nothing in `lib/` reads or writes them — they are not on the entity, the model, or the Drift table. Don't add them to new code.
bills/{id}                           → legacy/read-only after the 2026-06-10 migration; retained for rollback/audit and account-wipe cleanup only. The app must not query or notify from this collection. Previous shape: userId, type (payable | receivable), description, amount, dueDate, status (pending | paid), recurrence (oneShot | monthly), categoryId?, notes?, paidAt?, paidTransactionId?, parentBillId?, rejectedTransactionIds, createdAt, updatedAt
budgets/{id}                         → userId, categoryId, amount, createdAt, updatedAt
asset_classes/{id}                   → userId, name, icon, color, targetPercent, parentId?, createdAt  (allocation buckets; assets link via investment_assets.metadata.allocationClassId)
asset_holdings/{id}                  → legacy/read-only after the F7 V2 investing migration; superseded by the investment_* collections. Previous shape: userId, accountId, assetClassId, amount, notes?, updatedAt
institutions/{id}                    → userId, name, kind, currency, bank? (BankType.name display hint), color? (ARGB int display hint), createdAt
investment_assets/{id}               → userId, ticker, name, kind (stockBr | fiiBr | etfBr | bdrBr | stockUs | etfUs | crypto | treasury | fixedIncome | fund | cash — see `AssetKind`; the form's Type picker only offers `AssetKind.selectableKinds` = etfUs, crypto, fixedIncome, cash, but every value still deserializes), market, currency, institutionId, metadata (Map: allocationClassId?, allocationTargetPercent?, fiBasis?, fiRate?, tesouroName?, coingeckoId?), createdAt
investment_transactions/{id}         → userId, institutionId, assetId, kind (buy | sell | dividend), quantity, unitPriceMinor, feesMinor, amountMinor, currency, date, notes?, fundingAccountId? (checking account funding the aporte/receiving the resgate — F8), cashAmountMinor? (BRL moved on the checking side; set only with fundingAccountId), createdAt, updatedAt
investment_snapshots/{id}            → doc id = "${userId}_${yyyy-MM-dd}"; userId, date, totalValueMinor, totalInvestedMinor, unrealizedPlMinor, currency
chat_messages/{id}                   → userId, role, content, metadata, createdAt
allowed_emails/{email}               → addedAt, note?  (doc id is the lower-cased email; gates onboarding — see access_control)
```

> **`AccountType` is `checking | creditCard`.** The `investment` value was removed in F8.6 — brokers are `institutions`, and 50/30/20 savings comes from `institutionId`-tagged aporte/resgate rows on checking accounts. The one-time guided migration that retired it (`lib/features/data_migration/`, route `/migration`) was deleted with it; a stored `"investment"` degrades to `checking` via `enumByName`.

<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (60-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk go test             # Go test failures only (90%)
rtk jest                # Jest failures only (99.5%)
rtk vitest              # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk pytest              # Python test failures only (90%)
rtk rake test           # Ruby test failures only (90%)
rtk rspec               # RSpec test failures only (60%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%). Format flags (-c, -l, -L, -o, -Z) run raw.
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->
