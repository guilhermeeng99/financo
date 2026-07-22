# Allocation (V2) — F5

Current-vs-target asset allocation and rebalance suggestions, computed over
**market value** (not declared principal). Ports Investanco's
`computeInvestmentOverview` into Financo's investing module.

## Source of the buckets

The allocation buckets are the surviving `asset_classes` collection (the only
part of the V1 `investments` feature that lives on). Each row: `id, userId,
name, icon (int Material code point), color (int ARGB), targetPercent (0–100),
parentId?`. The investing module never depends on the V1 entity directly — the
`InvestingAllocationCubit` reads them through the V1 `GetAssetClassesUseCase`
and maps `AssetClassEntity → AllocationClass` (investing-owned) at that single
boundary, so F7 can relocate the collection without touching the service or UI.

## Asset → bucket link

An asset points at its bucket via `Asset.metadata['allocationClassId']`
(`AllocationMetadata`, mirroring `FixedIncomeMetadata`). The **target** lives on
the class, not the asset, so retargeting a class moves every asset in it at
once. The asset form has an Allocation section with a class picker (plus a
"None" row that clears the link). Investanco's per-asset `allocationTargetPercent`
sub-target is intentionally **not** ported — the class-level current-vs-target is
the rebalance signal.

## Computation (`AllocationService.compute`, pure)

Inputs: `classes: List<AllocationClass>`, `assets: List<Asset>`,
`holdings: List<HoldingValuation>` (already priced), `base: Currency`.

1. **Value per asset** = Σ `holding.marketValueBase`, **excluding** `fxMissing`
   holdings (an unconsolidatable foreign holding never distorts the weights).
   `totalValue` = Σ of those.
2. **Assign to bucket**: each asset's value goes to `allocationClassId` if that
   id is a known class; otherwise it stays unassigned. `allocatedValue` = Σ
   assigned; `unallocatedValue = totalValue − allocatedValue`.
3. **Per root** (`parentId == null`): `currentValue` = own value + Σ subclass
   values (subclasses roll up). `currentPercent = currentValue / totalValue`
   (0 when total is 0 — no div-by-zero). `targetValue = totalValue ×
   targetFraction`. `delta = targetValue − currentValue` (+ under → buy, − over
   → sell). Slices sorted by current value desc.
4. **Rebalance actions**: one per slice whose `|delta| ≥ 100` minor units (R$1),
   direction buy/sell, amount `|delta|`, sorted by amount desc.
5. `targetSumPercent` = Σ root `targetPercent`; `targetsBalanced` = within ±0.1
   of 100.

## Presentation

`InvestingAllocationCubit` (session-scoped) owns a per-cubit
`PortfolioPricingEngine` exactly like the overview: warm-start → price from
cache → compute → emit (`isRefreshing: true`) → skip-if-fresh else refresh
network → re-price → recompute → emit (`isRefreshing: false`). Route
`/investing/allocation` (a `SubPageScope` under the shell) + sidebar sub-item.

`InvestingAllocationPage` renders: total value + allocated/unallocated line, a
"targets ≠ 100%" banner when unbalanced, one row per bucket (class icon/color, current
value, a bar with current-fill + target-tick, `current% vs target%`, and a
buy/sell/on-target delta label), a Rebalance section listing the actions, and an
"unallocated" hint when any value is unassigned. Empty state when no buckets
exist.

## Edge cases (covered by `allocation_service_test.dart`)

| Scenario | Behaviour |
|---|---|
| On-target (current == target) | No rebalance actions; `targetsBalanced` true. |
| Under/over target | Buy action for under, sell for over; amount = `|delta|`. |
| Asset with no / unknown class | Value counts toward total but lands in `unallocatedValue`. |
| `fxMissing` holding | Excluded from every total. |
| Subclass holding | Rolls up into its root's `currentValue`. |
| Empty portfolio | `total = 0`, `currentPercent = 0`, no actions (no div-by-zero). |
