import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CreateAndEditCategoryBloc get createAndEditCategoryBloc =>
    Modular.get<CreateAndEditCategoryBloc>();

class CreateAndEditCategoryBloc extends GetxController {
  CreateAndEditCategoryBloc() {
    loadAvailableParentCategories();
  }

  CategoryUsecase get _categoryUsecase => Modular.get<CategoryUsecase>();

  final RxString name = ''.obs;

  final RxnInt parentCategoryId = RxnInt();

  final selectedCategoryType = FinancialType.expense.obs;

  final RxList<CategoryData> availableParentCategories = <CategoryData>[].obs;

  final RxnInt currentCategoryId = RxnInt();

  int? get validatedParentCategoryId {
    final selectedId = parentCategoryId.value;
    if (selectedId == null) return null;

    final availableIds = availableParentCategories.map((c) => c.id).toSet();
    return availableIds.contains(selectedId) ? selectedId : null;
  }

  List<int?> get validDropdownValues => [
    null,
    ...availableParentCategories.map((category) => category.id),
  ];

  bool get currentCategoryHasSubcategories {
    final categoryId = currentCategoryId.value;
    if (categoryId == null) return false;

    return false;
  }

  void initializeWithCategoryData(CategoryData category) {
    name.value = category.name;
    selectedCategoryType.value = category.categoryType;
    parentCategoryId.value = category.parentCategoryId;
    currentCategoryId.value = category.id;
    loadAvailableParentCategories();
  }

  Future<void> initializeSubCategoryFromCategory(int parentCategoryId) async {
    createAndEditCategoryBloc.parentCategoryId.value = parentCategoryId;

    final result = await _categoryUsecase.getCategoryById(parentCategoryId);

    result.fold(
      (failure) {
        logger.e('Error getting parent category: ${failure.message}');
        AppWidgetsUtils.snackBar(
          title: failure.message,
          type: SnackBarType.error,
        );
      },
      (parentCategory) {
        if (parentCategory != null) {
          createAndEditCategoryBloc.selectedCategoryType.value =
              parentCategory.categoryType;
        }
      },
    );

    await loadAvailableParentCategories();
  }

  Future<void> loadAvailableParentCategories() async {
    try {
      final result = await _categoryUsecase.getEligibleParentCategories(
        selectedCategoryType.value,
        currentCategoryId.value,
      );

      result.fold(
        (failure) {
          logger.e('Error loading parent categories: ${failure.message}');
          AppWidgetsUtils.snackBar(
            title: failure.message,
            type: SnackBarType.error,
          );
          availableParentCategories.clear();
        },
        (categories) {
          availableParentCategories.value = categories;
        },
      );
    } catch (e) {
      logger.e('Error loading parent categories: $e');
      availableParentCategories.clear();
    }
  }
}
