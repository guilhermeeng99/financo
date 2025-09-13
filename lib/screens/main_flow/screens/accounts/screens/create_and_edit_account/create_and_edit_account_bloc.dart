import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

import 'validation/account_form_types.dart';
import 'validation/account_form_validator.dart';

CreateAndEditAccountBloc get createAndEditAccountBloc =>
    Modular.get<CreateAndEditAccountBloc>();

class CreateAndEditAccountBloc extends GetxController {
  CreateAndEditAccountBloc() {
    // Listen to form data changes for real-time validation
    ever(formData, (AccountFormData data) {
      // Clear previous errors when form data changes
      formErrors.value = const AccountFormErrors();
    });
  }

  final Rx<AccountFormData> formData = AccountFormData().obs;
  final Rx<AccountFormErrors> formErrors = const AccountFormErrors().obs;

  // Convenience getters
  String get name => formData.value.name;
  double get initialBalance => formData.value.initialBalance;
  AccountType get selectedAccountType => formData.value.accountType;
  CurrencyType get selectedCurrencyType => formData.value.currencyType;
  AccountIconType get selectedIconType => formData.value.iconType;
  DateTime get selectedInitDate => formData.value.initDate;

  // Convenience setters
  void updateName(String name) {
    formData.value = formData.value.copyWith(name: name);
    clearFieldError(AccountFormField.name);
  }

  void updateInitialBalance(String value, BuildContext context) {
    final parsedValue = CurrencyFormatter.parseAmount(value, context);
    formData.value = formData.value.copyWith(initialBalance: parsedValue);
    clearFieldError(AccountFormField.initialBalance);
  }

  void updateAccountType(AccountType accountType) {
    formData.value = formData.value.copyWith(accountType: accountType);
  }

  void updateCurrencyType(CurrencyType currencyType) {
    formData.value = formData.value.copyWith(currencyType: currencyType);
  }

  void updateIconType(AccountIconType iconType) {
    formData.value = formData.value.copyWith(iconType: iconType);
  }

  void updateInitDate(DateTime initDate) {
    formData.value = formData.value.copyWith(initDate: initDate);
  }

  void initializeWithAccountData(AccountData account) {
    formData.value = AccountFormData(
      name: account.name,
      initialBalance: account.initialBalance,
      accountType: account.accountType,
      currencyType: account.currencyType,
      iconType: account.iconType,
      initDate: account.initDate,
    );
    clearAllErrors();
  }

  void validateForm(BuildContext context) {
    final errors = AccountFormValidator.validateField(
      formData.value,
      AccountFormField.name,
      context,
    );
    final balanceErrors = AccountFormValidator.validateField(
      formData.value,
      AccountFormField.initialBalance,
      context,
    );

    formErrors.value = AccountFormErrors(
      name: errors.name,
      initialBalance: balanceErrors.initialBalance,
    );
  }

  void validateField(AccountFormField field, BuildContext context) {
    final fieldErrors = AccountFormValidator.validateField(
      formData.value,
      field,
      context,
    );

    formErrors.value = switch (field) {
      AccountFormField.name => formErrors.value.copyWith(
        name: fieldErrors.name,
      ),
      AccountFormField.initialBalance => formErrors.value.copyWith(
        initialBalance: fieldErrors.initialBalance,
      ),
    };
  }

  void clearFieldError(AccountFormField field) {
    formErrors.value = formErrors.value.clearField(field);
  }

  void clearAllErrors() {
    formErrors.value = const AccountFormErrors();
  }

  void setFieldError(AccountFormField field, String error) {
    formErrors.value = switch (field) {
      AccountFormField.name => formErrors.value.copyWith(name: error),
      AccountFormField.initialBalance => formErrors.value.copyWith(
        initialBalance: error,
      ),
    };
  }

  bool isFormValid(BuildContext context) {
    final nameErrors = AccountFormValidator.validateField(
      formData.value,
      AccountFormField.name,
      context,
    );
    final balanceErrors = AccountFormValidator.validateField(
      formData.value,
      AccountFormField.initialBalance,
      context,
    );

    return !nameErrors.hasErrors &&
        !balanceErrors.hasErrors &&
        !formErrors.value.hasErrors;
  }

  @override
  void onClose() {
    formData.close();
    formErrors.close();
    super.onClose();
  }
}
