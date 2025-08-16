import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_bloc.dart';

import 'new_accounts_bloc.dart';

NewAccountsModel get newAccountsModel => Modular.get<NewAccountsModel>();

class NewAccountsModel {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> onTapSave() async {
    if (!newAccountsBloc.canSave) return;

    final result = await _databaseService.accountUsecase.createAccount(
      name: newAccountsBloc.name.value.trim(),
      accountType: newAccountsBloc.selectedAccountType.value,
      initialBalance: newAccountsBloc.initialBalance.value,
    );

    result.fold(
      (failure) {
        logger.e('Error creating account: ${failure.message}');
      },
      (account) {
        logger.i('Account created successfully: ${account.name}');
        accountsBloc.loadAccounts();
        PopUpManager.pop();
      },
    );
  }
}
