import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_bloc.dart';

import 'create_and_edit_account_bloc.dart';

CreateAndEditAccountModel get createAndEditAccountModel =>
    Modular.get<CreateAndEditAccountModel>();

class CreateAndEditAccountModel {
  IAccountUsecase get _accountUsecase => Modular.get<IAccountUsecase>();

  Future<void> onTapSave(AccountData? account, BuildContext context) async {
    if (account != null) {
      await _updateAccount(account, context);
    } else {
      await _createAccount(context);
    }
  }

  Future<void> _createAccount(BuildContext context) async {
    final (name, balance) = _validateInputs(context);

    if (name == null || balance == null) {
      return;
    }

    final result = await _accountUsecase.createAccount(
      name: name,
      accountType: createAndEditAccountBloc.selectedAccountType.value,
      initialBalance: balance,
      currencyType: createAndEditAccountBloc.selectedCurrencyType.value,
      iconType: createAndEditAccountBloc.selectedIconType.value,
      initDate: createAndEditAccountBloc.selectedInitDate.value,
    );

    result.fold(
      (failure) {
        logger.e('Error creating account: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (account) {
        logger.i('Account created successfully: ${account.name}');

        accountsBloc.loadGroupedAccounts();
        PopUpManager.pop();
      },
    );
  }

  Future<void> _updateAccount(
    AccountData originalAccount,
    BuildContext context,
  ) async {
    final (name, balance) = _validateInputs(context);

    if (name == null || balance == null) {
      return;
    }

    final result = await _accountUsecase.updateAccount(
      id: originalAccount.id,
      name: name,
      accountType: createAndEditAccountBloc.selectedAccountType.value,
      initialBalance: balance,
      currencyType: createAndEditAccountBloc.selectedCurrencyType.value,
      isActive: originalAccount.isActive,
      iconType: createAndEditAccountBloc.selectedIconType.value,
      initDate: createAndEditAccountBloc.selectedInitDate.value,
    );

    result.fold(
      (failure) {
        if (failure is NoChangesFailure) {
          logger.i(context.t.messages.warnings.no_changes_provided);
          CWSnackBar.snackBar(
            title: context.t.messages.warnings.no_changes_provided,
            type: SnackBarType.info,
          );
          PopUpManager.pop();
        } else {
          logger.e('Error creating account: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        }
      },
      (account) {
        logger.i('Account updated successfully: ${account.name}');

        accountsBloc.loadGroupedAccounts();
        PopUpManager.pop();
      },
    );
  }

  (AccountName?, Balance?) _validateInputs(BuildContext context) {
    AccountName? name;
    Balance? balance;

    // Clear previous errors
    createAndEditAccountBloc.clearErrors();

    try {
      name = AccountName.create(
        createAndEditAccountBloc.name.value.trim(),
        context,
      );
    } on ValidationException catch (e) {
      createAndEditAccountBloc.nameError.value = e.message;
    }

    try {
      balance = Balance.create(
        createAndEditAccountBloc.initialBalance.value,
        context,
      );
    } on ValidationException catch (e) {
      createAndEditAccountBloc.balanceError.value = e.message;
    }

    return (name, balance);
  }
}
