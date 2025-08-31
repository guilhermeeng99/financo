import 'package:app_widgets/app_widgets.dart';

DateFilterBloc get dateFilterBloc => Modular.get<DateFilterBloc>();

class DateFilterBloc extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  DateTime get currentDate => selectedDate.value;

  set currentDate(DateTime newDate) {
    selectedDate.value = newDate;
  }

  bool isTransactionInSelectedMonth(DateTime transactionDate) {
    return transactionDate.year == selectedDate.value.year &&
        transactionDate.month == selectedDate.value.month;
  }

  DateTime get startOfMonth {
    final date = selectedDate.value;
    return DateTime(date.year, date.month);
  }

  DateTime get endOfMonth {
    final date = selectedDate.value;
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  @override
  void onClose() {
    selectedDate.close();
    super.onClose();
  }
}
