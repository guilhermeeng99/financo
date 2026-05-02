import 'dart:math' as math;

/// Shifts `dueDate` by one calendar month, clamping the day to the
/// last valid day of the resulting month (Jan 31 → Feb 28/29).
///
/// Shared between the settlement flow (which materializes the next
/// occurrence in `BillRepositoryImpl`) and the preview projection
/// (`ProjectVirtualMonthlyBillsUseCase`) so both stay aligned.
DateTime nextMonthlyDueDate(DateTime dueDate) {
  final nextMonth = dueDate.month == 12 ? 1 : dueDate.month + 1;
  final nextYear = dueDate.month == 12 ? dueDate.year + 1 : dueDate.year;
  final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
  final day = math.min(dueDate.day, lastDay);
  return DateTime(nextYear, nextMonth, day);
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
