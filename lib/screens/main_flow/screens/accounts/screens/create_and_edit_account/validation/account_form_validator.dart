import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

import 'account_form_types.dart';

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
      nameValidation = AccountName.create(formData.name, context);
    } on ValidationException catch (e) {
      logger.e(e.message);
      errors = errors.copyWith(name: e.message);
    }

    try {
      balanceValidation = Balance.create(formData.initialBalance, context);
    } on ValidationException catch (e) {
      logger.e(e.message);
      errors = errors.copyWith(initialBalance: e.message);
    }

    return _FieldValidationResults(
      nameValidation: nameValidation,
      balanceValidation: balanceValidation,
      errors: errors,
    );
  }

  static AccountFormErrors validateField(
    AccountFormData formData,
    AccountFormField field,
    BuildContext context,
  ) {
    return switch (field) {
      AccountFormField.name => _validateNameField(formData.name, context),
      AccountFormField.initialBalance => _validateBalanceField(
        formData.initialBalance,
        context,
      ),
    };
  }

  static AccountFormErrors _validateNameField(
    String name,
    BuildContext context,
  ) {
    try {
      AccountName.create(name, context);
      return const AccountFormErrors();
    } on ValidationException catch (e) {
      return AccountFormErrors(name: e.message);
    }
  }

  static AccountFormErrors _validateBalanceField(
    double balance,
    BuildContext context,
  ) {
    try {
      Balance.create(balance, context);
      return const AccountFormErrors();
    } on ValidationException catch (e) {
      return AccountFormErrors(initialBalance: e.message);
    }
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
