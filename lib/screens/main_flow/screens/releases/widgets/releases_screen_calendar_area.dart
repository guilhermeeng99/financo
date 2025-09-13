import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/date_bloc.dart';

class CWAReleasesScreenCalendar extends StatelessWidget {
  const CWAReleasesScreenCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return CWCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Obx(() {
          final focusedDate = dateFilterBloc.currentDate;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => dateFilterBloc.navigateToPrevious(),
                icon: const Icon(Icons.chevron_left),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: focusedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                    );

                    if (selectedDate != null) {
                      dateFilterBloc.currentDate = selectedDate;
                    }
                  },
                  child: Text(
                    dateFilterBloc.getFormattedPeriod(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => dateFilterBloc.navigateToNext(),
                    icon: const Icon(Icons.chevron_right),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  const _PeriodDropdown(),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CWDropdownField<DatePeriodType>(
        value: dateFilterBloc.currentPeriod,
        items: DatePeriodType.values,
        onChanged: (DatePeriodType? newPeriod) {
          if (newPeriod != null) {
            dateFilterBloc.currentPeriod = newPeriod;
          }
        },
        itemBuilder: (DatePeriodType period, BuildContext context) {
          return Text(period.getName(context));
        },
        textStyle: Theme.of(context).textTheme.bodyMedium,
      );
    });
  }
}
