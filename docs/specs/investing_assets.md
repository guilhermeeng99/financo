# Spec: Assets (investing V2)

> Part of the V2 investing module (`docs/specs/investing.md`). Entity field table
> lives in the umbrella §3; this spec adds rules, repository, state and edges.

A tradable instrument the user owns. Its `kind` + `market` decide which pricing
source values it (`docs/specs/quotes.md`, F2). Belongs to one `Institution`.

## Entity

`Asset` (`lib/features/investing/domain/entities/asset.dart`):
`id, userId, ticker, name, kind (AssetKind), market (Market), currency (Currency),
institutionId?, metadata (Map<String,String>), createdAt`.

- `AssetKind = {stockBr, fiiBr, etfBr, bdrBr, stockUs, etfUs, crypto, treasury,
  fixedIncome, fund, cash}`. `AssetKind.selectableKinds = {etfUs, crypto,
  fixedIncome, cash}` — the only kinds the form's Type picker offers; all kinds
  still deserialize/display/value (CSV import + legacy data). Re-add to surface.
- `Market = {br, us, global}`.
- `cash` = a plain money balance (Wise EUR, broker reserve): valued at **face
  value** in its own currency, consolidated via FX, never flagged stale
  (`valuation.md`).

## `metadata` keys

| Key | For | Meaning |
|---|---|---|
| `allocationClassId` | any | Links the asset to an `AssetClass` (allocation, F5). |
| `allocationTargetPercent` | any | The asset's target share within its class. |
| `fiBasis` | fixedIncome | `cdi \| selic \| prefixed \| ipca`. |
| `fiRate` | fixedIncome | Contracted rate (`110` = 110% of CDI/Selic; absolute annual % for prefixed/IPCA+). |
| `tesouroName` | treasury | Canonical Tesouro Direto bond name for the API. |
| `coingeckoId` | crypto | CoinGecko coin id. |

Keys centralized in a `FixedIncomeMetadata` / `AllocationMetadata` helper
(read/write) so string literals live in one place.

## Business rules

1. `ticker` required, uppercased. For `treasury`/`fixedIncome`/`fund` it may be a
   synthetic id (no market symbol).
2. `institutionId` required on save; must resolve to an existing institution.
   Legacy rows without it load, but editing requires choosing one.
3. `(ticker, market)` unique per user (case-insensitive) → else
   `DuplicateAssetFailure(ticker)`, enforced in `CreateAssetUseCase` /
   `UpdateAssetUseCase` — **not** the repository impl (the check needs the
   current asset list). The CSV importer goes through `CreateAssetUseCase`, so
   it is guarded too.
4. `kind` determines the pricing strategy (`quotes.md`); `currency` defaults from
   `market` (`br→brl`, `us→usd`).
5. Deleting an asset with transactions is **blocked** → `AssetInUseFailure`,
   enforced in `DeleteAssetUseCase` (delete its transactions first).

## Repository contract

```dart
abstract class AssetRepository {
  Future<Either<Failure, List<Asset>>> getAssets({
    required String userId,
    bool forceRefresh = false,
  });
  Future<Either<Failure, Asset>> createAsset(Asset a);
  Future<Either<Failure, Asset>> updateAsset(Asset a);
  Future<Either<Failure, void>> deleteAsset(String id);
}
```

Firestore-primary + Drift cache. Collection `investment_assets/{id}`, scoped by
`userId`. `metadata` serialized as a JSON string column in Drift / a map in
Firestore. The repository validates nothing — rules 3 and 5 live in the use
cases (same split as `institutions.md`).

## State machine

`AssetsCubit` (F3) — `AssetsLoading → AssetsLoaded(list) | AssetsError`; mutations
return `Failure?`.

## Edge cases

| Scenario | Behaviour |
|---|---|
| Unknown ticker (no quote) | Asset valid; UI flags "price unavailable" (valuation). |
| Duplicate `(ticker, market)` | `DuplicateAssetFailure(ticker)`. |
| Legacy asset with no `institutionId` | Listed with "no institution" chip; save requires one. |
| Change `kind`/`currency` after transactions exist | Allowed; warns (pricing reinterpreted). |
| Delete asset with transactions | `AssetInUseFailure`. |
