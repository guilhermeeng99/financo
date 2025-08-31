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
                onPressed: () {
                  final newDate = DateTime(
                    focusedDate.year,
                    focusedDate.month - 1,
                  );
                  dateFilterBloc.currentDate = newDate;
                },
                icon: const Icon(Icons.chevron_left),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              GestureDetector(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: focusedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );

                  if (selectedDate != null) {
                    dateFilterBloc.currentDate = selectedDate;
                  }
                },
                child: Text(
                  focusedDate.formattedMonthYear(context: context),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: () {
                  final newDate = DateTime(
                    focusedDate.year,
                    focusedDate.month + 1,
                  );
                  dateFilterBloc.currentDate = newDate;
                },
                icon: const Icon(Icons.chevron_right),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          );
        }),
      ),
    );
  }
}
