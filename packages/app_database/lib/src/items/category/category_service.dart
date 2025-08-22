import 'package:app_database/app_database.dart';

import 'category_cache_manager.dart';
import 'category_cache_service.dart';

class CategoryService {

  factory CategoryService() {
    _instance ??= CategoryService._();
    return _instance!;
  }
  CategoryService._();

  static CategoryService? _instance;

  final CategoriesCacheManager _cacheManager = CategoriesCacheManager();
  late final CategoryCacheService _cacheService = CategoryCacheService(
    _cacheManager,
  );

  bool get isLoaded => _cacheManager.isLoaded;
  bool get isLoading => _cacheManager.isLoading;
  List<CategoryData>? get allCategories => _cacheManager.allItems;

  Future<bool> loadData() => _cacheManager.loadData();

  CategoryData? getById(int id) => _cacheManager.getById(id);

  void add(CategoryData category) => _cacheManager.add(category);

  void update(CategoryData updatedCategory) =>
      _cacheManager.update(updatedCategory);

  void remove(int categoryId) => _cacheManager.remove(categoryId);

  Map<CategoryType, Map<CategoryData, List<CategoryData>>>
  getCategoriesAndSubcategories({bool onlyActive = false}) =>
      _cacheService.getCategoriesAndSubcategories(onlyActive: onlyActive);

  List<CategoryData> getEligibleParentCategories(
    CategoryType type,
    int? excludeCategoryId,
  ) => _cacheService.getEligibleParentCategories(type, excludeCategoryId);

  List<CategoryData> getSubcategoriesFor(int parentCategoryId) =>
      _cacheService.getSubcategoriesFor(parentCategoryId);

  List<CategoryData> getCategoriesByType(
    CategoryType type, {
    bool onlyActive = false,
    bool onlyMainCategories = false,
  }) => _cacheService.getCategoriesByType(
    type,
    onlyActive: onlyActive,
    onlyMainCategories: onlyMainCategories,
  );
}
