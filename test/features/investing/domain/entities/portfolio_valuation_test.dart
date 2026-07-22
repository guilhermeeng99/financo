import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/holding_valuation.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brl = Currency.brl;
  const usd = Currency.usd;

  HoldingValuation valued({
    required String institutionId,
    required AssetKind kind,
    required Money base,
    required Money native,
    bool fxMissing = false,
  }) {
    return HoldingValuation(
      assetId: 'a-$institutionId',
      institutionId: institutionId,
      assetKind: kind,
      quantity: 1,
      marketValueBase: base,
      marketValueNative: native,
      investedBase: base,
      unrealizedPL: const Money.zero(brl),
      totalPL: const Money.zero(brl),
      returnPct: 0,
      dayChangeBase: const Money.zero(brl),
      priceStale: false,
      fxMissing: fxMissing,
    );
  }

  final priced = valued(
    institutionId: 'i1',
    kind: AssetKind.stockBr,
    base: Money.fromMajor(1000, brl),
    native: Money.fromMajor(1000, brl),
  );
  final foreign = valued(
    institutionId: 'i2',
    kind: AssetKind.stockUs,
    base: const Money.zero(brl),
    native: Money.fromMajor(500, usd),
    fxMissing: true,
  );

  test('base totals and allocations exclude FX-missing holdings', () {
    final p = PortfolioValuation.fromHoldings([priced, foreign], brl);

    expect(p.totalValueBase, Money.fromMajor(1000, brl));
    expect(p.byClass[AssetKind.stockBr], Money.fromMajor(1000, brl));
    expect(p.byClass.containsKey(AssetKind.stockUs), isFalse);
    expect(p.byInstitution['i1'], Money.fromMajor(1000, brl));
    expect(p.byInstitution.containsKey('i2'), isFalse);
  });

  test('byCurrency includes the native subtotal of FX-missing holdings', () {
    final p = PortfolioValuation.fromHoldings([priced, foreign], brl);

    expect(p.byCurrency[brl], Money.fromMajor(1000, brl));
    expect(p.byCurrency[usd], Money.fromMajor(500, usd));
  });

  test('forInstitution narrows to the matching holdings', () {
    final p = PortfolioValuation.fromHoldings([priced, foreign], brl);

    final only = p.forInstitution('i1');
    expect(only.holdings, hasLength(1));
    expect(only.totalValueBase, Money.fromMajor(1000, brl));
  });

  test('empty portfolio is zeroed', () {
    final p = PortfolioValuation.empty();
    expect(p.totalValueBase, const Money.zero(brl));
    expect(p.holdings, isEmpty);
  });
}
