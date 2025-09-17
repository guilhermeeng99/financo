import 'package:app_widgets/app_widgets.dart';

enum DatePeriodType { daily, weekly, monthly, quarterly, semester, custom }

class CalendarFilter {
  const CalendarFilter({
    required this.date,
    required this.period,
    this.startDate,
    this.endDate,
  });

  final DateTime date;
  final DatePeriodType period;
  final DateTime? startDate;
  final DateTime? endDate;

  CalendarFilter copyWith({
    DateTime? date,
    DatePeriodType? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CalendarFilter(
      date: date ?? this.date,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

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
