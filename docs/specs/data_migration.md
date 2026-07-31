# Spec: Guided Data Migration (F8.5 + F9.6)

> **Status**: Implemented. Route `/migration`, feature at
> `lib/features/data_migration/`.
> **Last updated**: 2026-07-31
> **Companions**: [investing_account_unification.md](investing_account_unification.md) §6
> (F8-M) and [multi_currency_accounts.md](multi_currency_accounts.md) §6 (F9-M) —
> those specs decide *what* must move; this one is the contract for the code
> that moves it.

A **one-time, user-supervised** rewrite of the user's own production Firestore
data, run from inside the app. It does two things that F8 and F9 left as
migrations:

1. **F8.5 — fold each `AccountType.investment` account into an `Institution`.**
   Its checking-side transfer legs become single-entry aportes tagged with the
   institution; the account-side legs and the account itself are deleted.
2. **F9.6 — convert each Wise-style `Institution` into a foreign-currency
   checking account.** Those institutions were only ever a mis-modelling of a
   EUR spending account (`multi_currency_accounts.md` §1).

The feature is deliberately **plan-then-apply**: nothing is written until the
user reviews a computed diff and confirms a second dialog. It has no repository
and no persisted state of its own — it orchestrates the account, institution,
transaction and asset repositories that already exist.

> **Why it lives in the app and not in a script.** The rewrite needs the same
> Firestore credentials, the same `userId` scoping and the same entity
> serialization the app already owns; a standalone script would duplicate all
> three and drift. It is also single-owner data — one user, one run.

---

## 1. Entity contracts

All four types are **plain in-memory value objects** (`Equatable`, no
`copyWith`, never persisted). They live in
`lib/features/data_migration/domain/`.

### `ConvertedCashFlow` (`account_migration_planner.dart`)

| Field | Type | Meaning |
|---|---|---|
| `transactionId` | `String` | The **checking-side** leg to re-tag. Its `institutionId` is set and its `linkedTransactionId` cleared. |
| `institutionId` | `String` | The institution the retired account merges into. |

### `InvestmentAccountMerge` (`account_migration_planner.dart`)

| Field | Type | Meaning |
|---|---|---|
| `account` | `AccountEntity` | The `type == investment` account being retired. |
| `institution` | `Institution` | The institution it folds into. |
| `aportes` | `List<ConvertedCashFlow>` | Checking-side legs to re-tag as institution cash flows. |
| `deletedLegIds` | `List<String>` | Account-side transfer legs to delete (their counterpart carries the flow). |
| `orphanTransactionCount` | `int` | Non-transfer transactions still pointing at the account. **Surfaced as a warning, never migrated or deleted.** |

`props` compares `account.id` / `institution.id` rather than the whole
entities — the plan is identity-driven and two loads of the same account must
compare equal.

### `WiseInstitutionConversion` (`account_migration_planner.dart`)

| Field | Type | Invariant |
|---|---|---|
| `institution` | `Institution` | Must have **zero** assets (checked by the planner). |
| `currency` | `Currency` | The new account's currency. Defaults to `Currency.eur`. |

### `AccountMigrationPlan` (`account_migration_planner.dart`)

| Field | Type | Meaning |
|---|---|---|
| `merges` | `List<InvestmentAccountMerge>` | F8.5 work items. |
| `conversions` | `List<WiseInstitutionConversion>` | F9.6 work items. |
| `warnings` | `List<String>` | Human-readable problems. Non-blocking; hard-coded PT-BR/EN strings, **not** slang keys (see §6). |

`isEmpty => merges.isEmpty && conversions.isEmpty` — warnings alone do not make
a plan actionable, and the Apply button is gated on `!isEmpty`.

### `MigrationResult` (`account_migration_executor.dart`)

Counters shown on the done screen, all defaulting to `0`:
`aportesRetagged`, `legsDeleted`, `accountsRemoved`, `accountsCreated`,
`institutionsRemoved`.

---

## 2. Business rules (numbered, testable)

### Planning — `AccountMigrationPlanner.plan(...)`

1. **Pure.** `plan()` performs no IO and mutates nothing. Given the same
   inputs it returns the same plan, which is what makes the preview
   trustworthy: the diff the user approves is the diff that runs.
2. **Only investment accounts are candidates.** Accounts with
   `type != AccountType.investment` are skipped silently.
3. **An unmapped account is a warning, not a guess.** When
   `accountToInstitutionId` has no entry for an investment account, the planner
   emits `No institution chosen for account "<name>".` and produces no merge.
4. **A dangling mapping is a warning.** When the chosen institution id is not
   in `institutions`, the planner emits
   `Institution for "<name>" no longer exists.` and produces no merge.
5. **Every transfer leg on the retired account is deleted; its counterpart is
   re-tagged.** For each transaction with `accountId == account.id` and
   `isTransfer`, the leg's id goes to `deletedLegIds`, and its
   `linkedTransactionId` counterpart (looked up in the same transaction list)
   becomes a `ConvertedCashFlow`. This preserves the money movement while
   collapsing the two-legged transfer into the single-entry aporte model F8
   introduced.
6. **A half-pair still loses its leg.** When the counterpart is not in the
   supplied transaction list, the leg is still deleted but **no** cash flow is
   produced — there is nothing to re-tag, and leaving an orphan leg pointing at
   a deleted account is worse than losing it.
7. **Non-transfer transactions on the account are counted, never touched.**
   `orphanTransactionCount` increments and the planner emits
   `"<name>" has N non-transfer transaction(s) that will be left pointing at
   the retired account — review them first.` The user resolves them by hand.
8. **An institution that still holds assets cannot convert.**
   `institutionAssetCounts[id] > 0` → warning
   `Institution "<name>" holds N asset(s) and cannot convert to a cash account
   until they are moved.`, and **no** conversion is planned. The assets would
   otherwise be orphaned by the institution delete in rule 13.
9. **An unknown conversion id is skipped silently** (no warning) — unlike rule
   4, the user never named it; it can only come from stale cubit state.
10. **Conversion currency is uniform.** Every conversion in one plan uses the
    same `conversionCurrency` (default EUR). Per-institution currency choice is
    out of scope — the only real case is Wise EUR.

### Applying — `AccountMigrationExecutor.apply(plan)`

11. **Sequential, fail-fast, no rollback.** Writes run in declaration order and
    the first `Left` returns immediately, carrying that `Failure`. Everything
    written before it **stays written**. This is deliberate: each step is
    individually idempotent-ish and the plan is recomputed from live data on
    the next load, so a partial run is finished by re-opening the page — an
    all-or-nothing batch across four collections is not available and a
    hand-rolled compensating write would be a second, untested migration.
12. **Merge order is fixed** (per merge, `plan.merges` order):
    1. Re-tag each `ConvertedCashFlow` via
       `TransactionEntity.asInstitutionCashFlow(institutionId)` +
       `updateTransaction`.
    2. Delete each id in `deletedLegIds`.
    3. `updateInstitution` with `bank: merge.account.bank.name` — the account's
       brand hint carries onto the institution so the Dashboard row keeps its
       avatar.
    4. `deleteAccount(merge.account.id)`.

    Re-tagging before deleting means a crash between the two leaves the money
    visible (double-counted at worst), not missing.
13. **A cash-flow row that has already vanished is skipped, not fatal.**
    `getTransaction` returning `Left` (or the row being gone) `continue`s
    without incrementing `aportesRetagged`. A re-run of a partially applied
    migration must not fail on the rows it already converted.
14. **Conversion order is fixed** (per conversion): create the account, then
    delete the institution. The new `AccountEntity` is
    `type: checking`, `initialBalance: 0`, `currency: conversion.currency`,
    `name`/`userId`/`createdAt` copied from the institution, `id: ''` (the
    repository assigns it).
15. **The institution's `bank` hint maps back to a `BankType` by name**
    (`_bankFor`), falling back to `BankType.others`. The hint is a free-form
    `String?` on `Institution`, so an unrecognised value must not throw.
16. **The old principal is dropped.** No balance is carried from a retired
    investment account (F8 decision O3) and a converted institution starts at
    `initialBalance: 0`. The user re-seeds the EUR account by hand if needed.

### Loading — `MigrationCubit`

17. **All four reads must succeed.** Accounts, institutions, transactions and
    assets are fetched, and the **first** failure in that order emits
    `MigrationError`. A partial data set would produce a plan that deletes
    legs whose counterparts simply weren't loaded (rule 6).
18. **Asset counts are derived, not fetched.** `assetCounts[institutionId]` is
    a tally over `getAssets`; assets with a null `institutionId` are ignored.
19. **Exact-name pre-fill.** Each investment account is pre-mapped to the
    institution whose `name` matches after `trim().toLowerCase()`. `??=` means
    a user choice is never overwritten by a reload. No fuzzy matching — a
    near-miss the user has to notice is safer than a wrong merge they don't.
20. **Every choice re-plans.** `chooseInstitution` and `toggleConvert` mutate
    the private mapping and immediately re-emit `MigrationReady` with a freshly
    computed plan, so the preview can never lag the inputs.
21. **`apply()` is a no-op unless the state is `MigrationReady`** — it reads
    the plan off the state, not off a field, so what is applied is exactly what
    was rendered.

---

## 3. Repository contract

The feature owns **no repository**. It consumes four existing ones plus one
executor, all resolved from `get_it` by `MigrationPage`:

| Dependency | Methods used |
|---|---|
| `AccountRepository` | `getAccounts`, `createAccount`, `deleteAccount` |
| `InstitutionRepository` | `getInstitutions`, `updateInstitution`, `deleteInstitution` |
| `TransactionRepository` | `getTransactions`, `getTransaction`, `updateTransaction`, `deleteTransaction` |
| `AssetRepository` | `getAssets` (asset-count guard only) |
| `AccountMigrationExecutor` | `apply(plan)` |

> **The executor talks to the repositories directly, not through the use
> cases** — so it bypasses `DeleteInstitutionUseCase`'s `InstitutionInUseFailure`
> guard (`institutions.md` rule 2). That is intentional: the planner's own
> asset-count check (rule 8) stands in for it, and the migration legitimately
> deletes an account whose transactions it is rewriting in the same pass. Note
> the substitute guard counts **assets** only — an institution referenced solely
> by an `investment_transactions` row would slip through. Not reachable today
> (a transaction requires an asset, and the asset carries the same
> `institutionId`), but it is a narrower guarantee than the use case gives.

```dart
class AccountMigrationPlanner {
  const AccountMigrationPlanner();

  AccountMigrationPlan plan({
    required List<AccountEntity> accounts,
    required List<Institution> institutions,
    required List<TransactionEntity> transactions,
    required Map<String, String> accountToInstitutionId,
    required Set<String> institutionIdsToConvert,
    Map<String, int> institutionAssetCounts = const {},
    Currency conversionCurrency = Currency.eur,
  });
}

class AccountMigrationExecutor {
  const AccountMigrationExecutor({
    required AccountRepository accountRepository,
    required InstitutionRepository institutionRepository,
    required TransactionRepository transactionRepository,
  });

  Future<Either<Failure, MigrationResult>> apply(AccountMigrationPlan plan);
}
```

**DI**: only the executor is registered —
`injection_container.dart` (`..registerLazySingleton(() => AccountMigrationExecutor(...))`,
under the `// F8.5/F9.6` comment). The planner is a `const` default argument on
the cubit, so tests can inject a stub without touching the container.

**Route**: `AppRoutes.migration` (`/migration`) →
`SubPageScope(child: MigrationPage())` in `app_router.dart`. It is **not**
linked from any menu — reachable by typing the URL / deep link only, which is
the intended discoverability for a destructive one-off.

---

## 4. State machine

`MigrationCubit` (`presentation/cubit/migration_cubit.dart`), created
per-visit by `MigrationPage` with `userId` from `context.currentUserId`.
Sealed hierarchy, 5 states:

```
                    ┌──────────────────┐
   construct  ──▶   │ MigrationLoading │   (initial)
                    └────────┬─────────┘
                   load()    │
              ┌──────────────┴──────────────┐
              ▼                             ▼
   ┌────────────────────┐        ┌────────────────────┐
   │   MigrationReady   │        │   MigrationError   │  (terminal)
   │  plan, accounts,   │        │      failure       │
   │  institutions,     │        └────────────────────┘
   │  mapping,          │                  ▲
   │  toConvert,        │                  │
   │  assetCounts       │                  │
   └─────────┬──────────┘                  │
             │  chooseInstitution / toggleConvert
             │  ──▶ re-emits MigrationReady (rule 20)
             │
             │  apply()   [ignored unless Ready — rule 21]
             ▼
   ┌────────────────────┐
   │ MigrationApplying  │
   └─────────┬──────────┘
             │
      ┌──────┴───────┐
      ▼              ▼
┌───────────┐  ┌────────────────┐
│MigrationDone│ │ MigrationError │
│  (result)  │  └────────────────┘
└───────────┘   (terminal both)
```

| State | Fields |
|---|---|
| `MigrationLoading` | — |
| `MigrationReady` | `plan`, `investmentAccounts`, `institutions`, `mapping (Map<String, String?>)`, `toConvert (Set<String>)`, `assetCounts (Map<String, int>)` |
| `MigrationApplying` | — |
| `MigrationDone` | `result (MigrationResult)` |
| `MigrationError` | `failure` |

- `mapping`, `toConvert` and `assetCounts` are emitted as **unmodifiable**
  copies so the view can never mutate cubit state.
- `MigrationDone` and `MigrationError` are terminal — there is no reset
  transition. Recovering from a partial run means leaving the page and coming
  back, which forces a fresh `load()` and therefore a fresh plan (rule 11).

---

## 5. UI

`MigrationPage` / `_MigrationView` (`presentation/pages/migration_page.dart`).
A `switch` on the sealed state renders:

| State | Render |
|---|---|
| `MigrationLoading` | Centered `CircularProgressIndicator`. |
| `MigrationApplying` | Spinner + "Aplicando…". |
| `MigrationError` | `Erro: ${localizedFailure(failure)}`. |
| `MigrationDone` | `_DoneView` — check icon (`colors.income`) + the five counters. |
| `MigrationReady` | `_ReadyView` — mapping list, conversion list, warnings, Apply button. |

`_ReadyView` sections, in order:

1. **"Contas de investimento → instituição"** — one `Card`/`ListTile` per
   investment account with a `DropdownButton<String?>`; the first item (`—`,
   value `null`) clears the mapping.
2. **"Instituições → conta em moeda estrangeira (EUR)"** — a `_ConvertTile`
   (`CheckboxListTile`) per institution. **Disabled** (`onChanged: null`) with
   the subtitle `N ativo(s) — mova-os antes de converter` when it holds assets,
   so rule 8 is enforced in the UI too, not only in the planner.
3. **"Avisos"** — `plan.warnings`, each with a `warning_amber` icon. Hidden
   when empty.
4. **"Revisar e aplicar"** — `FilledButton`, disabled while `plan.isEmpty`.

Applying goes through a second `AlertDialog` (`_confirmAndApply`) that states
the counts and that the change **"Não é facilmente reversível"**. Only a
`true` result calls `cubit.apply()`.

---

## 6. Deliberate deviations from the project conventions

Both are intentional and documented in the source; do not "fix" them without
re-reading this section.

- **Strings are hard-coded PT-BR, not slang.** `migration_page.dart` says so at
  the top: this is a one-off admin utility, not part of the localized product
  surface. Adding ~15 keys to `en`/`pt-BR` for a screen that runs once, for one
  user, and is then dead weight, is worse than the hard-coding.
- **The page does not use the design-system widgets** (`FinancoLargeAppBar`,
  `FinancoPickerField`, `FinancoSubmitBar`, `AmountText`). Raw Material
  `Card`/`ListTile`/`DropdownButton`/`CheckboxListTile` are used instead, for
  the same reason. `design_system.md` §11's checklist does not apply here.

Planner warnings are English while the page chrome is PT-BR — an artefact of
the planner being pure domain code with no `BuildContext`. Cosmetic; the
warnings are read once by the only user who will ever see them.

---

## 7. Edge cases

| Scenario | Behaviour |
|---|---|
| No investment accounts and no institutions to convert | `plan.isEmpty` → Apply disabled; the page still renders (empty sections). |
| Investment account with no institution chosen | Warning (rule 3), no merge; other accounts still migrate. |
| Two investment accounts mapped to the **same** institution | Allowed. Both merge; the second `updateInstitution` overwrites the first's `bank` hint. Not guarded — the real case is one account per broker. |
| Investment account with only non-transfer transactions | Merge has empty `aportes`/`deletedLegIds`; the account is still deleted and the orphan warning fires (rule 7). |
| Transfer leg whose counterpart is outside the loaded set | Leg deleted, no cash flow (rule 6). Cannot happen in practice — `getTransactions` is unfiltered. |
| Cash-flow row deleted on another device mid-run | Skipped, run continues (rule 13). |
| Institution holding assets, ticked for conversion | Warning + no conversion (rule 8); the checkbox is also disabled in the UI. |
| `updateTransaction` / `deleteAccount` fails midway | `Left(failure)` → `MigrationError`; prior writes persist. Re-open `/migration` to finish (rule 11). |
| Migration run twice | Second run finds no `type == investment` accounts and no ticked institutions → empty plan, Apply disabled. |
| Institution with an unrecognised `bank` string | Converted account gets `BankType.others` (rule 15). |

---

## 8. Testing

`test/features/data_migration/` mirrors `lib/`:

- **`domain/account_migration_planner_test.dart`** — `investment account merge
  (F8.5)`: aporte conversion + leg deletion, orphan warning, unmapped account
  warning, vanished-institution warning, half-paired leg. `Wise institution
  conversion (F9.6)`: holding-free convert, refusal when assets remain. Plus
  the empty-plan case.
- **`domain/account_migration_executor_test.dart`** — a merge + conversion end
  to end (asserting the exact repository calls and the `MigrationResult`
  counters), and four fail-fast paths: generic write failure, aporte re-tag
  failure, institution-update failure, account-delete failure.
- **`presentation/cubit/migration_cubit_test.dart`** — `load` emits `Ready`
  with the exact-name pre-fill, `apply` delegates to the executor and emits
  `Done`, and a repository failure emits `Error`.

No widget test: the page is throwaway (§6) and its logic is entirely in the
cubit/planner, which are covered.

---

## 9. Retirement

This feature is **scheduled for deletion**. Once the user confirms the
migration has run against production and the Dashboard reconciles
(`investing_account_unification.md` §6 step 4), remove:

- `lib/features/data_migration/` and `test/features/data_migration/`
- the `AccountMigrationExecutor` registration in `injection_container.dart`
- `AppRoutes.migration` + its `GoRoute`
- the CLAUDE.md pointer under the Firestore collection map

It is coupled to `AccountType.investment`, so it is a blocker on **F8.6**
(removing the enum value) — see `TODO.md`.
