import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/allocation_overview.dart';
import 'package:financo/features/investing/domain/services/allocation_metadata.dart';
import 'package:financo/features/investing/domain/services/allocation_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  const service = AllocationService();
  const brl = Currency.brl;

  // Two buckets, 60/40. Two assets linked to them; a stock worth R$600 and a
  // bond worth R$400 → perfectly on target.
  final stocksClass = AllocationClassFactory.root(id: 'c-stocks');
  final bondsClass = AllocationClassFactory.root(
    id: 'c-bonds',
    name: 'Bonds',
    targetPercent: 40,
  );

  test('on-target portfolio yields no rebalance actions', () {
    final assets = [
      AssetFactory.stockUs(
        id: 'a-stock',
        metadata: AllocationMetadata.write(const {}, 'c-stocks'),
      ),
      AssetFactory.stockUs(
        id: 'a-bond',
        metadata: AllocationMetadata.write(const {}, 'c-bonds'),
      ),
    ];
    final holdings = [
      HoldingValuationFactory.base(
        assetId: 'a-stock',
        marketValueBase: Money.fromMajor(600, brl),
      ),
      HoldingValuationFactory.base(
        assetId: 'a-bond',
        marketValueBase: Money.fromMajor(400, brl),
      ),
    ];

    final overview = service.compute(
      classes: [stocksClass, bondsClass],
      assets: assets,
      holdings: holdings,
      base: brl,
    );

    expect(overview.totalValue, Money.fromMajor(1000, brl));
    expect(overview.allocatedValue, Money.fromMajor(1000, brl));
    expect(overview.unallocatedValue, const Money.zero(brl));
    expect(overview.rebalanceActions, isEmpty);
    expect(overview.targetsBalanced, isTrue);
    // Slices sorted by current value desc → Stocks first.
    expect(overview.slices.first.classId, 'c-stocks');
    expect(overview.slices.first.currentPercent, closeTo(0.6, 1e-9));
  });

  test('under/over target produces buy and sell actions', () {
    // Stocks R$800 (target 60% = 600 → sell 200), Bonds R$200 (target 40% =
    // 400 → buy 200).
    final assets = [
      AssetFactory.stockUs(
        id: 'a-stock',
        metadata: AllocationMetadata.write(const {}, 'c-stocks'),
      ),
      AssetFactory.stockUs(
        id: 'a-bond',
        metadata: AllocationMetadata.write(const {}, 'c-bonds'),
      ),
    ];
    final holdings = [
      HoldingValuationFactory.base(
        assetId: 'a-stock',
        marketValueBase: Money.fromMajor(800, brl),
      ),
      HoldingValuationFactory.base(
        assetId: 'a-bond',
        marketValueBase: Money.fromMajor(200, brl),
      ),
    ];

    final overview = service.compute(
      classes: [stocksClass, bondsClass],
      assets: assets,
      holdings: holdings,
      base: brl,
    );

    expect(overview.rebalanceActions, hasLength(2));
    final sell = overview.rebalanceActions.firstWhere(
      (a) => a.direction == RebalanceDirection.sell,
    );
    final buy = overview.rebalanceActions.firstWhere(
      (a) => a.direction == RebalanceDirection.buy,
    );
    expect(sell.classId, 'c-stocks');
    expect(sell.amount, Money.fromMajor(200, brl));
    expect(buy.classId, 'c-bonds');
    expect(buy.amount, Money.fromMajor(200, brl));
  });

  test('assets without a known class fall into unallocated', () {
    final assets = [
      AssetFactory.stockUs(
        id: 'a-stock',
        metadata: AllocationMetadata.write(const {}, 'c-stocks'),
      ),
      // No allocationClassId → unallocated.
      AssetFactory.stockUs(id: 'a-loose'),
      // Points at a class that no longer exists → also unallocated.
      AssetFactory.stockUs(
        id: 'a-ghost',
        metadata: AllocationMetadata.write(const {}, 'c-deleted'),
      ),
    ];
    final holdings = [
      HoldingValuationFactory.base(
        assetId: 'a-stock',
        marketValueBase: Money.fromMajor(600, brl),
      ),
      HoldingValuationFactory.base(
        assetId: 'a-loose',
        marketValueBase: Money.fromMajor(300, brl),
      ),
      HoldingValuationFactory.base(
        assetId: 'a-ghost',
        marketValueBase: Money.fromMajor(100, brl),
      ),
    ];

    final overview = service.compute(
      classes: [stocksClass, bondsClass],
      assets: assets,
      holdings: holdings,
      base: brl,
    );

    expect(overview.totalValue, Money.fromMajor(1000, brl));
    expect(overview.allocatedValue, Money.fromMajor(600, brl));
    expect(overview.unallocatedValue, Money.fromMajor(400, brl));
    expect(overview.hasUnallocated, isTrue);
  });

  test('fx-missing holdings are excluded from every total', () {
    final assets = [
      AssetFactory.stockUs(
        id: 'a-stock',
        metadata: AllocationMetadata.write(const {}, 'c-stocks'),
      ),
    ];
    final holdings = [
      HoldingValuationFactory.base(
        assetId: 'a-stock',
        marketValueBase: Money.fromMajor(600, brl),
      ),
      HoldingValuationFactory.base(
        assetId: 'a-stock',
        marketValueBase: Money.fromMajor(999, brl),
        fxMissing: true,
      ),
    ];

    final overview = service.compute(
      classes: [stocksClass],
      assets: assets,
      holdings: holdings,
      base: brl,
    );

    expect(overview.totalValue, Money.fromMajor(600, brl));
  });

  test('subclass value rolls up into its root', () {
    final sub = AllocationClassFactory.root(
      id: 'c-sub',
      name: 'US Stocks',
      targetPercent: 0,
      parentId: 'c-stocks',
    );
    final assets = [
      AssetFactory.stockUs(
        id: 'a-sub',
        metadata: AllocationMetadata.write(const {}, 'c-sub'),
      ),
    ];
    final holdings = [
      HoldingValuationFactory.base(
        assetId: 'a-sub',
        marketValueBase: Money.fromMajor(600, brl),
      ),
    ];

    final overview = service.compute(
      classes: [stocksClass, sub],
      assets: assets,
      holdings: holdings,
      base: brl,
    );

    final root = overview.slices.firstWhere((s) => s.classId == 'c-stocks');
    expect(root.currentValue, Money.fromMajor(600, brl));
    expect(overview.unallocatedValue, const Money.zero(brl));
  });

  test('empty portfolio is safe (no div-by-zero)', () {
    final overview = service.compute(
      classes: [stocksClass],
      assets: const [],
      holdings: const [],
      base: brl,
    );

    expect(overview.totalValue, const Money.zero(brl));
    expect(overview.slices.single.currentPercent, 0);
    expect(overview.rebalanceActions, isEmpty);
  });
}
