import 'dart:math' as math;

/// Shifts `dueDate` by one calendar month, clamping the day to the
/// last valid day of the resulting month (Jan 31 → Feb 28/29).
///
/// Shared between the virtual projection (`ProjectVirtualMonthlyBillsUseCase`)
/// and lower-level callers that want a single month step. The settlement
/// flow uses `nextMonthlyDueDateAfter` instead — see its doc-comment for
/// why a single-step advance is wrong when the user pays a late bill.
DateTime nextMonthlyDueDate(DateTime dueDate) {
  final nextMonth = dueDate.month == 12 ? 1 : dueDate.month + 1;
  final nextYear = dueDate.month == 12 ? dueDate.year + 1 : dueDate.year;
  final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
  final day = math.min(dueDate.day, lastDay);
  return DateTime(nextYear, nextMonth, day);
}

/// Like [nextMonthlyDueDate] but advances by as many months as needed so
/// the resulting date is **not before** [today]. Preserves the original
/// day-of-month across iterations: each candidate clamps `baseDueDate.day`
/// to that month's last valid day, so a "monthly on day 31" chain still
/// lands on day 31 (or month-end) every step.
///
/// Used by the bill settlement flow. Why this matters: when the user pays
/// a monthly bill that was already overdue (e.g., due Apr 1, paid May 8),
/// a plain one-step advance would create the next occurrence at May 1 —
/// which is *also* in the past → the new bill is born overdue → the
/// daily Cloud Function notification fires the next morning → user pays
/// again → another born-overdue occurrence. The chain takes one settlement
/// per stale month to catch up. Fast-forwarding to the first dueDate
/// `>= today` collapses that to a single settlement.
///
/// Example (today = 2026-05-08):
/// - base Apr  1 → returns May  1 (still actionable today).
/// - base Mar  1 → returns Jun  1 (skips May  1 which is < today).
/// - base Jan 31 → returns May 31 (preserves day 31 each step).
/// - base May  8 → returns Jun  8 (no fast-forward needed).
/// - base May 15 (future) → returns Jun 15 (no fast-forward).
DateTime nextMonthlyDueDateAfter(DateTime baseDueDate, DateTime today) {
  final originalDay = baseDueDate.day;
  final todayStart = DateTime(today.year, today.month, today.day);
  var year = baseDueDate.year;
  var month = baseDueDate.month;
  while (true) {
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
    final day = math.min(originalDay, lastDayOfMonth(year, month));
    final candidate = DateTime(year, month, day);
    if (!candidate.isBefore(todayStart)) return candidate;
  }
}

/// Last valid day-of-month for the given year/month. Used when
/// propagating a `dueDate.day` change across a recurrent chain — each
/// subsequent occurrence keeps its own month/year and clamps the day.
int lastDayOfMonth(int year, int month) =>
    DateTime(year, month + 1, 0).day;

/// Clamps `day` to the valid range for the given year/month. Convenience
/// wrapper for the propagation logic.
int clampDayToMonth(int year, int month, int day) =>
    math.min(day, lastDayOfMonth(year, month));
