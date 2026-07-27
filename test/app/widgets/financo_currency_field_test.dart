import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/core/money/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyInputFormatter.format', () {
    test('formats BRL integers with two decimals', () {
      expect(CurrencyInputFormatter.format(2000), '2.000,00');
    });

    test('formats fractional BRL with cents', () {
      expect(CurrencyInputFormatter.format(12.5), '12,50');
    });

    test('formats sub-unit BRL values', () {
      expect(CurrencyInputFormatter.format(0.05), '0,05');
    });

    test('handles thousands grouping past 1k', () {
      expect(CurrencyInputFormatter.format(1234567.89), '1.234.567,89');
    });

    test('formats USD in en_US style (comma grouping, dot decimal)', () {
      expect(CurrencyInputFormatter.format(1234.5, Currency.usd), '1,234.50');
    });

    test('formats EUR in de_DE style (dot grouping, comma decimal)', () {
      expect(CurrencyInputFormatter.format(1234.5, Currency.eur), '1.234,50');
    });
  });

  group('CurrencyInputFormatter.formatEditUpdate', () {
    TextEditingValue update(String text, [Currency currency = Currency.brl]) =>
        CurrencyInputFormatter(currency).formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: text),
        );

    test('returns empty when nothing was typed', () {
      expect(update('').text, '');
    });

    test('cents-style: a single digit is treated as 0,0X (BRL)', () {
      expect(update('5').text, '0,05');
    });

    test('200000 typed digits format as 2.000,00 (BRL)', () {
      expect(update('200000').text, '2.000,00');
    });

    test('same digits format as 2,000.00 under USD', () {
      expect(update('200000', Currency.usd).text, '2,000.00');
    });

    test('strips non-digits before formatting', () {
      expect(update(r'R$ 200000').text, '2.000,00');
      // Already-formatted text is idempotent.
      expect(update('2.000,00').text, '2.000,00');
    });

    test('cursor sits at end of formatted text', () {
      final value = update('200000');
      expect(value.selection.baseOffset, value.text.length);
      expect(value.selection.extentOffset, value.text.length);
    });

    test('extreme inputs are clamped, not thrown', () {
      // Pasting a 50-digit string used to overflow int.parse — clamped
      // to 15 digits so the field stays alive.
      final long = '9' * 50;
      expect(() => update(long), returnsNormally);
    });
  });
}
