import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';

import 'category_cache_service.dart';

class CategoriesCacheManager extends BaseCacheManager<CategoryData> {
  factory CategoriesCacheManager() {
    _instance ??= CategoriesCacheManager._();
    return _instance!;
  }
  CategoriesCacheManager._();

  static CategoriesCacheManager? _instance;

  Map<CategoryType, List<CategoryData>>? _categoriesByType;

  CategoryCacheService? _cacheService;
  CategoryCacheService get _cache {
    _cacheService ??= CategoryCacheService(this);
    return _cacheService!;
  }

  @override
  Future<List<CategoryData>?> fetchDataFromSource() async {
    final categoryUsecase = Modular.get<CategoryUsecase>();

    logger.i('📊 Loading categories...');

    final categoriesResult = await categoryUsecase.getAllCategories();
    return categoriesResult.fold((failure) {
      logger.e('❌ Error loading categories: ${failure.message}');
      throw Exception('Failed to load categories: ${failure.message}');
    }, (categories) => categories);
  }

  @override
  int getItemId(CategoryData item) => item.id;

  @override
  String getItemTypeName() => 'categories';

  @override
  void onDataLoaded(List<CategoryData> items) {
    _categoriesByType = _groupCategoriesByType(items);
  }

  @override
  void onClearCache() {
    _categoriesByType = null;
  }

  @override
  Map<String, dynamic> getCustomStatistics() {
    return {
      'categoriesByType':
          _categoriesByType?.map(
            (key, value) => MapEntry(key.toString(), value.length),
          ) ??
          {},
    };
  }

  Map<CategoryType, Map<CategoryData, List<CategoryData>>>
  getCategoriesAndSubcategories({bool onlyActive = false}) {
    return _cache.getCategoriesAndSubcategories(onlyActive: onlyActive);
  }

  List<CategoryData> getEligibleParentCategories(
    CategoryType type,
    int? excludeCategoryId,
  ) {
    return _cache.getEligibleParentCategories(type, excludeCategoryId);
  }

  List<CategoryData> getSubcategoriesFor(int parentCategoryId) {
    return _cache.getSubcategoriesFor(parentCategoryId);
  }

  void add(CategoryData category) {
    if (allItems != null) {
      allItems!.add(category);
      _categoriesByType = _groupCategoriesByType(allItems!);
      logger.i('➕ Category added to cache: ${category.name}');
    }
  }

  void update(CategoryData updatedCategory) {
    if (allItems != null) {
      final index = allItems!.indexWhere((cat) => cat.id == updatedCategory.id);
      if (index != -1) {
        allItems![index] = updatedCategory;
        _categoriesByType = _groupCategoriesByType(allItems!);
        logger.i('🔄 Category updated in cache: ${updatedCategory.name}');
      }
    }
  }

  void remove(int categoryId) {
    if (allItems != null) {
      allItems!.removeWhere((cat) => cat.id == categoryId);
      _categoriesByType = _groupCategoriesByType(allItems!);
      logger.i('🗑️ Category removed from cache: ID $categoryId');
    }
  }

  Map<CategoryType, List<CategoryData>> _groupCategoriesByType(
    List<CategoryData> categories,
  ) {
    final grouped = <CategoryType, List<CategoryData>>{};

    for (final type in CategoryType.values) {
      grouped[type] = categories
          .where((category) => category.categoryType == type)
          .toList();
    }

    return grouped;
  }
}
