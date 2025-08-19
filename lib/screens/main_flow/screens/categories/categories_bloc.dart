import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CategoriesBloc get categoriesBloc => Modular.get<CategoriesBloc>();

class CategoriesBloc extends GetxController {
  CategoriesBloc() {
    loadGroupedCategories();
  }

  final RxMap<CategoryType, List<CategoryData>> groupedCategories =
      <CategoryType, List<CategoryData>>{}.obs;

  final RxMap<CategoryType, Map<CategoryData, List<CategoryData>>>
  categoriesWithSubcategories =
      <CategoryType, Map<CategoryData, List<CategoryData>>>{}.obs;

  Future<void> loadGroupedCategories() async {
    try {
      final categoriesCache = DataCacheManager().categories;

      final grouped = <CategoryType, List<CategoryData>>{};
      for (final type in CategoryType.values) {
        final mainCategories = categoriesCache.getMainCategoriesByType(type);
        if (mainCategories.isNotEmpty) {
          grouped[type] = mainCategories;
        }
      }

      final withSubcategories = categoriesCache
          .getCategoriesWithSubcategories();

      groupedCategories.value = grouped;
      categoriesWithSubcategories.value = withSubcategories;
      logger.i('✅ Grouped categories loaded from cache');
    } catch (e) {
      logger.e('❌ Error loading categories from cache: $e');
    }
  }

  @override
  void onClose() {
    groupedCategories.close();
    categoriesWithSubcategories.close();
    super.onClose();
  }
}
