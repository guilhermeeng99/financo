import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/screens/create_and_edit_account/validation/account_form_types.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/screens/create_and_edit_account/validation/account_validaton_exceptions.dart';

class AccountFormValidator {
  static ValidationResult<CreateAccountParams, AccountFormErrors>
  validateCreateAccount(AccountFormData formData, BuildContext context) {
    final validationResults = _validateFields(formData, context);

    if (validationResults.hasErrors) {
      return ValidationResult.failure(validationResults.errors);
    }

    return ValidationResult.success(
      CreateAccountParams(
        name: validationResults.nameValidation!,
        accountType: formData.accountType,
        initialBalance: validationResults.balanceValidation!,
        currencyType: formData.currencyType,
        iconType: formData.iconType,
        initDate: formData.initDate,
      ),
    );
  }

  static ValidationResult<UpdateAccountParams, AccountFormErrors>
  validateUpdateAccount(
    int accountId,
    AccountFormData formData,
    BuildContext context,
  ) {
    final validationResults = _validateFields(formData, context);

    if (validationResults.hasErrors) {
      return ValidationResult.failure(validationResults.errors);
    }

    return ValidationResult.success(
      UpdateAccountParams(
        id: accountId,
        name: validationResults.nameValidation!,
        accountType: formData.accountType,
        initialBalance: validationResults.balanceValidation!,
        currencyType: formData.currencyType,
        iconType: formData.iconType,
        initDate: formData.initDate,
      ),
    );
  }

  static _FieldValidationResults _validateFields(
    AccountFormData formData,
    BuildContext context,
  ) {
    AccountName? nameValidation;
    Balance? balanceValidation;
    var errors = const AccountFormErrors();

    try {
      nameValidation = AccountName.create(formData.name);
    } on Exception catch (e) {
      final errorMessage = AccountValidationException.getMessage(e, context);
      errors = errors.copyWith(name: errorMessage);
    }

    try {
      balanceValidation = Balance.create(formData.initialBalance);
    } on Exception catch (e) {
      final errorMessage = AccountValidationException.getMessage(e, context);
      errors = errors.copyWith(initialBalance: errorMessage);
    }

    return _FieldValidationResults(
      nameValidation: nameValidation,
      balanceValidation: balanceValidation,
      errors: errors,
    );
  }
}

class _FieldValidationResults {
  const _FieldValidationResults({
    required this.errors,
    this.nameValidation,
    this.balanceValidation,
  });

  final AccountName? nameValidation;
  final Balance? balanceValidation;
  final AccountFormErrors errors;

  bool get hasErrors =>
      errors.hasErrors || nameValidation == null || balanceValidation == null;
}
