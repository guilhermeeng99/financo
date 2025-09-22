import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_widget.dart';
import 'package:financo/screens/main_flow/screens/home/home_bloc.dart';

class CWHomeScreenCalendarNavigator extends StatelessWidget {
  const CWHomeScreenCalendarNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => homeBloc.navigateToPrevious(),
            icon: const Icon(Icons.keyboard_arrow_up),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          const Gap(10),
          Text(
            homeBloc.getFormattedPeriod(context: context, short: true),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(10),
          IconButton(
            onPressed: () => homeBloc.navigateToNext(),
            icon: const Icon(Icons.keyboard_arrow_down),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          const CWCalendarNavigatorPeriodDropdown(),
        ],
      );
    });
  }
}
