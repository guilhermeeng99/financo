import 'package:app_core/app_core.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/new_accounts/new_accounts_module.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/new_accounts/new_accounts_screen.dart';

AccountsModel get accountsModel => Modular.get<AccountsModel>();

class AccountsModel {
  void onTapFloatingActionButton() => PopUpManager.showDialog(
    builder: (c) => WidgetModuleProvider(
      module: NewAccountsModule(),
      child: () => const NewAccountsPopUp(),
    ),
  );
}
