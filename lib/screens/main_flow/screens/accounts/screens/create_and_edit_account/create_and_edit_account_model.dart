import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_bloc.dart';

import 'create_and_edit_account_bloc.dart';

CreateAndEditAccountModel get createAndEditAccountModel =>
    Modular.get<CreateAndEditAccountModel>();

class CreateAndEditAccountModel {
  AccountUsecase get _accountUsecase => Modular.get<AccountUsecase>();

  Future<void> onTapSave(AccountData? account) async {
    final canSave = createAndEditAccountBloc.name.value.trim().isNotEmpty;

    if (canSave) {
      if (account != null) {
        await _updateAccount(account);
      } else {
        await _createAccount();
      }
    }
  }

  Future<void> _createAccount() async {
    final result = await _accountUsecase.createAccount(
      name: createAndEditAccountBloc.name.value.trim(),
      accountType: createAndEditAccountBloc.selectedAccountType.value,
      initialBalance: createAndEditAccountBloc.initialBalance.value,
      currencyType: createAndEditAccountBloc.selectedCurrencyType.value,
      iconType: createAndEditAccountBloc.selectedIconType.value,
      initDate: createAndEditAccountBloc.selectedInitDate.value,
    );

    result.fold(
      (failure) {
        logger.e('Error creating account: ${failure.message}');
      },
      (account) {
        logger.i('Account created successfully: ${account.name}');

        DataCacheManager().accounts.add(account);

        accountsBloc.loadGroupedAccounts();
        PopUpManager.pop();
      },
    );
  }

  Future<void> _updateAccount(AccountData originalAccount) async {
    final result = await _accountUsecase.updateAccount(
      id: originalAccount.id,
      name: createAndEditAccountBloc.name.value.trim(),
      accountType: createAndEditAccountBloc.selectedAccountType.value,
      balance: createAndEditAccountBloc.initialBalance.value,
      currencyType: createAndEditAccountBloc.selectedCurrencyType.value,
      isActive: originalAccount.isActive,
      iconType: createAndEditAccountBloc.selectedIconType.value,
      initDate: createAndEditAccountBloc.selectedInitDate.value,
    );

    result.fold(
      (failure) {
        logger.e('Error updating account: ${failure.message}');
      },
      (account) {
        logger.i('Account updated successfully: ${account.name}');

        DataCacheManager().accounts.update(account);

        accountsBloc.loadGroupedAccounts();
        PopUpManager.pop();
      },
    );
  }
}
