import 'package:app_database/app_database.dart';

import 'category_cache_manager.dart';

class CategoryCacheService {
  CategoryCacheService(this._cacheManager);

  final CategoriesCacheManager _cacheManager;

  Map<CategoryType, Map<CategoryData, List<CategoryData>>>
  getCategoriesAndSubcategories({bool onlyActive = false}) {
    if (!_cacheManager.isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }

    final result = <CategoryType, Map<CategoryData, List<CategoryData>>>{};

    for (final type in CategoryType.values) {
      final mainCategories = _getMainCategoriesByType(type);
      final filteredMainCategories = onlyActive
          ? mainCategories.where((cat) => cat.isActive).toList()
          : mainCategories;

      if (filteredMainCategories.isNotEmpty) {
        final categorySubcategoryMap = <CategoryData, List<CategoryData>>{};

        for (final mainCategory in filteredMainCategories) {
          final subcategories = _getSubcategoriesFor(mainCategory.id);
          final filteredSubcategories = onlyActive
              ? subcategories.where((sub) => sub.isActive).toList()
              : subcategories;
          categorySubcategoryMap[mainCategory] = filteredSubcategories;
        }

        result[type] = categorySubcategoryMap;
      }
    }

    return result;
  }

  List<CategoryData> getEligibleParentCategories(
    CategoryType type,
    int? excludeCategoryId,
  ) {
    if (!_cacheManager.isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }

    final allCategoriesOfType = _getCategoriesByType(type);

    var eligibleCategories = excludeCategoryId != null
        ? allCategoriesOfType
              .where((category) => category.id != excludeCategoryId)
              .toList()
        : allCategoriesOfType;

    eligibleCategories = eligibleCategories
        .where((category) => category.parentCategoryId == null)
        .toList();

    eligibleCategories.sort((a, b) => a.name.compareTo(b.name));

    return eligibleCategories;
  }

  List<CategoryData> getSubcategoriesFor(int parentCategoryId) {
    return _getSubcategoriesFor(parentCategoryId);
  }

  List<CategoryData> getCategoriesByType(
    CategoryType type, {
    bool onlyActive = false,
    bool onlyMainCategories = false,
  }) {
    var categories = _getCategoriesByType(type);

    if (onlyActive) {
      categories = categories
          .where((CategoryData cat) => cat.isActive)
          .toList();
    }

    if (onlyMainCategories) {
      categories = categories
          .where((CategoryData cat) => cat.parentCategoryId == null)
          .toList();
    }

    return categories;
  }

  List<CategoryData> _getCategoriesByType(CategoryType type) {
    final allItems = _cacheManager.allItems ?? [];
    return allItems
        .where((CategoryData category) => category.categoryType == type)
        .toList();
  }

  List<CategoryData> _getMainCategoriesByType(CategoryType type) {
    return _getCategoriesByType(
      type,
    ).where((category) => category.parentCategoryId == null).toList();
  }

  List<CategoryData> _getSubcategoriesFor(int parentCategoryId) {
    if (!_cacheManager.isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }

    final allItems = _cacheManager.allItems;
    return allItems
            ?.where(
              (CategoryData category) =>
                  category.parentCategoryId == parentCategoryId,
            )
            .toList() ??
        [];
  }
}
