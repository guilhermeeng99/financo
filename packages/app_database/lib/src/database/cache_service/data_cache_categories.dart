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
    logger.i('📊 Loading categories...');

    await Future.delayed(const Duration(milliseconds: 100));
    return [];
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
