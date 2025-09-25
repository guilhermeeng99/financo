import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/accounts_bloc.dart';

class CoreAccountsModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<CoreAccountsBloc>(CoreAccountsBloc.new);
  }
}
