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

An asset points at its bucket via `Asset.metadata['allocationClassId']` and
carries a **within-class target share** via
`Asset.metadata['allocationTargetPercent']` (0–100), both via
`AllocationMetadata` (mirroring `FixedIncomeMetadata`). The class's
`targetPercent` is the portfolio-level target; the per-asset target refines it —
the class's target value is split across its assets by their shares, driving the
class-detail page's per-asset "add/trim to reach the target" suggestions (ported
from Investanco). The asset form's Allocation section has a class picker (plus a
"None" row that clears both keys) and, once a class is set, a "target % within
class" field.

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
3b. **Per-asset slices** (`AllocationClassSlice.assets`): for each asset linked
   directly to the class (largest value first), `suggestedValue = classTargetValue
   × assetTargetPercent / 100`, `suggestedDelta = suggestedValue − currentValue`
   (+ add, − trim), `percentOfClass`/`percentOfTotal` from its value, and
   `suggestedDeltaNative` = the delta in the asset's own currency via the
   holding's current base↔native ratio (null for base-currency assets or no
   current value). An asset with no target (0) yields a zero suggestion.
4. **Rebalance actions**: one per slice whose `|delta| ≥ 100` minor units (R$1),
   direction buy/sell, amount `|delta|`, sorted by amount desc.
5. `targetSumPercent` = Σ root `targetPercent`; `targetsBalanced` = within ±0.1
   of 100.

## Presentation

`InvestingAllocationCubit` (session-scoped) owns a per-cubit
`PortfolioPricingEngine` exactly like the overview: warm-start → price from
cache → compute → emit (`isRefreshing: true`) → skip-if-fresh else refresh
network → re-price → recompute → emit (`isRefreshing: false`). Route
`/investing/allocation` + sidebar sub-item. It is a **navigation-group peer**,
not a `SubPageScope`: the sidebar and the mobile section strip both reach it
with `go`, and wrapping it hid the mobile bottom bar (design_system.md §7).

`InvestingAllocationPage` (Investanco-style) renders: a **donut**
(`AllocationClassDonut`, `fl_chart`) of the current mix — one arc per class sized
by market value, a muted arc for the unallocated remainder, invested net worth in
the center; a "targets ≠ 100%" banner when unbalanced; one row per bucket (class
icon/color, name, `X% of Y%` = current% of target%, current value, a
`R$ X above/below` delta, and a full-color bar filling current/target — capped
full when over target, with a chevron); a Rebalance section; and an "unallocated"
hint. Tapping a bucket opens its **class-detail page**.

`AllocationClassDetailPage` (route `/investing/allocation/class/:id`, a
`SubPageScope` under the shell) reads the same shell-scoped
`InvestingAllocationCubit` and picks the slice by id. It renders a hero card
(value, `X% of Y%`, bar, `Target: R$ X`, above/below), then the class's assets —
each row shows the ticker, `R$ X · a% of t%`, and a suggestion (`Add/Trim R$ X
(native)` from `suggestedDelta`/`suggestedDeltaNative`, or "no target"), tappable
to edit the asset — and an "Add asset" button that opens the asset form
pre-selecting the class. The app-bar pencil edits the class (the surviving V1
`asset_classes` form). Class create still flows through the `+` FAB on the list.

## Edge cases (covered by `allocation_service_test.dart`)

| Scenario | Behaviour |
|---|---|
| On-target (current == target) | No rebalance actions; `targetsBalanced` true. |
| Under/over target | Buy action for under, sell for over; amount = `|delta|`. |
| Asset with no / unknown class | Value counts toward total but lands in `unallocatedValue`. |
| `fxMissing` holding | Excluded from every total. |
| Subclass holding | Rolls up into its root's `currentValue`. |
| Per-asset slices | Class carries its assets (value-desc) with within-class target %, `percentOfClass/Total`, and `suggestedDelta` (add/trim). |
| Foreign asset suggestion | `suggestedDeltaNative` set in the asset's currency via the holding's base↔native ratio. |
| Empty portfolio | `total = 0`, `currentPercent = 0`, no actions (no div-by-zero). |
