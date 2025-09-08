import 'package:app_widgets/app_widgets.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:financo/app/app_theme.dart';

class CWCalendarDropDown extends StatelessWidget {
  const CWCalendarDropDown({
    required this.selectedDateRx,
    required this.title,
    super.key,
  });

  final Rx<DateTime> selectedDateRx;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: CWPopUpItemTitle(
        title: title,
        titleSpacing: 18,
        errorOffset: const Offset(0, 2),
        child: Obx(() {
          return GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 25,
                children: [
                  Text(
                    selectedDateRx.value
                        .formattedDateddMMyyyy(context: context),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).customColors.secondaryTextColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: _buildCalendarConfig(context),
      dialogSize: const Size(320, 400),
      borderRadius: BorderRadius.circular(16),
      value: [selectedDateRx.value],
      dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );

    if (results != null && results.isNotEmpty && results.first != null) {
      selectedDateRx.value = results.first!;
    }
  }

  CalendarDatePicker2WithActionButtonsConfig _buildCalendarConfig(
    BuildContext context,
  ) {
    const baseTextStyle = TextStyle(fontSize: 16);

    final secondaryTextStyle = baseTextStyle.copyWith(
      color: Theme.of(context).customColors.secondaryTextColor,
    );

    final selectedTextStyle = baseTextStyle.copyWith(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontWeight: FontWeight.w500,
    );

    return CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.single,
      selectedDayHighlightColor: Theme.of(context).customColors.button01,
      firstDayOfWeek: 0,
      controlsHeight: 56,
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
      dayBorderRadius: BorderRadius.circular(8),
      selectedRangeHighlightColor: Theme.of(context).customColors.button01,
      selectableDayPredicate: (day) =>
          !day.isAfter(DateTime.now().add(const Duration(days: 365))),
      selectedDayTextStyle: baseTextStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      todayTextStyle: baseTextStyle.copyWith(
        color: Theme.of(context).customColors.button01,
        fontWeight: FontWeight.w600,
      ),
      weekdayLabelTextStyle: secondaryTextStyle.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      dayTextStyle: selectedTextStyle,
      disabledDayTextStyle: secondaryTextStyle,
      controlsTextStyle: baseTextStyle.copyWith(
        color: Theme.of(context).textTheme.titleMedium?.color,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      monthTextStyle: secondaryTextStyle,
      selectedMonthTextStyle: selectedTextStyle,
      yearTextStyle: secondaryTextStyle,
      selectedYearTextStyle: selectedTextStyle,
    );
  }
}
