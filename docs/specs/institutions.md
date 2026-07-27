# Spec: Institutions (investing V2)

> Part of the V2 investing module (`docs/specs/investing.md`). Entity field table
> lives in the umbrella §3; this spec adds rules, repository, state and edges.

Where assets are custodied: Nubank, Avenue, a broker, a bank. Pure organizational
grouping used to segment holdings and (later) attach an auto-import source. A
sibling collection — **not** an overload of `Account` (umbrella §0.5).

## Entity

`Institution` (`lib/features/investing/domain/entities/institution.dart`):
`id, userId, name, kind (InstitutionKind), currency (Currency), createdAt,
bank? (String — a `BankType.name` used to render a brand avatar on the
Dashboard; F8), color? (int — ARGB display colour for the fallback avatar,
falls back to a `kind`-derived colour when null)`. `Equatable` + `copyWith`.
`InstitutionKind = {bank, broker, internationalBroker, crypto, other}`.

## Business rules

1. `name` required, trimmed, unique per user (case-insensitive) → else
   `ValidationFailure(duplicateInstitutionName)`, enforced in the repository so the
   form and CSV import are both guarded. Length ≤ 60 enforced by the Drift column.
2. Deleting an institution referenced by any asset or transaction is **blocked** →
   `InUseFailure`. Reassign/delete the assets first.
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
`userId`. Duplicate-name and in-use checks run in the repository impl (need the
current list + reference counts).

## State machine

`InstitutionsCubit` — page-scoped for the institutions management page (F3). States
`InstitutionsLoading → InstitutionsLoaded(list) | InstitutionsError`; mutations
return a `Failure?` for the form.

## Edge cases

| Scenario | Behaviour |
|---|---|
| Duplicate name (case-insensitive) | `ValidationFailure(duplicateInstitutionName)` |
| Delete while referenced | `InUseFailure`; list unchanged |
| Empty list | Empty state with "add institution" CTA |
