import 'package:app_core/app_core.dart';

import 'releases_bloc.dart';
import 'releases_model.dart';
import 'releases_screen.dart';

class ReleasesModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<TransactionsBloc>(TransactionsBloc.new)
      ..addSingleton<AccountsBloc>(AccountsBloc.new)
      ..addSingleton<ReleasesModel>(ReleasesModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const ReleasesScreen());
  }
}
