import 'package:app_widgets/app_widgets.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:financo/app/app_theme.dart';

class CustomCalendarDialog {
  static Future<List<DateTime?>?> show(
    BuildContext context, {
    required List<DateTime?> initialDates,
    Size? dialogSize,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    CalendarDatePicker2Type? calendarType,
    bool Function(DateTime)? selectableDayPredicate,
    TextStyle? selectedDayTextStyle,
    TextStyle? todayTextStyle,
    TextStyle? weekdayLabelTextStyle,
    TextStyle? dayTextStyle,
    TextStyle? disabledDayTextStyle,
    TextStyle? controlsTextStyle,
    TextStyle? monthTextStyle,
    TextStyle? selectedMonthTextStyle,
    TextStyle? yearTextStyle,
    TextStyle? selectedYearTextStyle,
    Color? selectedDayHighlightColor,
    Color? selectedRangeHighlightColor,
    BorderRadius? dayBorderRadius,
    int? firstDayOfWeek,
    double? controlsHeight,
    bool? centerAlignModePicker,
    Widget? customModePickerIcon,
  }) async {
    final config = _buildCalendarConfig(
      context,
      calendarType: calendarType,
      selectableDayPredicate: selectableDayPredicate,
      selectedDayTextStyle: selectedDayTextStyle,
      todayTextStyle: todayTextStyle,
      weekdayLabelTextStyle: weekdayLabelTextStyle,
      dayTextStyle: dayTextStyle,
      disabledDayTextStyle: disabledDayTextStyle,
      controlsTextStyle: controlsTextStyle,
      monthTextStyle: monthTextStyle,
      selectedMonthTextStyle: selectedMonthTextStyle,
      yearTextStyle: yearTextStyle,
      selectedYearTextStyle: selectedYearTextStyle,
      selectedDayHighlightColor: selectedDayHighlightColor,
      selectedRangeHighlightColor: selectedRangeHighlightColor,
      dayBorderRadius: dayBorderRadius,
      firstDayOfWeek: firstDayOfWeek,
      controlsHeight: controlsHeight,
      centerAlignModePicker: centerAlignModePicker,
      customModePickerIcon: customModePickerIcon,
    );

    return showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: dialogSize ?? const Size(320, 400),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      value: initialDates,
      dialogBackgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
    );
  }

  static CalendarDatePicker2WithActionButtonsConfig _buildCalendarConfig(
    BuildContext context, {
    CalendarDatePicker2Type? calendarType,
    bool Function(DateTime)? selectableDayPredicate,
    TextStyle? selectedDayTextStyle,
    TextStyle? todayTextStyle,
    TextStyle? weekdayLabelTextStyle,
    TextStyle? dayTextStyle,
    TextStyle? disabledDayTextStyle,
    TextStyle? controlsTextStyle,
    TextStyle? monthTextStyle,
    TextStyle? selectedMonthTextStyle,
    TextStyle? yearTextStyle,
    TextStyle? selectedYearTextStyle,
    Color? selectedDayHighlightColor,
    Color? selectedRangeHighlightColor,
    BorderRadius? dayBorderRadius,
    int? firstDayOfWeek,
    double? controlsHeight,
    bool? centerAlignModePicker,
    Widget? customModePickerIcon,
  }) {
    const baseTextStyle = TextStyle(fontSize: 16);

    final secondaryTextStyle = baseTextStyle.copyWith(
      color: Theme.of(context).customColors.secondaryTextColor,
    );

    final selectedTextStyle = baseTextStyle.copyWith(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontWeight: FontWeight.w500,
    );

    return CalendarDatePicker2WithActionButtonsConfig(
      calendarType: calendarType ?? CalendarDatePicker2Type.single,
      selectedDayHighlightColor:
          selectedDayHighlightColor ?? Theme.of(context).customColors.button01,
      firstDayOfWeek: firstDayOfWeek ?? 0,
      controlsHeight: controlsHeight ?? 56,
      centerAlignModePicker: centerAlignModePicker ?? true,
      customModePickerIcon: customModePickerIcon ?? const SizedBox(),
      dayBorderRadius: dayBorderRadius ?? BorderRadius.circular(8),
      selectedRangeHighlightColor: selectedRangeHighlightColor ??
          Theme.of(context).customColors.button01,
      selectableDayPredicate: selectableDayPredicate ??
          (day) => !day.isAfter(DateTime.now().add(const Duration(days: 365))),
      selectedDayTextStyle: selectedDayTextStyle ??
          baseTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
      todayTextStyle: todayTextStyle ??
          baseTextStyle.copyWith(
            color: Theme.of(context).customColors.button01,
            fontWeight: FontWeight.w600,
          ),
      weekdayLabelTextStyle: weekdayLabelTextStyle ??
          secondaryTextStyle.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
      dayTextStyle: dayTextStyle ?? selectedTextStyle,
      disabledDayTextStyle: disabledDayTextStyle ?? secondaryTextStyle,
      controlsTextStyle: controlsTextStyle ??
          baseTextStyle.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
      monthTextStyle: monthTextStyle ?? secondaryTextStyle,
      selectedMonthTextStyle: selectedMonthTextStyle ?? selectedTextStyle,
      yearTextStyle: yearTextStyle ?? secondaryTextStyle,
      selectedYearTextStyle: selectedYearTextStyle ?? selectedTextStyle,
    );
  }
}
