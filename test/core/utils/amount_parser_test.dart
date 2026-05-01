import 'package:financo/core/utils/amount_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDecimalAmount', () {
    test('parses Brazilian negative decimal', () {
      expect(parseDecimalAmount('-431,72'), -431.72);
    });

    test('parses Brazilian decimal with thousands grouper', () {
      expect(parseDecimalAmount('1.234,56'), closeTo(1234.56, 0.001));
    });

    test('parses English decimal as-is', () {
      expect(parseDecimalAmount('421.95'), closeTo(421.95, 0.001));
    });

    test('parses English decimal with thousands grouper', () {
      expect(parseDecimalAmount('1,234.56'), closeTo(1234.56, 0.001));
    });

    test('parses bare integer', () {
      expect(parseDecimalAmount('100'), 100.0);
    });

    test('preserves leading minus sign', () {
      expect(parseDecimalAmount('-100'), -100.0);
      expect(parseDecimalAmount('-100.50'), closeTo(-100.50, 0.001));
    });

    test('strips wrapping quotes', () {
      expect(parseDecimalAmount('"-9,99"'), closeTo(-9.99, 0.001));
    });

    test('returns null for empty input', () {
      expect(parseDecimalAmount(''), isNull);
      expect(parseDecimalAmount('   '), isNull);
    });

    test('returns null for non-numeric input', () {
      expect(parseDecimalAmount('abc'), isNull);
      expect(parseDecimalAmount('--1'), isNull);
    });
  });
}
