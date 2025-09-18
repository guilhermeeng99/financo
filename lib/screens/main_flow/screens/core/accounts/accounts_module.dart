import 'package:app_core/app_core.dart';

import 'accounts_bloc.dart';

class CoreAccountsModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<CoreAccountsBloc>(CoreAccountsBloc.new);
  }
}
