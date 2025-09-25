import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

import 'create_and_edit_account_bloc.dart';
import 'create_and_edit_account_service.dart';
import 'validation/account_form_types.dart';
import 'validation/account_form_validator.dart';

CreateAndEditAccountModel get createAndEditAccountModel =>
    Modular.get<CreateAndEditAccountModel>();

class CreateAndEditAccountModel {
  final AccountOperationService _operationService = AccountOperationService();

  Future<void> onTapSave(AccountData? account, BuildContext context) async {
    createAndEditAccountBloc.clearAllErrors();

    if (account != null) {
      await _updateAccount(account, context);
    } else {
      await _createAccount(context);
    }
  }

  Future<void> _createAccount(BuildContext context) async {
    final formData = createAndEditAccountBloc.formData.value;

    final validationResult = AccountFormValidator.validateCreateAccount(
      formData,
      context,
    );

    if (validationResult.isFailure) {
      createAndEditAccountBloc.formErrors.value = validationResult.errors!;
      return;
    }

    final params = validationResult.data!;
    final result = await _operationService.createAccount(
      params,
      formData,
      context,
    );

    await result.fold((failure) => _handleFailure(failure, context), (
      account,
    ) async {
      logger.i('Account created successfully');
      await PopUpManager.pop();
    });
  }

  Future<void> _updateAccount(
    AccountData originalAccount,
    BuildContext context,
  ) async {
    final formData = createAndEditAccountBloc.formData.value;

    final validationResult = AccountFormValidator.validateUpdateAccount(
      originalAccount.id,
      formData,
      context,
    );

    if (validationResult.isFailure) {
      createAndEditAccountBloc.formErrors.value = validationResult.errors!;
      return;
    }

    final params = validationResult.data!;
    final result = await _operationService.updateAccount(
      params,
      formData,
      context,
    );

    await result.fold((failure) => _handleFailure(failure, context), (
      account,
    ) async {
      logger.i('Account updated successfully');
      await PopUpManager.pop();
    });
  }

  Future<void> _handleFailure(Failure failure, BuildContext context) async {
    if (failure is DuplicateEntryFailure) {
      createAndEditAccountBloc.formErrors.value = AccountFormErrors(
        name: context.t.accounts.validation.name_already_exists,
      );
    } else if (failure is NoChangesFailure) {
      logger.i(context.t.messages.warnings.no_changes_provided);
      CWSnackBar.snackBar(
        title: context.t.messages.warnings.no_changes_provided,
        type: SnackBarType.info,
      );
      await PopUpManager.pop();
    } else {
      CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      logger.e('Error with account operation: ${failure.message}');
    }
  }
}
