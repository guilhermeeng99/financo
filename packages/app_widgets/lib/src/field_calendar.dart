import 'package:app_widgets/app_widgets.dart';
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
    final results = await CustomCalendarDialog.show(
      context,
      initialDates: [selectedDateRx.value],
    );

    if (results != null && results.isNotEmpty && results.first != null) {
      selectedDateRx.value = results.first!;
    }
  }
}
