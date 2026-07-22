import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('fromMajor rounds to the nearest cent', () {
      expect(Money.fromMajor(10.50, Currency.brl).minorUnits, 1050);
      expect(Money.fromMajor(10.005, Currency.brl).minorUnits, 1001);
      expect(Money.fromMajor(10.004, Currency.brl).minorUnits, 1000);
    });

    test('major converts minor units back to major units', () {
      expect(const Money(1051, Currency.brl).major, 10.51);
    });

    test('zero / isZero / isNegative', () {
      expect(const Money.zero(Currency.usd).minorUnits, 0);
      expect(const Money.zero(Currency.usd).isZero, isTrue);
      expect(const Money(-1, Currency.brl).isNegative, isTrue);
      expect(const Money(1, Currency.brl).isNegative, isFalse);
    });

    test('addition and subtraction on the same currency', () {
      const a = Money(1000, Currency.brl);
      const b = Money(250, Currency.brl);
      expect(a + b, const Money(1250, Currency.brl));
      expect(a - b, const Money(750, Currency.brl));
    });

    test('multiplication scales and rounds to the nearest cent', () {
      expect(
        const Money(1050, Currency.brl) * 3,
        const Money(3150, Currency.brl),
      );
      // 333 * 1.5 = 499.5 → rounds to 500
      expect(
        const Money(333, Currency.brl) * 1.5,
        const Money(500, Currency.brl),
      );
    });

    test('combining different currencies throws (loud, release too)', () {
      const brl = Money(1000, Currency.brl);
      const usd = Money(1000, Currency.usd);
      expect(() => brl + usd, throwsArgumentError);
      expect(() => brl - usd, throwsArgumentError);
    });

    test('equality is value-based (Equatable)', () {
      expect(const Money(500, Currency.brl), const Money(500, Currency.brl));
      expect(
        const Money(500, Currency.brl) == const Money(500, Currency.usd),
        isFalse,
      );
    });

    test('toString shows code and 2 decimals', () {
      expect(const Money(1051, Currency.brl).toString(), 'BRL 10.51');
    });
  });

  group('formatMoney', () {
    test('formats each currency with its own symbol and separators', () {
      final brl = formatMoney(Money.fromMajor(1234.56, Currency.brl));
      expect(brl, contains(r'R$'));
      expect(brl, contains('1.234,56'));

      final usd = formatMoney(Money.fromMajor(1234.56, Currency.usd));
      expect(usd, contains(r'$'));
      expect(usd, contains('1,234.56'));

      final eur = formatMoney(Money.fromMajor(1234.56, Currency.eur));
      expect(eur, contains('€'));
      expect(eur, contains('1.234,56'));
    });
  });
}
