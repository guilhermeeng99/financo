import 'package:financo/features/bills/domain/utils/monthly_due_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextMonthlyDueDate', () {
    test('advances by one calendar month, preserving the day', () {
      expect(
        nextMonthlyDueDate(DateTime(2026, 5)),
        DateTime(2026, 6),
      );
      expect(
        nextMonthlyDueDate(DateTime(2026, 5, 15)),
        DateTime(2026, 6, 15),
      );
    });

    test('clamps to the last valid day when the next month is shorter', () {
      // Jan 31 → Feb 28 (2026 is not a leap year).
      expect(
        nextMonthlyDueDate(DateTime(2026, 1, 31)),
        DateTime(2026, 2, 28),
      );
      // Jan 31 → Feb 29 (2024 is a leap year).
      expect(
        nextMonthlyDueDate(DateTime(2024, 1, 31)),
        DateTime(2024, 2, 29),
      );
      // May 31 → Jun 30.
      expect(
        nextMonthlyDueDate(DateTime(2026, 5, 31)),
        DateTime(2026, 6, 30),
      );
    });

    test('rolls into the next year when stepping out of December', () {
      expect(
        nextMonthlyDueDate(DateTime(2026, 12, 15)),
        DateTime(2027, 1, 15),
      );
    });
  });

  group('nextMonthlyDueDateAfter', () {
    test(
      'returns next month when one-step advance is already after today',
      () {
        // base = today's month, day 1. Next month = first of next month
        // → strictly after today, no fast-forward needed.
        expect(
          nextMonthlyDueDateAfter(
            DateTime(2026, 5),
            DateTime(2026, 5, 8),
          ),
          DateTime(2026, 6),
        );
      },
    );

    test('returns the same-day next month when paying on time', () {
      // User pays a May 8 bill on May 8 → next is exactly Jun 8.
      expect(
        nextMonthlyDueDateAfter(
          DateTime(2026, 5, 8),
          DateTime(2026, 5, 8),
        ),
        DateTime(2026, 6, 8),
      );
    });

    test('skips months that would land in the past', () {
      // Original Apr 1, paid May 8 — May 1 would be born overdue → skip.
      expect(
        nextMonthlyDueDateAfter(
          DateTime(2026, 4),
          DateTime(2026, 5, 8),
        ),
        DateTime(2026, 6),
      );
      // Original Mar 1, paid May 8 — both Apr 1 and May 1 are past → skip.
      expect(
        nextMonthlyDueDateAfter(
          DateTime(2026, 3),
          DateTime(2026, 5, 8),
        ),
        DateTime(2026, 6),
      );
    });

    test('preserves day-of-month preference across fast-forwarded months',
        () {
      // base = Jan 31, today = May 8 → fast-forward through
      // Feb 28 (clamped), Mar 31, Apr 30 (clamped), all in the past →
      // land on May 31 (clamped from 31, still 31). The day-31 preference
      // would be lost if we iterated nextMonthlyDueDate naively.
      expect(
        nextMonthlyDueDateAfter(
          DateTime(2026, 1, 31),
          DateTime(2026, 5, 8),
        ),
        DateTime(2026, 5, 31),
      );
    });

    test('treats today exactly as not-before (does not fast-forward)', () {
      // If the candidate equals startOfToday, the bill is "due today" —
      // that's an actionable, expected state. No need to skip another month.
      expect(
        nextMonthlyDueDateAfter(
          DateTime(2026, 4, 8),
          DateTime(2026, 5, 8),
        ),
        DateTime(2026, 5, 8),
      );
    });

    test('rolls year forward when fast-forwarding across December', () {
      // base = Oct 15, today = Feb 1 of the following year → next valid
      // candidate is Mar 15.
      expect(
        nextMonthlyDueDateAfter(
          DateTime(2025, 10, 15),
          DateTime(2026, 2),
        ),
        DateTime(2026, 2, 15),
      );
    });

    test('handles base dueDate strictly in the future without fast-forward',
        () {
      // User pays early — base is already in the future relative to today.
      expect(
        nextMonthlyDueDateAfter(
          DateTime(2026, 5, 15),
          DateTime(2026, 5, 8),
        ),
        DateTime(2026, 6, 15),
      );
    });
  });

  group('lastDayOfMonth / clampDayToMonth', () {
    test('lastDayOfMonth returns the right day for each month', () {
      expect(lastDayOfMonth(2026, 1), 31);
      expect(lastDayOfMonth(2026, 2), 28);
      expect(lastDayOfMonth(2024, 2), 29);
      expect(lastDayOfMonth(2026, 4), 30);
      expect(lastDayOfMonth(2026, 12), 31);
    });

    test('clampDayToMonth caps the day at the month-end', () {
      expect(clampDayToMonth(2026, 2, 31), 28);
      expect(clampDayToMonth(2026, 5, 15), 15);
      expect(clampDayToMonth(2024, 2, 31), 29);
    });
  });
}
