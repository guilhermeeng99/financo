import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DateFilterCubit extends Cubit<DateFilterState> {
  DateFilterCubit()
    : super(
        DateFilterState(
          year: DateTime.now().year,
          month: DateTime.now().month,
        ),
      );

  void setMonth(int year, int month) {
    emit(DateFilterState(year: year, month: month));
  }

  void nextMonth() {
    var month = state.month + 1;
    var year = state.year;
    if (month > 12) {
      month = 1;
      year++;
    }
    emit(DateFilterState(year: year, month: month));
  }

  void previousMonth() {
    var month = state.month - 1;
    var year = state.year;
    if (month < 1) {
      month = 12;
      year--;
    }
    emit(DateFilterState(year: year, month: month));
  }
}

class DateFilterState extends Equatable {
  const DateFilterState({required this.year, required this.month});

  final int year;
  final int month;

  @override
  List<Object> get props => [year, month];
}
