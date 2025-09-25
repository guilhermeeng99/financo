import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_module.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_screen.dart';

class ReleasesModule extends Module {
  @override
  List<Module> get imports => [
    CoreTransactionsModule(),
    CoreCalendarModule(),
    CoreAccountsModule(),
  ];

  @override
  void binds(Injector i) {
    i.addSingleton<ReleasesBloc>(ReleasesBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const ReleasesScreen());
  }
}
