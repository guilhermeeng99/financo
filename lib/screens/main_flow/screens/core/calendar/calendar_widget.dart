import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_filter.dart';

class CWACalendarNavigator extends StatelessWidget {
  const CWACalendarNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return CWCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => calendarFilterBloc.navigateToPrevious(),
                icon: const Icon(Icons.chevron_left),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: Text(
                  calendarFilterBloc.getFormattedPeriod(context),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => calendarFilterBloc.navigateToNext(),
                icon: const Icon(Icons.chevron_right),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              const Gap(10),
              const _PeriodDropdown(),
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
    return PopupMenuButton<DatePeriodType>(
      onSelected: (DatePeriodType newPeriod) async {
        if (newPeriod == DatePeriodType.custom) {
          await calendarFilterBloc.selectCustomPeriod(context);
        } else {
          calendarFilterBloc.currentPeriod = newPeriod;
        }
      },
      icon: const Icon(Icons.settings),
      color: Theme.of(context).scaffoldBackgroundColor,
      itemBuilder: (BuildContext context) {
        return DatePeriodType.values.map((DatePeriodType period) {
          return PopupMenuItem<DatePeriodType>(
            value: period,
            child: Text(
              period.getName(context),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }).toList();
      },
    );
  }
}
