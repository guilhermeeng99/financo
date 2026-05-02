import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrlCurrencyInputFormatter.format', () {
    test('formats integer reais with two decimals', () {
      expect(BrlCurrencyInputFormatter.format(2000), '2.000,00');
    });

    test('formats fractional reais with cents', () {
      expect(BrlCurrencyInputFormatter.format(12.5), '12,50');
    });

    test('formats sub-real values', () {
      expect(BrlCurrencyInputFormatter.format(0.05), '0,05');
    });

    test('handles thousands grouping past 1k', () {
      expect(BrlCurrencyInputFormatter.format(1234567.89), '1.234.567,89');
    });
  });

  group('BrlCurrencyInputFormatter.formatEditUpdate', () {
    final formatter = BrlCurrencyInputFormatter();

    TextEditingValue update(String text) => formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: text),
    );

    test('returns empty when nothing was typed', () {
      expect(update('').text, '');
    });

    test('cents-style: a single digit is treated as 0,0X', () {
      expect(update('5').text, '0,05');
    });

    test('200000 typed digits format as 2.000,00', () {
      expect(update('200000').text, '2.000,00');
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
