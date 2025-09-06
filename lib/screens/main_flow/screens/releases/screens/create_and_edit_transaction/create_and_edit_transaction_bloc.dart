import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CreateAndEditTransactionBloc get createAndEditTransactionBloc =>
    Modular.get<CreateAndEditTransactionBloc>();

class CreateAndEditTransactionBloc extends GetxController {
  CreateAndEditTransactionBloc() {
    _loadAccounts();
    _loadCategories();

    ever(selectedTransactionType, (FinancialType transactionType) {
      _loadCategories();
    });
  }
  final RxString description = ''.obs;
  final RxString descriptionError = ''.obs;

  final RxDouble amount = 0.0.obs;
  final RxString amountError = ''.obs;

  final Rx<DateTime> actualDate = DateTime.now().obs;
  final Rx<DateTime> competenceDate = DateTime.now().obs;
  final selectedTransactionType = FinancialType.expense.obs;
  final selectedPaymentStatus = TransactionPaymentStatus.unpaid.obs;
  final selectedRecurrenceType = TransactionRecurrenceType.unique.obs;
  final selectedRecurrenceFrequency =
      TransactionRecurrenceFrequency.monthly.obs;
  final Rx<int?> selectedAccountId = Rx<int?>(null);
  final RxString accountError = ''.obs;

  final Rx<int?> selectedCategoryId = Rx<int?>(null);
  final RxString categoryError = ''.obs;

  final RxList<AccountData> accounts = <AccountData>[].obs;
  final RxList<CategoryData> categories = <CategoryData>[].obs;

  void initializeWithTransactionData(TransactionData transaction) {
    description.value = transaction.description ?? '';
    amount.value = transaction.amount;
    actualDate.value = transaction.actualDate;
    competenceDate.value = transaction.competenceDate;
    selectedTransactionType.value = transaction.transactionType;
    selectedPaymentStatus.value = transaction.paymentStatus;
    selectedRecurrenceType.value = transaction.recurrenceType;
    selectedRecurrenceFrequency.value =
        transaction.recurrenceFrequency ??
        TransactionRecurrenceFrequency.monthly;
    selectedAccountId.value = transaction.accountId;
    selectedCategoryId.value = transaction.categoryId;
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
    final categoryUsecase = Modular.get<ICategoryUsecase>();
    final result = await categoryUsecase.getCategoriesByType(
      selectedTransactionType.value,
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
    description.close();
    descriptionError.close();
    amount.close();
    amountError.close();
    actualDate.close();
    competenceDate.close();
    selectedTransactionType.close();
    selectedPaymentStatus.close();
    selectedRecurrenceType.close();
    selectedRecurrenceFrequency.close();
    selectedAccountId.close();
    accountError.close();
    selectedCategoryId.close();
    categoryError.close();
    super.onClose();
  }
}
