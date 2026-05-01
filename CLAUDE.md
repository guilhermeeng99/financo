# Financo — Project Conventions

Personal finance manager built with Flutter. Supports Android, iOS, and Web.

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
| **AI Chat**          | Firebase AI Logic (`firebase_ai`, Vertex AI backend)              |
| **Error handling**   | dartz Either<Failure, T> pattern                                  |
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

Every feature MUST have a spec at `specs/<feature>.md` before writing new code or tests.

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

### UI & Formatting

* Every user-facing string via slang (`t.section.key`) — never hardcode
* Monetary values formatted with `formatCurrency()` — never display raw doubles

---

## State Management

* **Bloc** for complex event-driven logic (Auth, Dashboard, Transactions, Chat)
* **Cubit** for simpler state (Accounts, Categories, Profile, Startup)

### Rules

* UI must not contain business logic
* Cubits/Blocs orchestrate, UseCases execute logic
* State must be immutable

### Lifecycle

* Global blocs are singletons (`registerLazySingleton`)
* Form cubits are created per use (`registerFactory`)

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
bills/{id}
chat_messages/{id}
```

### Guidelines

* Always scope queries by `userId`
* Avoid unbounded queries
* Use indexes explicitly when needed
* Prefer batched writes for multi-document updates

---

## Firebase — Firestore Collections

```
users/{userId}                       → name, email, photoUrl, createdAt
users/{userId}/fcmTokens/{tokenId}   → token, platform, updatedAt
accounts/{id}                        → userId, name, type, bank, initialBalance, creditLimit?, closingDay?, dueDay?, linkedAccountId?, createdAt
categories/{id}                      → userId, name, icon, color, type (income | expense), parentId?
transactions/{id}                    → userId, accountId, categoryId, type, amount, description, date, notes, linkedTransactionId?, createdAt, updatedAt
bills/{id}                           → userId, type (payable | receivable), description, amount, dueDate, status (pending | paid), recurrence (oneShot | monthly), categoryId?, notes?, paidAt?, paidTransactionId?, parentBillId?, createdAt, updatedAt
chat_messages/{id}                   → userId, role, content, metadata, createdAt
```
