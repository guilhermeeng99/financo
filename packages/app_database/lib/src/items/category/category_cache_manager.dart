import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';

class CategoriesCacheManager extends BaseCacheManager<CategoryData> {
  factory CategoriesCacheManager() {
    _instance ??= CategoriesCacheManager._();
    return _instance!;
  }
  CategoriesCacheManager._();

  static CategoriesCacheManager? _instance;

  Map<CategoryType, List<CategoryData>>? _categoriesByType;

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

  List<CategoryData> getByType(CategoryType type) {
    if (!isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }
    return _categoriesByType?[type] ?? [];
  }

  List<CategoryData> getMainCategoriesByType(CategoryType type) {
    if (!isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }
    return getByType(
      type,
    ).where((category) => category.parentCategoryId == null).toList();
  }

  List<CategoryData> getSubcategoriesFor(int parentCategoryId) {
    if (!isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }
    return allItems
            ?.where((category) => category.parentCategoryId == parentCategoryId)
            .toList() ??
        [];
  }

  Map<CategoryType, Map<CategoryData, List<CategoryData>>>
  getCategoriesWithSubcategories() {
    if (!isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }

    final result = <CategoryType, Map<CategoryData, List<CategoryData>>>{};

    for (final type in CategoryType.values) {
      final mainCategories = getMainCategoriesByType(type);

      if (mainCategories.isNotEmpty) {
        final categorySubcategoryMap = <CategoryData, List<CategoryData>>{};

        for (final mainCategory in mainCategories) {
          final subcategories = getSubcategoriesFor(mainCategory.id);
          categorySubcategoryMap[mainCategory] = subcategories;
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
    if (!isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }

    final allCategoriesOfType = getByType(type);

    var eligibleCategories = excludeCategoryId != null
        ? allCategoriesOfType
              .where((category) => category.id != excludeCategoryId)
              .toList()
        : allCategoriesOfType;

    final parentIds =
        allItems
            ?.where((category) => category.parentCategoryId != null)
            .map((category) => category.parentCategoryId!)
            .toSet() ??
        <int>{};

    eligibleCategories = eligibleCategories
        .where((category) => !parentIds.contains(category.id))
        .toList();

    eligibleCategories.sort((a, b) => a.name.compareTo(b.name));

    return eligibleCategories;
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
