import 'package:financo/core/utils/csv_parsing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('readCsvCell', () {
    test('trims the cell at the given index', () {
      expect(readCsvCell(['  hi  ', 'x'], 0), 'hi');
    });

    test('returns empty string for null index', () {
      expect(readCsvCell(['a'], null), '');
    });

    test('returns empty string when index is out of range', () {
      expect(readCsvCell(['a'], 5), '');
    });

    test('coerces a null cell to empty string', () {
      expect(readCsvCell([null, 'b'], 0), '');
    });

    test('stringifies non-string cells', () {
      expect(readCsvCell([42], 0), '42');
    });
  });

  group('parseCsvAmount', () {
    test('parses Brazilian format (1.234,56)', () {
      expect(parseCsvAmount('1.234,56'), 1234.56);
    });

    test('parses English format (1,234.56)', () {
      expect(parseCsvAmount('1,234.56'), 1234.56);
    });

    test('returns 0 for blank or garbage', () {
      expect(parseCsvAmount(''), 0);
      expect(parseCsvAmount('abc'), 0);
    });

    test('keeps the sign by default', () {
      expect(parseCsvAmount('-431,72'), -431.72);
    });

    test('absolute: true strips the sign', () {
      expect(parseCsvAmount('-431,72', absolute: true), 431.72);
    });
  });

  group('parseDmyDate', () {
    test('parses a DD/MM/YYYY cell', () {
      expect(parseDmyDate('01/05/2026'), DateTime(2026, 5));
    });

    test('returns null when the part count is wrong', () {
      expect(parseDmyDate('2026-05-01'), isNull);
    });

    test('returns null for out-of-range month/day', () {
      expect(parseDmyDate('01/13/2026'), isNull);
      expect(parseDmyDate('32/01/2026'), isNull);
    });

    test('returns null for non-numeric parts', () {
      expect(parseDmyDate('aa/bb/cccc'), isNull);
    });
  });
}
