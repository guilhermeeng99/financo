import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brl = Currency.brl;

  // Compared against formatMoney() rather than hard-coded symbol strings so the
  // locale's exact currency spacing/sign placement can't make the test brittle.
  group('signedMoney', () {
    test('prefixes a plus on positives', () {
      final money = Money.fromMajor(10, brl);
      expect(signedMoney(money), '+${formatMoney(money)}');
    });

    test('leaves negatives as the formatter prints them', () {
      final money = Money.fromMajor(-10, brl);
      expect(signedMoney(money), formatMoney(money));
    });

    test('leaves zero unsigned', () {
      const money = Money.zero(brl);
      expect(signedMoney(money), formatMoney(money));
    });
  });

  group('absMoney', () {
    test('drops the sign', () {
      final positive = Money.fromMajor(10, brl);
      expect(absMoney(Money.fromMajor(-10, brl)), formatMoney(positive));
      expect(absMoney(positive), formatMoney(positive));
    });
  });

  group('signedPercent', () {
    test('signs positive and negative ratios, two decimals', () {
      expect(signedPercent(0.0957), '+9.57%');
      expect(signedPercent(-0.05), '-5.00%');
      expect(signedPercent(0), '0.00%');
    });
  });

  group('percentFraction', () {
    test('one-decimal percent from a fraction', () {
      expect(percentFraction(0.451), '45.1%');
      expect(percentFraction(0.2), '20.0%');
    });
  });
}
