# Investments — superseded by the V2 investing module (F7)

The legacy tracking-only **investments** feature was removed in F7 of the
Investanco→Financo integration. It valued a portfolio from **manually declared**
`AssetHoldingEntity` amounts against investment-account balances (Model-A
"Σ holdings ≤ account balance") and computed a static overview. That whole
stack — `AssetHoldingEntity`, `InvestmentOverview`, `computeInvestmentOverview`,
`GetInvestmentOverviewUseCase`, `InvestmentsCubit`, `investments_page` and the
`investment_*` widgets — has been deleted.

The V2 investing module replaces it: holdings are **derived from real buy/sell/
dividend transactions** and valued at **market price** (multi-currency, quotes/
FX/fixed-income). See:

- `docs/specs/investing.md` — umbrella
- `docs/specs/institutions.md`, `docs/specs/investing_assets.md`,
  `docs/specs/investing_transactions.md`, `docs/specs/holdings.md`
- `docs/specs/valuation.md` — pricing, net-worth overview, snapshots
- `docs/specs/quotes.md` — market data (quotes/FX/indices)
- `docs/specs/allocation.md` — current-vs-target allocation + rebalance
- `docs/specs/investing_csv_import.md` — CSV import

## What survives from this feature: allocation classes

The **`asset_classes`** collection lives on as the allocation buckets, kept
under `lib/features/investments/` (data/domain + the class form UI):

### `AssetClassEntity`

| Field | Type | Notes |
|---|---|---|
| `id` | String | |
| `userId` | String | |
| `name` | String | |
| `icon` | int | Material code point (rendered via `materialIconFor`) |
| `color` | int | ARGB |
| `targetPercent` | double | 0–100; root = share of the whole portfolio |
| `parentId` | String? | null = root; one nesting level only |
| `createdAt` | DateTime | |

Helpers: `targetFraction` (`targetPercent / 100`), `isSubclass`, `canBeParent`.

### Rules (enforced by the use cases)

- Create/Update validate a non-empty name, `targetPercent ∈ [0, 100]`, a
  parent-must-be-root constraint (no 2-level chains), and a sibling target-sum
  ≤ 100 check.
- **Delete** (`DeleteAssetClassUseCase`) blocks only when **subclasses** still
  point at the class — the holdings block was removed (there are no holding
  records in V2; an asset links to a class via
  `Asset.metadata['allocationClassId']`, see `allocation.md`).

### How it's used

The V2 **allocation page** (`docs/specs/allocation.md`) reads these classes
(through `GetAssetClassesUseCase`, mapped to the investing-owned
`AllocationClass`) and is the entry point for managing them: its FAB opens the
class form (`AppRoutes.assetClass`) to add a class, and tapping a bucket opens
the same form to edit it. The classes are mirrored to Firestore and pulled by
`SyncService.fullSync`.
