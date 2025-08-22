import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CategoriesBloc get categoriesBloc => Modular.get<CategoriesBloc>();

class CategoriesBloc extends GetxController {
  CategoriesBloc() {
    loadCategories();
  }

  final RxMap<CategoryType, Map<CategoryData, List<CategoryData>>>
  categoriesWithSubcategories =
      <CategoryType, Map<CategoryData, List<CategoryData>>>{}.obs;

  final RxBool showOnlyActiveCategories = true.obs;

  Future<void> loadCategories() async {
    try {
      final categoriesCache = DataCacheManager().categories;

      final withSubcategories = categoriesCache.getCategoriesAndSubcategories(
        onlyActive: showOnlyActiveCategories.value,
      );

      categoriesWithSubcategories.value = withSubcategories;
      logger.i('✅ Grouped categories loaded from cache');
    } catch (e) {
      logger.e('❌ Error loading categories from cache: $e');
    }
  }

  @override
  void onClose() {
    categoriesWithSubcategories.close();
    showOnlyActiveCategories.close();
    super.onClose();
  }
}
