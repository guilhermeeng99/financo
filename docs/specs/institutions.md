# Spec: Institutions (investing V2)

> Part of the V2 investing module (`docs/specs/investing.md`). Entity field table
> lives in the umbrella §3; this spec adds rules, repository, state and edges.

Where assets are custodied: Nubank, Avenue, a broker, a bank.

> **Superseded by F8 (2026-07-25)**: this spec originally described an
> institution as "pure organizational grouping … a sibling collection, **not**
> an overload of `Account`" (umbrella §0 decision 5). F8 decision **D1**
> reverses that: the `Institution` **is** the single "investment account"
> record. `AccountType.investment` was retired in data by F8 and removed from
> the enum in F8.6, an institution's Dashboard value is its derived market
> value, and it
> carries `bank`/`color` display hints so it renders like an account row. See
> [investing_account_unification.md](investing_account_unification.md) §2–§4.
> The rules below still hold — F8 added responsibilities, it did not change the
> entity's CRUD contract.

## Entity

`Institution` (`lib/features/investing/domain/entities/institution.dart`):
`id, userId, name, kind (InstitutionKind), currency (Currency), createdAt,
bank? (String — a `BankType.name` used to render a brand avatar on the
Dashboard; F8), color? (int — ARGB display colour for the fallback avatar,
falls back to a `kind`-derived colour when null)`. `Equatable` + `copyWith`.
`InstitutionKind = {bank, broker, internationalBroker, crypto, other}`.

## Business rules

1. `name` required, trimmed, unique per user (case-insensitive) → else
   `DuplicateInstitutionNameFailure`, enforced in
   `CreateInstitutionUseCase` / `UpdateInstitutionUseCase` (**not** the
   repository impl — the check needs the current list, and both the form and
   the CSV importer's find-or-create path go through the use cases). Length
   ≤ 60 enforced by the Drift column.
2. Deleting an institution referenced by any asset or transaction is **blocked**
   → `InstitutionInUseFailure`, enforced in `DeleteInstitutionUseCase`.
   Reassign/delete the assets first.
   > The F9.6 guided migration used to call
   > `InstitutionRepository.deleteInstitution` **directly**, bypassing this
   > guard and relying on its own asset-count check. That migration feature was
   > deleted in F8.6, so this guard is now the only path.
3. `kind` is informational — it never affects pricing (pricing is per-asset).
4. No seed defaults — the user adds institutions manually; the empty state suggests
   "Nubank, Avenue, …".
5. `currency` is the default for assets created under this institution (BRL for
   Nubank, USD for Avenue, EUR for Wise).

## Repository contract

```dart
abstract class InstitutionRepository {
  Future<Either<Failure, List<Institution>>> getInstitutions({
    required String userId,
    bool forceRefresh = false,
  });
  Future<Either<Failure, Institution>> createInstitution(Institution i);
  Future<Either<Failure, Institution>> updateInstitution(Institution i);
  Future<Either<Failure, void>> deleteInstitution(String id);
}
```

Firestore-primary + Drift cache (Financo pattern): `forceRefresh:false` → local;
`forceRefresh:true` → Firestore → replace local. Create/update write Firestore
then upsert local; delete inverts. Collection `institutions/{id}`, scoped by
`userId`.

The repository is a **plain persistence seam** — it validates nothing.
Duplicate-name and in-use checks live in the use cases
(`create_institution_usecase.dart`, `update_institution_usecase.dart`,
`delete_institution_usecase.dart`), because each needs a second read (the
current list, or the asset/transaction reference counts) that a repository impl
has no business owning.

## State machine

`InstitutionsCubit` — **shell-scoped**, not page-scoped: `app_router.dart`
creates it in the shell's `BlocProvider` list with `userId` from `AuthBloc` and
eagerly calls `load()`, because the Dashboard and the investing overview both
read the institution list, not just the management page (CLAUDE.md § State
Management → Lifecycle). States
`InstitutionsLoading → InstitutionsLoaded(list) | InstitutionsError`; mutations
return a `Failure?` for the form.

## Edge cases

| Scenario | Behaviour |
|---|---|
| Duplicate name (case-insensitive) | `ValidationFailure(duplicateInstitutionName)` |
| Delete while referenced | `InUseFailure`; list unchanged |
| Empty list | Empty state with "add institution" CTA. Also drives the 50/30/20 "cadastre a corretora" tip → `/investing/institution/add` (`fifty_thirty_twenty.md` rule 9) |
| Mis-modelled as a foreign cash account (Wise) | Was converted to a `checking` account by the F9.6 guided migration, then deleted — only when it held **zero** assets. That migration is done and its feature removed (see [investing_account_unification.md](investing_account_unification.md) §6) |
