import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/screens/create_and_edit_account/validation/account_form_types.dart';

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
  double? get creditLimit => formData.value.creditLimit;
  DateTime? get firstBillDueDate => formData.value.firstBillDueDate;
  int get billClosingDay => formData.value.billClosingDay;
  int? get paymentAccountId => formData.value.paymentAccountId;

  // Convenience setters
  void updateName(String name) {
    formData.value = formData.value.copyWith(name: name);
    _clearFormError('name');
  }

  void updateInitialBalance(String value, BuildContext context) {
    final parsedValue = CurrencyFormatter.parseAmount(value, context);
    formData.value = formData.value.copyWith(initialBalance: parsedValue);
    _clearFormError('initialBalance');
  }

  void updateAccountType(AccountType accountType) {
    formData.value = formData.value.copyWith(accountType: accountType);

    // Load checking accounts when switching to credit card
    if (accountType == AccountType.creditCard) {
      unawaited(loadAvailableCheckingAccounts());
    }
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

  void updateCreditLimit(String value, BuildContext context) {
    final parsedValue = CurrencyFormatter.parseAmount(value, context);
    formData.value = formData.value.copyWith(creditLimit: parsedValue);
    _clearFormError('creditLimit');
  }

  void updateFirstBillDueDate(DateTime date) {
    formData.value = formData.value.copyWith(firstBillDueDate: date);
    _clearFormError('firstBillDueDate');
  }

  void updateBillClosingDay(int day) {
    formData.value = formData.value.copyWith(billClosingDay: day);
    _clearFormError('billClosingDay');
  }

  void updatePaymentAccountId(int? accountId) {
    formData.value = formData.value.copyWith(paymentAccountId: accountId);
    _clearFormError('paymentAccountId');
  }

  final RxList<AccountData> _checkingAccounts = <AccountData>[].obs;
  List<AccountData> get availableCheckingAccounts => _checkingAccounts;

  Future<void> loadAvailableCheckingAccounts() async {
    final accountUsecase = Modular.get<IAccountUsecase>();
    final result = await accountUsecase.getCheckingAccounts();

    result.fold(
      (failure) {
        logger.e('Error loading checking accounts: ${failure.message}');
        _checkingAccounts.clear();
      },
      _checkingAccounts.assignAll,
    );
  }

  void initializeWithAccountData(AccountData account) {
    formData.value = AccountFormData.fromAccount(account);
    clearAllErrors();

    // Load checking accounts if this is a credit card
    if (account.accountType == AccountType.creditCard) {
      unawaited(loadAvailableCheckingAccounts());
    }
  }

  void _clearFormError(String field) {
    switch (field) {
      case 'name':
        formErrors.value = formErrors.value.copyWith(name: '');
      case 'initialBalance':
        formErrors.value = formErrors.value.copyWith(initialBalance: '');
      case 'creditLimit':
        formErrors.value = formErrors.value.copyWith(creditLimit: '');
      case 'firstBillDueDate':
        formErrors.value = formErrors.value.copyWith(firstBillDueDate: '');
      case 'billClosingDay':
        formErrors.value = formErrors.value.copyWith(billClosingDay: '');
      case 'paymentAccountId':
        formErrors.value = formErrors.value.copyWith(paymentAccountId: '');
    }
  }

  void clearAllErrors() {
    formErrors.value = const AccountFormErrors();
  }

  @override
  void onClose() {
    formData.close();
    formErrors.close();
    super.onClose();
  }
}
