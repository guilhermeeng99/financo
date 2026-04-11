import 'package:intl/intl.dart';

final _dayMonthYear = DateFormat('dd/MM/yyyy');
final _monthYear = DateFormat('MMMM yyyy');
final _dayMonth = DateFormat('dd MMM');
final _time = DateFormat('HH:mm');

String formatDate(DateTime date) => _dayMonthYear.format(date);

String formatMonthYear(DateTime date) => _monthYear.format(date);

String formatDayMonth(DateTime date) => _dayMonth.format(date);

String formatTime(DateTime date) => _time.format(date);

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
