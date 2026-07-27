import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/allocation_class.dart';
import 'package:financo/features/investing/domain/entities/allocation_overview.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/holding_valuation.dart';
import 'package:financo/features/investing/domain/services/allocation_metadata.dart';

/// Computes current-vs-target allocation over **market value** (not principal),
/// ported from Investanco's `computeInvestmentOverview`. Pure: no I/O, no
/// clock. Assets link to a bucket via `Asset.metadata['allocationClassId']`;
/// subclass values roll up into their root. See `docs/specs/allocation.md`.
class AllocationService {
  const AllocationService();

  /// Below this the drift is treated as on-target and yields no rebalance
  /// action — R$1 (100 minor units), matching the transaction rounding floor.
  static const rebalanceThresholdMinor = 100;

  /// Builds the overview from priced [holdings], the [assets] that carry the
  /// bucket links, and the [classes] (targets). [base] is the currency every
  /// value is consolidated into.
  AllocationOverview compute({
    required List<AllocationClass> classes,
    required List<Asset> assets,
    required List<HoldingValuation> holdings,
    required Currency base,
  }) {
    // Market value per asset (base), excluding fx-missing holdings so an
    // unconsolidatable foreign holding never distorts the percentages. The
    // native total per asset rides alongside so the class detail can suggest an
    // aporte in the asset's own currency (e.g. US$ for an Avenue ETF).
    final valueByAsset = <String, Money>{};
    final nativeByAsset = <String, Money>{};
    var total = Money.zero(base);
    for (final h in holdings) {
      if (h.fxMissing) continue;
      total += h.marketValueBase;
      valueByAsset[h.assetId] =
          (valueByAsset[h.assetId] ?? Money.zero(base)) + h.marketValueBase;
      final native = h.marketValueNative;
      nativeByAsset[h.assetId] =
          (nativeByAsset[h.assetId] ?? Money.zero(native.currency)) + native;
    }

    // Assign each asset's value to its (known) bucket.
    final assetsById = {for (final a in assets) a.id: a};
    final knownIds = {for (final c in classes) c.id};
    final valueByClass = <String, Money>{};
    var allocated = Money.zero(base);
    valueByAsset.forEach((assetId, value) {
      final asset = assetsById[assetId];
      final classId = asset == null ? null : AllocationMetadata.classId(asset);
      if (classId == null || !knownIds.contains(classId)) return;
      valueByClass[classId] =
          (valueByClass[classId] ?? Money.zero(base)) + value;
      allocated += value;
    });
    final unallocated = total - allocated;

    final subsByParent = <String, List<AllocationClass>>{};
    for (final c in classes) {
      final parent = c.parentId;
      if (parent != null) (subsByParent[parent] ??= []).add(c);
    }

    final slices = <AllocationClassSlice>[];
    for (final root in classes.where((c) => c.isRoot)) {
      var rootValue = valueByClass[root.id] ?? Money.zero(base);
      for (final sub in subsByParent[root.id] ?? const <AllocationClass>[]) {
        rootValue += valueByClass[sub.id] ?? Money.zero(base);
      }
      final targetValue = total * root.targetFraction;
      slices.add(
        AllocationClassSlice(
          classId: root.id,
          name: root.name,
          icon: root.icon,
          color: root.color,
          currentValue: rootValue,
          currentPercent: total.minorUnits == 0
              ? 0
              : rootValue.minorUnits / total.minorUnits,
          targetPercent: root.targetFraction,
          targetValue: targetValue,
          delta: targetValue - rootValue,
          assets: _assetSlices(
            classId: root.id,
            classTargetValue: targetValue,
            total: total,
            assets: assets,
            valueByAsset: valueByAsset,
            nativeByAsset: nativeByAsset,
            base: base,
          ),
        ),
      );
    }
    slices.sort(
      (a, b) => b.currentValue.minorUnits.compareTo(a.currentValue.minorUnits),
    );

    final actions = <RebalanceAction>[
      for (final s in slices)
        if (s.delta.minorUnits.abs() >= rebalanceThresholdMinor)
          RebalanceAction(
            classId: s.classId,
            name: s.name,
            direction: s.isUnderTarget
                ? RebalanceDirection.buy
                : RebalanceDirection.sell,
            amount: Money(s.delta.minorUnits.abs(), base),
          ),
    ]..sort((a, b) => b.amount.minorUnits.compareTo(a.amount.minorUnits));

    final targetSum = classes
        .where((c) => c.isRoot)
        .fold<double>(0, (sum, c) => sum + c.targetPercent);

    return AllocationOverview(
      totalValue: total,
      allocatedValue: allocated,
      unallocatedValue: unallocated,
      slices: slices,
      rebalanceActions: actions,
      targetSumPercent: targetSum,
    );
  }

  /// The per-asset slices for one class: every asset linked directly to
  /// [classId], largest first, each priced against its within-class target
  /// share (`AllocationMetadata.target`). The class's [classTargetValue] is
  /// split by those shares to derive each asset's suggested value and the
  /// aporte/trim to reach it (in base and, when foreign, native currency).
  List<AllocationAssetSlice> _assetSlices({
    required String classId,
    required Money classTargetValue,
    required Money total,
    required List<Asset> assets,
    required Map<String, Money> valueByAsset,
    required Map<String, Money> nativeByAsset,
    required Currency base,
  }) {
    int valueMinor(String assetId) => valueByAsset[assetId]?.minorUnits ?? 0;

    final classAssets =
        assets.where((a) => AllocationMetadata.classId(a) == classId).toList()
          ..sort((a, b) => valueMinor(b.id).compareTo(valueMinor(a.id)));

    final classTotalMinor = classAssets.fold<int>(
      0,
      (sum, a) => sum + valueMinor(a.id),
    );
    final targetValueMinor = classTargetValue.minorUnits;

    return [
      for (final asset in classAssets)
        () {
          final currentMinor = valueMinor(asset.id);
          final assetTarget = AllocationMetadata.target(asset);
          final suggestedMinor = (targetValueMinor * assetTarget / 100).round();
          final deltaMinor = suggestedMinor - currentMinor;
          return AllocationAssetSlice(
            assetId: asset.id,
            ticker: asset.ticker,
            currentValue: Money(currentMinor, base),
            percentOfClass: classTotalMinor == 0
                ? 0
                : currentMinor / classTotalMinor,
            percentOfTotal: total.minorUnits == 0
                ? 0
                : currentMinor / total.minorUnits,
            targetPercent: assetTarget,
            suggestedValue: Money(suggestedMinor, base),
            suggestedDelta: Money(deltaMinor, base),
            suggestedDeltaNative: _nativeDelta(
              asset: asset,
              base: base,
              currentBaseMinor: currentMinor,
              currentNativeMinor: nativeByAsset[asset.id]?.minorUnits ?? 0,
              deltaBaseMinor: deltaMinor,
            ),
          );
        }(),
    ];
  }

  /// The base-currency delta expressed in the asset's own currency, using the
  /// holding's current base↔native ratio. Null for base-currency assets or when
  /// the ratio can't be derived (no current value on either side).
  Money? _nativeDelta({
    required Asset asset,
    required Currency base,
    required int currentBaseMinor,
    required int currentNativeMinor,
    required int deltaBaseMinor,
  }) {
    if (asset.currency == base) return null;
    if (currentBaseMinor == 0 || currentNativeMinor == 0) return null;
    final nativeMinor = (deltaBaseMinor * currentNativeMinor / currentBaseMinor)
        .round();
    return Money(nativeMinor, asset.currency);
  }
}
