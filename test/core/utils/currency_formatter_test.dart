import 'package:financo/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // intl's pt_BR currency pattern separates the symbol from the value with
  // a non-breaking space (U+00A0) — a regular space would not match.
  const nbsp = ' ';

  group('formatCurrency', () {
    test('formats a positive value with comma decimals', () {
      expect(formatCurrency(1234.56), 'R\$$nbsp${'1.234,56'}');
    });

    test('formats a negative value with a leading minus', () {
      expect(formatCurrency(-1234.56), '-R\$$nbsp${'1.234,56'}');
    });

    test('formats zero with two decimal places', () {
      expect(formatCurrency(0), 'R\$${nbsp}0,00');
    });

    test('rounds half-up at the cent boundary', () {
      expect(formatCurrency(0.005), 'R\$${nbsp}0,01');
      expect(formatCurrency(0.004), 'R\$${nbsp}0,00');
    });

    test('groups thousands with dots', () {
      expect(formatCurrency(1000000), 'R\$$nbsp${'1.000.000,00'}');
    });

    test('pads sub-real values with a leading zero', () {
      expect(formatCurrency(12.5), 'R\$$nbsp${'12,50'}');
    });
  });
}
