import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/accounts_model.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/accounts_screen.dart';

class AccountsModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<AccountsBloc>(AccountsBloc.new)
      ..addSingleton<AccountsModel>(AccountsModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const AccountsScreen());
  }
}
