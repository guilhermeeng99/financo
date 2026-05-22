import 'package:financo/core/utils/date_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('startOfMonth', () {
    test('returns midnight on the first of the month', () {
      expect(startOfMonth(DateTime(2026, 5, 22, 14, 30)), DateTime(2026, 5));
    });
  });

  group('endOfMonth', () {
    test('returns the last millisecond of the month', () {
      expect(
        endOfMonth(DateTime(2026, 5, 10)),
        DateTime(2026, 5, 31, 23, 59, 59, 999),
      );
    });

    test('handles February in a leap year', () {
      expect(
        endOfMonth(DateTime(2024, 2)),
        DateTime(2024, 2, 29, 23, 59, 59, 999),
      );
    });

    test('handles December roll-over', () {
      expect(
        endOfMonth(DateTime(2026, 12, 5)),
        DateTime(2026, 12, 31, 23, 59, 59, 999),
      );
    });
  });

  group('isSameMonth', () {
    test('true for same year and month, different day', () {
      expect(isSameMonth(DateTime(2026, 5), DateTime(2026, 5, 31)), isTrue);
    });

    test('false across month or year boundary', () {
      expect(isSameMonth(DateTime(2026, 5, 31), DateTime(2026, 6)), isFalse);
      expect(isSameMonth(DateTime(2025, 5), DateTime(2026, 5)), isFalse);
    });
  });

  group('isSameDay', () {
    test('true for same calendar day, different time', () {
      expect(
        isSameDay(DateTime(2026, 5, 22, 9), DateTime(2026, 5, 22, 23)),
        isTrue,
      );
    });

    test('false for different day', () {
      expect(isSameDay(DateTime(2026, 5, 22), DateTime(2026, 5, 23)), isFalse);
    });
  });
}
