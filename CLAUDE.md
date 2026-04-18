# Financo — Project Conventions

Personal finance manager built with Flutter. Supports Android, iOS, and Web.

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
- `domain/` — entities, repository interfaces, use cases
- `data/` — models, datasources, repository implementations
- `presentation/` — cubits/blocs, pages, widgets

## Key Technologies

| Aspect | Detail |
|---|---|
| **State management** | flutter_bloc (Cubits for simple state, Blocs for event-driven) |
| **DI** | get_it (service locator in `lib/app/di/injection_container.dart`) |
| **Routing** | go_router (declarative, path-based, shell route) |
| **Database** | Drift (local SQLite cache) + Firebase Firestore (remote) |
| **Auth** | Firebase Auth + Google Sign-In |
| **AI Chat** | Firebase AI Logic (`firebase_ai`, Vertex AI backend) |
| **Error handling** | dartz Either<Failure, T> pattern |
| **Linting** | very_good_analysis (strict) |
| **i18n** | slang (generated in `lib/gen/`) |
| **Theme** | Light + Dark Material 3, custom AppColors / AppTheme |
| **Currency** | BRL (Real brasileiro) via `intl` |

## Commands

```bash
flutter test                            # Run all tests
flutter test test/features/categories/  # Run feature tests
flutter analyze                         # Static analysis (must be zero issues)
flutter run                             # Run the app
dart run build_runner build             # Generate code (Drift)
dart run slang                          # Generate i18n
```

## Post-Change Checklist

After every code change:

1. Run `dart run slang` if any i18n JSON was modified.
2. Run `dart run build_runner build` if Drift tables or DAOs changed.
3. Run `flutter analyze` — **zero** errors, warnings, and info-level issues.
4. Run `flutter test` — all tests must pass.
5. Never add `// ignore` without clear justification.

## Spec-Driven Development

Every feature MUST have a spec at `specs/<feature>.md` before writing new code or tests.

**Spec workflow:**
1. Write or update the spec (business rules, contracts, state machines)
2. Write tests based on the spec
3. Implement or modify code to pass the tests
4. Update the spec if requirements change

**Spec structure:**
- Entity contract (fields, types, invariants)
- Business rules (numbered, testable)
- Repository contract (methods, parameters, return types)
- State machines (cubit/bloc states and transitions)
- Edge cases

## Harness Engineering

Test infrastructure lives in `test/harness/`:
- `mocks.dart` — centralized mock declarations (mocktail)
- `helpers.dart` — shared test setup and utilities
- `factories/` — test data factories per entity

**Conventions:**
- One test file per source file, mirroring the `lib/` structure
- Use `bloc_test` for cubit/bloc testing
- Use factories for test data — never hardcode entities in tests
- Mock at the boundary (repositories for cubits, datasources for repositories)

## Code Conventions

- Entities use `Equatable` and provide `copyWith`
- Failures are sealed classes (`ServerFailure`, `AuthFailure`, etc.)
- Use cases are single-method classes with `call()` operator
- Models extend entities and handle serialization
- All repository methods return `Future<Either<Failure, T>>`
- Use package imports (`package:financo/...`), not relative
- Apply `const` constructors wherever possible
- Every user-facing string via slang `t.section.key` — never hardcode
- Monetary values formatted with `formatCurrency()` — never display raw doubles

## State Management

- **Bloc** for complex event-driven logic (Auth, Dashboard, Transactions, Chat)
- **Cubit** for simpler state (Accounts, Categories, Profile, Startup)
- Global blocs are singletons (`registerLazySingleton`) provided in `app_widget.dart`
- Form cubits are created per use (`registerFactory`) locally in pages

## Firebase — Firestore Collections

```
users/{userId}          → name, email, photoUrl, createdAt
accounts/{id}           → userId, name, type, bank, initialBalance, creditLimit?, closingDay?, dueDay?, createdAt
categories/{id}         → userId, name, icon, color, type (income | expense)
transactions/{id}       → userId, accountId, categoryId, type, amount, description, date, notes, linkedTransactionId?, createdAt, updatedAt
chat_messages/{id}      → userId, role, content, metadata, createdAt
```
