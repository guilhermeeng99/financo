import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/services/fixed_income_cash_flows.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  const usd = Currency.usd;

  test('maps buys to positive and sells to negative flows, dividends out', () {
    final flows = buildFixedIncomeCashFlows([
      AssetTransactionFactory.buy(),
      AssetTransactionFactory.sell(),
      AssetTransactionFactory.dividend(),
    ]);

    expect(flows, hasLength(2));
    expect(flows.first.amount, Money.fromMajor(1000, usd)); // 100 * 10 buy
    expect(flows[1].amount, Money.fromMajor(-600, usd)); // -(150 * 4) sell
  });

  test('orders flows oldest-first', () {
    final flows = buildFixedIncomeCashFlows([
      AssetTransactionFactory.sell(date: DateTime(2024, 2, 10)),
      AssetTransactionFactory.buy(date: DateTime(2024, 1, 10)),
    ]);

    expect(flows.first.date.isBefore(flows[1].date), isTrue);
  });
}
