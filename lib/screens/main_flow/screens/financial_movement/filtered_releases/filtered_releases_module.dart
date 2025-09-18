import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_module.dart';

import 'filtered_releases_bloc.dart';
import 'filtered_releases_model.dart';
import 'filtered_releases_screen.dart';

class FilteredReleasesModule extends Module {
  @override
  List<Module> get imports => [
    CoreTransactionsModule(),
    CoreCalendarModule(),
    CoreAccountsModule(),
  ];

  @override
  void binds(Injector i) {
    i
      ..addSingleton<FilteredReleasesBloc>(FilteredReleasesBloc.new)
      ..addSingleton<FilteredReleasesModel>(FilteredReleasesModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const FilteredReleasesScreen());
  }
}
