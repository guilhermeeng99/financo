import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/services/holding_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  const calc = HoldingCalculator();
  const usd = Currency.usd;

  test('single buy: quantity and cost basis (fees folded into avg cost)', () {
    final holdings = calc.derive([
      AssetTransactionFactory.buy(
        quantity: 8,
        unitPrice: Money.fromMajor(125, usd),
        fees: Money.fromMajor(40, usd),
      ),
    ]);

    expect(holdings, hasLength(1));
    final h = holdings.single;
    expect(h.quantity, 8);
    // (125*8 + 40 fees) / 8 = 130.00 per unit
    expect(h.avgCost, Money.fromMajor(130, usd));
    expect(h.investedCost, Money.fromMajor(1040, usd));
    expect(h.isClosed, isFalse);
  });

  test('two buys: weighted average cost', () {
    final holdings = calc.derive([
      AssetTransactionFactory.buy(
        id: 'b1',
        quantity: 5,
        unitPrice: Money.fromMajor(80, usd),
        date: DateTime(2024),
      ),
      AssetTransactionFactory.buy(
        id: 'b2',
        quantity: 15,
        unitPrice: Money.fromMajor(120, usd),
        date: DateTime(2024, 1, 2),
      ),
    ]);

    final h = holdings.single;
    expect(h.quantity, 20);
    expect(h.avgCost, Money.fromMajor(110, usd)); // (5*80 + 15*120) / 20
  });

  test('sell records realized P/L against average cost', () {
    final holdings = calc.derive([
      AssetTransactionFactory.buy(
        quantity: 8,
        unitPrice: Money.fromMajor(90, usd),
      ),
      AssetTransactionFactory.sell(
        quantity: 3,
        unitPrice: Money.fromMajor(140, usd),
      ),
    ]);

    final h = holdings.single;
    expect(h.quantity, 5);
    expect(h.avgCost, Money.fromMajor(90, usd));
    expect(h.realizedPL, Money.fromMajor(150, usd)); // (140-90)*3
  });

  test('dividends accumulate without changing quantity', () {
    final holdings = calc.derive([
      AssetTransactionFactory.buy(
        quantity: 8,
        unitPrice: Money.fromMajor(90, usd),
      ),
      AssetTransactionFactory.dividend(amount: Money.fromMajor(35, usd)),
    ]);

    final h = holdings.single;
    expect(h.quantity, 8);
    expect(h.dividends, Money.fromMajor(35, usd));
  });

  test('re-buy after a full close starts a fresh average cost', () {
    final holdings = calc.derive([
      AssetTransactionFactory.buy(
        id: 'b1',
        quantity: 8,
        unitPrice: Money.fromMajor(90, usd),
        date: DateTime(2024),
      ),
      AssetTransactionFactory.sell(
        id: 's1',
        quantity: 8,
        unitPrice: Money.fromMajor(140, usd),
        date: DateTime(2024, 2),
      ),
      AssetTransactionFactory.buy(
        id: 'b2',
        quantity: 5,
        unitPrice: Money.fromMajor(200, usd),
        date: DateTime(2024, 3),
      ),
    ]);

    final h = holdings.single;
    expect(h.quantity, 5);
    expect(h.avgCost, Money.fromMajor(200, usd)); // closed lot not blended
    expect(h.realizedPL, Money.fromMajor(400, usd)); // (140-90)*8
  });

  test('sell to exactly zero closes the position', () {
    final holdings = calc.derive([
      AssetTransactionFactory.buy(
        quantity: 7,
        unitPrice: Money.fromMajor(90, usd),
      ),
      AssetTransactionFactory.sell(
        quantity: 7,
        unitPrice: Money.fromMajor(110, usd),
      ),
    ]);

    expect(holdings.single.quantity, 0);
    expect(holdings.single.isClosed, isTrue);
  });

  test('groups by (asset, institution) into separate holdings', () {
    final holdings = calc.derive([
      AssetTransactionFactory.buy(assetId: 'a1', institutionId: 'i1'),
      AssetTransactionFactory.buy(assetId: 'a2', institutionId: 'i1'),
      AssetTransactionFactory.buy(assetId: 'a1', institutionId: 'i2'),
    ]);

    expect(holdings, hasLength(3));
  });
}
