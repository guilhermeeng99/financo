import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/holding.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:financo/features/investing/domain/services/portfolio_inputs_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  const builder = PortfolioInputsBuilder();
  const usd = Currency.usd;

  Holding usdHolding() => Holding(
    assetId: 'asset-aapl',
    institutionId: 'inst-avenue',
    quantity: 10,
    avgCost: Money.fromMajor(100, usd),
    realizedPL: const Money.zero(usd),
    dividends: const Money.zero(usd),
  );

  test('assigns the FX rate for a foreign holding whose rate is loaded', () {
    final inputs = builder.build(
      holdings: [usdHolding()],
      assetsById: {'asset-aapl': AssetFactory.stockUs()},
      transactions: const [],
      quotesById: const {},
      indexSeries: const {},
      fxToBaseRates: const {usd: 5},
    );

    expect(inputs, hasLength(1));
    expect(inputs.first.fxToBase, 5);
  });

  test('passes a null FX when the currency has no loaded rate', () {
    final inputs = builder.build(
      holdings: [usdHolding()],
      assetsById: {'asset-aapl': AssetFactory.stockUs()},
      transactions: const [],
      quotesById: const {},
      indexSeries: const {},
      fxToBaseRates: const {},
    );

    expect(inputs.first.fxToBase, isNull);
  });

  test('heldAssetIds includes open positions and fixed-income assets', () {
    final fi = AssetFactory.stockBr(
      id: 'fi-1',
      metadata: const {'fiBasis': 'cdi', 'fiRate': '100'},
    ).copyWith(kind: AssetKind.fixedIncome);
    final open = usdHolding();
    const closed = Holding(
      assetId: 'fi-1',
      institutionId: 'inst-nubank',
      quantity: 0,
      avgCost: Money.zero(Currency.brl),
      realizedPL: Money.zero(Currency.brl),
      dividends: Money.zero(Currency.brl),
    );

    final ids = builder.heldAssetIds(
      [open, closed],
      [AssetFactory.stockUs(), fi],
      [
        AssetTransactionFactory.buy(
          assetId: 'fi-1',
          institutionId: 'inst-nubank',
        ),
      ],
    );

    expect(ids, contains('asset-aapl')); // open position
    expect(ids, contains('fi-1')); // fixed income, even at qty 0
  });

  test('earliestIndexDates picks the oldest buy per index', () {
    final fi = AssetFactory.stockBr(
      id: 'fi-1',
      metadata: const {'fiBasis': 'cdi', 'fiRate': '100'},
    ).copyWith(kind: AssetKind.fixedIncome);

    final dates = builder.earliestIndexDates(
      [fi],
      [
        AssetTransactionFactory.buy(
          assetId: 'fi-1',
          date: DateTime(2024, 3),
        ),
        AssetTransactionFactory.buy(
          id: 'b2',
          assetId: 'fi-1',
          date: DateTime(2024),
        ),
      ],
    );

    expect(dates[EconomicIndex.cdi], DateTime(2024));
  });
}
