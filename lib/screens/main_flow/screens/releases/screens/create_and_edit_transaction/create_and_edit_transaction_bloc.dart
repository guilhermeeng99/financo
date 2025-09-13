import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

import 'validation/transaction_form_types.dart';
import 'validation/transaction_form_validator.dart';

CreateAndEditTransactionBloc get createAndEditTransactionBloc =>
    Modular.get<CreateAndEditTransactionBloc>();

class CreateAndEditTransactionBloc extends GetxController {
  CreateAndEditTransactionBloc() {
    // Initialize reactive date
    actualDateRx = formData.value.actualDate.obs;

    _loadAccounts();
    _loadCategories();

    // Listen to form data changes
    ever(formData, (TransactionFormData data) {
      // Sync reactive date
      actualDateRx.value = data.actualDate;

      if (!data.transactionScreenType.isTransfer) {
        _loadCategories();
      }
    });

    // Listen to reactive date changes from calendar widget
    ever(actualDateRx, (DateTime date) {
      // Only update if the date is different to avoid infinite loop
      if (formData.value.actualDate != date) {
        formData.value = formData.value.copyWith(actualDate: date);
      }
    });
  }

  final Rx<TransactionFormData> formData = TransactionFormData().obs;
  final Rx<TransactionFormErrors> formErrors =
      const TransactionFormErrors().obs;
  final RxList<AccountData> accounts = <AccountData>[].obs;
  final RxList<CategoryData> categories = <CategoryData>[].obs;

  // Reactive date for calendar widgets
  late final Rx<DateTime> actualDateRx;

  // Convenience getters
  String get description => formData.value.description;
  double get amount => formData.value.amount;
  DateTime get actualDate => formData.value.actualDate;
  DateTime get competenceDate => formData.value.competenceDate;
  TransactionScreenType get selectedTransactionScreenType =>
      formData.value.transactionScreenType;
  int? get selectedTargetAccountId => formData.value.selectedTargetAccountId;
  TransactionPaymentStatus get selectedPaymentStatus =>
      formData.value.paymentStatus;
  TransactionRecurrenceType get selectedRecurrenceType =>
      formData.value.recurrenceType;
  TransactionRecurrenceFrequency get selectedRecurrenceFrequency =>
      formData.value.recurrenceFrequency;
  int? get selectedAccountId => formData.value.selectedAccountId;
  int? get selectedCategoryId => formData.value.selectedCategoryId;

  // Form error getters
  String get descriptionError => formErrors.value.description;
  String get amountError => formErrors.value.amount;
  String get accountError => formErrors.value.account;
  String get categoryError => formErrors.value.category;

  bool get isTransfer => formData.value.isTransfer;
  FinancialType? get selectedTransactionType =>
      formData.value.selectedTransactionType;

  TransactionFormErrors get formErrorsValue => formErrors.value;

  // Update methods
  void updateDescription(String value) {
    formData.value = formData.value.copyWith(description: value);
    _clearFormError('description');
  }

  void updateAmount(double value) {
    formData.value = formData.value.copyWith(amount: value);
    _clearFormError('amount');
  }

  void updateActualDate(DateTime value) {
    formData.value = formData.value.copyWith(actualDate: value);
  }

  void updateCompetenceDate(DateTime value) {
    formData.value = formData.value.copyWith(competenceDate: value);
  }

  void updateTransactionScreenType(TransactionScreenType type) {
    formData.value = formData.value.copyWith(
      transactionScreenType: type,
      selectedTargetAccountId: type.isTransfer
          ? null
          : formData.value.selectedTargetAccountId,
    );
  }

  void updateSelectedTargetAccountId(int? value) {
    formData.value = formData.value.copyWith(selectedTargetAccountId: value);
    _clearFormError('account');
  }

  void updatePaymentStatus(TransactionPaymentStatus value) {
    formData.value = formData.value.copyWith(paymentStatus: value);
  }

  void updateRecurrenceType(TransactionRecurrenceType value) {
    formData.value = formData.value.copyWith(recurrenceType: value);
  }

  void updateRecurrenceFrequency(TransactionRecurrenceFrequency value) {
    formData.value = formData.value.copyWith(recurrenceFrequency: value);
  }

  void updateSelectedAccountId(int? value) {
    formData.value = formData.value.copyWith(selectedAccountId: value);
    _clearFormError('account');
  }

  void updateSelectedCategoryId(int? value) {
    formData.value = formData.value.copyWith(selectedCategoryId: value);
    _clearFormError('category');
  }

  void _clearFormError(String field) {
    switch (field) {
      case 'description':
        formErrors.value = formErrors.value.copyWith(description: '');

      case 'amount':
        formErrors.value = formErrors.value.copyWith(amount: '');

      case 'account':
        formErrors.value = formErrors.value.copyWith(account: '');

      case 'category':
        formErrors.value = formErrors.value.copyWith(category: '');
    }
  }

  set formErrorsValue(TransactionFormErrors errors) {
    formErrors.value = errors;
  }

  void clearAllErrors() {
    formErrors.value = const TransactionFormErrors();
  }

  void setTransactionScreenType(TransactionScreenType type) {
    updateTransactionScreenType(type);
  }

  void initializeWithTransactionData(DataTransaction transaction) {
    formData.value = TransactionFormData.fromTransaction(transaction);
  }

  Future<void> _loadAccounts() async {
    final accountUsecase = Modular.get<IAccountUsecase>();
    final result = await accountUsecase.getAllAccounts();

    result.fold(
      (Failure failure) {
        logger.e('Error loading accounts: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (List<AccountData> accountsList) {
        accounts.value = accountsList;
      },
    );
  }

  Future<void> _loadCategories() async {
    final screenType = formData.value.transactionScreenType;
    if (screenType.isTransfer) return;

    final categoryUsecase = Modular.get<ICategoryUsecase>();
    final result = await categoryUsecase.getCategoriesByType(
      screenType.financialType!,
    );

    result.fold(
      (Failure failure) {
        logger.e('Error loading categories: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (List<CategoryData> categoriesList) {
        final flatCategories = <CategoryData>[];

        final parentCategories = categoriesList
            .where((category) => category.parentCategoryId == null)
            .toList();
        flatCategories.addAll(parentCategories);

        final subCategories = categoriesList
            .where((category) => category.parentCategoryId != null)
            .toList();
        flatCategories.addAll(subCategories);

        categories.value = flatCategories;
      },
    );
  }

  @override
  void onClose() {
    formData.close();
    formErrors.close();
    accounts.close();
    categories.close();
    super.onClose();
  }
}
