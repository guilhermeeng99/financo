import 'package:app_core/app_core.dart';

import 'calendar_bloc.dart';

class CalendarModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<CalendarFilterBloc>(CalendarFilterBloc.new);
  }
}
