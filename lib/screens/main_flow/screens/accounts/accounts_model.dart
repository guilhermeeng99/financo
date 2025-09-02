import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/create_and_edit_account/create_and_edit_account_module.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/create_and_edit_account/create_and_edit_account_screen.dart';

AccountsModel get accountsModel => Modular.get<AccountsModel>();

class AccountsModel {
  IAccountUsecase get _accountUsecase => Modular.get<IAccountUsecase>();

  void onTapFloatingActionButton() => _showAccountPopUp(
    CreateAndEditAccountPopUpArgs(type: CreateAndEditAccountPopUpType.create),
  );

  void onTapUpdateAccountPopUp(AccountData account) => _showAccountPopUp(
    CreateAndEditAccountPopUpArgs(
      type: CreateAndEditAccountPopUpType.edit,
      account: account,
    ),
  );

  void _showAccountPopUp(CreateAndEditAccountPopUpArgs args) =>
      PopUpManager.showDialog(
        builder: (c) => WidgetModuleProvider(
          module: CreateAndEditAccountModule(),
          child: () => CreateAndEditAccountPopUp(args),
        ),
      );

  void onTapShowOnlyActiveAccounts() {
    accountsBloc.showOnlyActiveAccounts.value =
        !accountsBloc.showOnlyActiveAccounts.value;
    accountsBloc.loadGroupedAccounts();
  }

  Future<void> onTapFreezeOrUnfreeze({
    required AccountData account,
    required bool freeze,
  }) async {
    final result = await _accountUsecase.updateAccount(
      id: account.id,
      isActive: !freeze,
    );

    result.fold(
      (failure) {
        logger.e('Error updating account status: ${failure.message}');
        AppWidgetsUtils.snackBar(
          title: failure.message,
          type: SnackBarType.error,
        );
      },
      (updatedAccount) {
        logger.i('Account status updated successfully');

        accountsBloc.loadGroupedAccounts();
      },
    );
  }

  Future<void> onTapDeleteAccout(AccountData account) async {
    final result = await _accountUsecase.deleteAccount(account.id);

    result.fold(
      (failure) {
        logger.e('Error deleting account: ${failure.message}');
        AppWidgetsUtils.snackBar(
          title: failure.message,
          type: SnackBarType.error,
        );
      },
      (deletedAccount) {
        logger.i('Account deleted successfully');

        accountsBloc.loadGroupedAccounts();
      },
    );
  }
}
