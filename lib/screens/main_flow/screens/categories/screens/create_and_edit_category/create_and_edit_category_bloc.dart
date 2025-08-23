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

  final selectedCategoryType = CategoryType.expense.obs;

  final RxList<CategoryData> availableParentCategories = <CategoryData>[].obs;

  final RxnInt currentCategoryId = RxnInt();

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
      },
      (parentCategory) {
        if (parentCategory != null) {
          createAndEditCategoryBloc.selectedCategoryType.value =
              parentCategory.categoryType;
        }
      },
    );
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
