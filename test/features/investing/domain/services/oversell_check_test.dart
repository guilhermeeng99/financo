import 'package:financo/features/investing/domain/services/oversell_check.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  test('buy then a smaller later sell does not oversell', () {
    // Factory defaults: buy 2024-01-10, sell 2024-02-10 (correct order).
    final oversells = oversellsTimeline([
      AssetTransactionFactory.buy(quantity: 8),
      AssetTransactionFactory.sell(quantity: 3),
    ]);
    expect(oversells, isFalse);
  });

  test('a sell with nothing held oversells', () {
    final oversells = oversellsTimeline([
      AssetTransactionFactory.sell(quantity: 1),
    ]);
    expect(oversells, isTrue);
  });

  test('selling more than held oversells', () {
    final oversells = oversellsTimeline([
      AssetTransactionFactory.buy(quantity: 3),
      AssetTransactionFactory.sell(quantity: 5),
    ]);
    expect(oversells, isTrue);
  });

  test('a backdated sell before its covering buy oversells', () {
    final oversells = oversellsTimeline([
      AssetTransactionFactory.buy(date: DateTime(2024, 2, 10)),
      AssetTransactionFactory.sell(date: DateTime(2024, 1, 10)),
    ]);
    expect(oversells, isTrue);
  });

  test('same-instant buy settles before sell (buy-before-sell tiebreak)', () {
    final at = DateTime(2024, 5, 5);
    final oversells = oversellsTimeline([
      AssetTransactionFactory.sell(date: at, createdAt: at),
      AssetTransactionFactory.buy(date: at, createdAt: at),
    ]);
    expect(oversells, isFalse);
  });

  test('dividends do not affect the quantity timeline', () {
    final oversells = oversellsTimeline([
      AssetTransactionFactory.buy(quantity: 5),
      AssetTransactionFactory.dividend(date: DateTime(2024, 1, 20)),
      AssetTransactionFactory.sell(quantity: 5),
    ]);
    expect(oversells, isFalse);
  });
}
