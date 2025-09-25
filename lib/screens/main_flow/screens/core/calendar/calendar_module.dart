import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';

class CoreCalendarModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<CoreCalendarBloc>(CoreCalendarBloc.new);
  }
}
