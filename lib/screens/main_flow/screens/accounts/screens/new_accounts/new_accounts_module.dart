import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/new_accounts/new_accounts_bloc.dart';

import 'new_accounts_model.dart';
import 'new_accounts_screen.dart';

class NewAccountsModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<NewAccountsModel>(NewAccountsModel.new)
      ..addSingleton<NewAccountsBloc>(NewAccountsBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const NewAccountsPopUp());
  }
}
