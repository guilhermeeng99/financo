import 'package:app_widgets/app_widgets.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

enum DatePeriodType { daily, weekly, monthly, quarterly, semester, custom }

extension DatePeriodTypeExtension on DatePeriodType {
  String getName(BuildContext context) {
    switch (this) {
      case DatePeriodType.daily:
        return context.t.common.period_types.daily;
      case DatePeriodType.weekly:
        return context.t.common.period_types.weekly;
      case DatePeriodType.monthly:
        return context.t.common.period_types.monthly;
      case DatePeriodType.quarterly:
        return context.t.common.period_types.quarterly;
      case DatePeriodType.semester:
        return context.t.common.period_types.semester;
      case DatePeriodType.custom:
        return context.t.common.period_types.custom;
    }
  }
}

class DateFilter {
  const DateFilter({
    required this.date,
    required this.period,
    this.startDate,
    this.endDate,
  });

  final DateTime date;
  final DatePeriodType period;
  final DateTime? startDate;
  final DateTime? endDate;

  DateFilter copyWith({
    DateTime? date,
    DatePeriodType? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateFilter(
      date: date ?? this.date,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

DateFilterBloc get dateFilterBloc => Modular.get<DateFilterBloc>();

class DateFilterBloc extends GetxController {
  final Rx<DateFilter> _current = DateFilter(
    date: DateTime.now(),
    period: DatePeriodType.monthly,
  ).obs;

  DateFilter get current => _current.value;

  DateTime get currentDate => _current.value.date;

  DatePeriodType get currentPeriod => _current.value.period;

  Rx<DateFilter> get selected => _current;

  Rx<DateFilter> get selectedDate => _current;

  Rx<DateFilter> get selectedPeriod => _current;

  set currentDate(DateTime newDate) {
    _current.value = _current.value.copyWith(date: newDate);
  }

  set currentPeriod(DatePeriodType newPeriod) {
    if (newPeriod == DatePeriodType.custom) {
      return;
    }
    _current.value = _current.value.copyWith(period: newPeriod);
  }

  Future<void> selectCustomPeriod(BuildContext context) async {
    await openCustomCalendarDialog(context);
  }

  void setCustomPeriod(DateTime? startDate, DateTime? endDate) {
    _current.value = _current.value.copyWith(
      period: DatePeriodType.custom,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> openCustomCalendarDialog(BuildContext context) async {
    final results = await CustomCalendarDialog.show(
      context,
      initialDates: [
        current.startDate ?? DateTime.now(),
        current.endDate ?? DateTime.now(),
      ],
      calendarType: CalendarDatePicker2Type.range,
    );

    if (results != null && results.length >= 2) {
      final startDate = results[0];
      final endDate = results[1];

      if (startDate != null && endDate != null) {
        setCustomPeriod(startDate, endDate);
      } else if (startDate != null) {
        setCustomPeriod(startDate, startDate);
      }
    }
  }

  bool isTransactionInSelectedMonth(DateTime transactionDate) {
    if (currentPeriod == DatePeriodType.custom) {
      final start = startOfPeriod;
      final end = endOfPeriod;
      return transactionDate.isAfter(start.subtract(const Duration(days: 1))) &&
          transactionDate.isBefore(end.add(const Duration(days: 1)));
    }
    return transactionDate.year == currentDate.year &&
        transactionDate.month == currentDate.month;
  }

  DateTime get startOfPeriod {
    final date = currentDate;
    switch (currentPeriod) {
      case DatePeriodType.daily:
        return DateTime(date.year, date.month, date.day);
      case DatePeriodType.weekly:
        final weekday = date.weekday;
        return date.subtract(Duration(days: weekday - 1));
      case DatePeriodType.monthly:
        return DateTime(date.year, date.month);
      case DatePeriodType.quarterly:
        final quarterMonth = ((date.month - 1) ~/ 3) * 3 + 1;
        return DateTime(date.year, quarterMonth);
      case DatePeriodType.semester:
        final semesterMonth = date.month <= 6 ? 1 : 7;
        return DateTime(date.year, semesterMonth);
      case DatePeriodType.custom:
        return current.startDate ?? DateTime(date.year, date.month, date.day);
    }
  }

  DateTime get endOfPeriod {
    final date = currentDate;
    switch (currentPeriod) {
      case DatePeriodType.daily:
        return DateTime(date.year, date.month, date.day, 23, 59, 59);
      case DatePeriodType.weekly:
        final weekday = date.weekday;
        final endOfWeek = date.add(Duration(days: 7 - weekday));
        return DateTime(
          endOfWeek.year,
          endOfWeek.month,
          endOfWeek.day,
          23,
          59,
          59,
        );
      case DatePeriodType.monthly:
        return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
      case DatePeriodType.quarterly:
        final quarterMonth = ((date.month - 1) ~/ 3) * 3 + 4;
        return DateTime(date.year, quarterMonth, 0, 23, 59, 59);
      case DatePeriodType.semester:
        final semesterEndMonth = date.month <= 6 ? 7 : 13;
        return DateTime(date.year, semesterEndMonth, 0, 23, 59, 59);
      case DatePeriodType.custom:
        final endDate =
            current.endDate ??
            DateTime(date.year, date.month, date.day, 23, 59, 59);
        return DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    }
  }

  DateTime get startOfMonth {
    final date = currentDate;
    return DateTime(date.year, date.month);
  }

  DateTime get endOfMonth {
    final date = currentDate;
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  void navigateToPrevious() {
    final date = currentDate;
    switch (currentPeriod) {
      case DatePeriodType.daily:
        currentDate = date.subtract(const Duration(days: 1));
      case DatePeriodType.weekly:
        currentDate = date.subtract(const Duration(days: 7));
      case DatePeriodType.monthly:
        currentDate = DateTime(date.year, date.month - 1, date.day);
      case DatePeriodType.quarterly:
        currentDate = DateTime(date.year, date.month - 3, date.day);
      case DatePeriodType.semester:
        currentDate = DateTime(date.year, date.month - 6, date.day);
      case DatePeriodType.custom:
        break;
    }
  }

  void navigateToNext() {
    final date = currentDate;
    switch (currentPeriod) {
      case DatePeriodType.daily:
        currentDate = date.add(const Duration(days: 1));
      case DatePeriodType.weekly:
        currentDate = date.add(const Duration(days: 7));
      case DatePeriodType.monthly:
        currentDate = DateTime(date.year, date.month + 1, date.day);
      case DatePeriodType.quarterly:
        currentDate = DateTime(date.year, date.month + 3, date.day);
      case DatePeriodType.semester:
        currentDate = DateTime(date.year, date.month + 6, date.day);
      case DatePeriodType.custom:
        break;
    }
  }

  String getFormattedPeriod(BuildContext context) {
    final date = currentDate;
    switch (currentPeriod) {
      case DatePeriodType.daily:
        return date.formattedDateddMMyyyy(context: context);
      case DatePeriodType.weekly:
        final start = startOfPeriod;
        final end = endOfPeriod;
        return '${start.formattedDateddMM(context: context)} - ${end.formattedDateddMMyyyy(context: context)}';
      case DatePeriodType.monthly:
        return date.formattedMonthYear(context: context);
      case DatePeriodType.quarterly:
        final quarter = ((date.month - 1) ~/ 3) + 1;
        return 'T$quarter ${date.year}';
      case DatePeriodType.semester:
        final semester = date.month <= 6 ? 1 : 2;
        return '$semesterº Semestre ${date.year}';
      case DatePeriodType.custom:
        final start = current.startDate ?? date;
        final end = current.endDate ?? date;
        if (start == end) {
          return start.formattedDateddMMyyyy(context: context);
        }
        return '${start.formattedDateddMMyy(context: context)} - ${end.formattedDateddMMyy(context: context)}';
    }
  }

  @override
  void onClose() {
    _current.close();
    super.onClose();
  }
}
