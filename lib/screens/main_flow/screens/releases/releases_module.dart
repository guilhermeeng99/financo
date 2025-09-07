import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/account_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/transactions_bloc.dart';

import 'bloc/date_bloc.dart';
import 'releases_model.dart';
import 'releases_screen.dart';

class ReleasesModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<DateFilterBloc>(DateFilterBloc.new)
      ..addSingleton<TransactionsBloc>(TransactionsBloc.new)
      ..addSingleton<TransactionsAccountsBloc>(TransactionsAccountsBloc.new)
      ..addSingleton<ReleasesModelExcel>(ReleasesModelExcel.new)
      ..addSingleton<ReleasesModel>(ReleasesModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const ReleasesScreen());
  }
}
