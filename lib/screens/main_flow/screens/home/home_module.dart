import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/accounts_module.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_module.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_module.dart';
import 'package:financo/screens/main_flow/screens/home/home_bloc.dart';

import 'home_model.dart';
import 'home_screen.dart';

class HomeModule extends Module {
  @override
  List<Module> get imports => [
    CoreTransactionsModule(),
    CoreCalendarModule(),
    CoreAccountsModule(),
  ];

  @override
  void binds(Injector i) {
    i
      ..addSingleton<HomeBloc>(HomeBloc.new)
      ..addSingleton<HomeModel>(HomeModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const HomeScreen());
  }
}
