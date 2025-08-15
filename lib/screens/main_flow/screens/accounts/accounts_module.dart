import 'package:app_core/app_core.dart';

import 'accounts_model.dart';
import 'accounts_screen.dart';

class AccountsModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<AccountsModel>(AccountsModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const AccountsScreen());
  }
}
