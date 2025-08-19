import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CreateAndEditCategoryBloc get createAndEditCategoryBloc =>
    Modular.get<CreateAndEditCategoryBloc>();

class CreateAndEditCategoryBloc extends GetxController {
  CreateAndEditCategoryBloc() {
    loadAvailableParentCategories();
  }

  final RxString name = ''.obs;

  final RxnInt parentCategoryId = RxnInt();

  final selectedCategoryType = CategoryType.expense.obs;

  final RxList<CategoryData> availableParentCategories = <CategoryData>[].obs;

  final RxnInt currentCategoryId = RxnInt();

  void initializeWithCategoryData(CategoryData category) {
    name.value = category.name;
    selectedCategoryType.value = category.categoryType;
    parentCategoryId.value = category.parentCategoryId;
    currentCategoryId.value = category.id;
  }

  Future<void> loadAvailableParentCategories() async {
    try {
      final categoriesCache = DataCacheManager().categories;

      final categories = categoriesCache.getEligibleParentCategories(
        selectedCategoryType.value,
        currentCategoryId.value,
      );

      availableParentCategories.value = categories;
    } catch (e) {
      logger.e('Error loading parent categories from cache: $e');
      availableParentCategories.clear();
    }
  }
}
