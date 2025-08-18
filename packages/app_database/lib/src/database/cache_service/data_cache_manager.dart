import 'package:app_core/app_core.dart';
import 'package:app_database/src/database/cache_service/data_cache_accounts.dart';
import 'package:app_database/src/database/cache_service/data_cache_categories.dart';

abstract class BaseCacheManager<T> {
  List<T>? _allItems;
  bool _isLoaded = false;
  bool _isLoading = false;

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;

  List<T>? get allItems => _allItems;

  Future<bool> loadData() async {
    if (_isLoaded || _isLoading) return _isLoaded;

    _isLoading = true;

    try {
      final result = await fetchDataFromSource();

      if (result != null) {
        _allItems = result;
        onDataLoaded(result);
        _isLoaded = true;
        logger.i('✅ ${result.length} ${getItemTypeName()} loaded');
        return true;
      } else {
        _isLoaded = false;
        return false;
      }
    } catch (e) {
      logger.e('❌ Error while loading ${getItemTypeName()}: $e');
      _isLoaded = false;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  T? getById(int id) {
    if (!_isLoaded) return null;
    try {
      return _allItems?.firstWhere((item) => getItemId(item) == id);
    } catch (e) {
      return null;
    }
  }

  void clearCache() {
    _allItems = null;
    onClearCache();
    _isLoaded = false;
    logger.i('🗑️ Cleared ${getItemTypeName()} cache');
  }

  Future<bool> reloadData() async {
    clearCache();
    return loadData();
  }

  Map<String, dynamic> getCacheStatistics() {
    final baseStats = {'isLoaded': _isLoaded, 'isLoading': _isLoading};

    final customStats = getCustomStatistics();
    return {...baseStats, ...customStats};
  }

  Future<List<T>?> fetchDataFromSource();
  int getItemId(T item);
  String getItemTypeName();

  void onDataLoaded(List<T> items) {}
  void onClearCache() {}
  Map<String, dynamic> getCustomStatistics() => {};
}

class DataCacheManager {
  factory DataCacheManager() {
    _instance ??= DataCacheManager._();
    return _instance!;
  }

  DataCacheManager._();
  static DataCacheManager? _instance;

  static AccountsCacheManager? _accountsInstance;
  static CategoriesCacheManager? _categoriesInstance;

  AccountsCacheManager get accounts {
    _accountsInstance ??= AccountsCacheManager();
    return _accountsInstance!;
  }

  CategoriesCacheManager get categories {
    _categoriesInstance ??= CategoriesCacheManager();
    return _categoriesInstance!;
  }

  bool get isLoaded => accounts.isLoaded && categories.isLoaded;

  bool get isLoading => accounts.isLoading || categories.isLoading;

  Future<bool> preloadAllData() async {
    if (isLoaded || isLoading) return isLoaded;

    logger.i('📦 Starting preloading all data...');

    try {
      final results = await Future.wait([
        accounts.loadData(),
        categories.loadData(),
      ]);

      final success = results.every((result) => result == true);

      if (success) {
        logger.i('✅ Preload complete! All data cached.');
      } else {
        logger.w('⚠️ Preloading partially successful.');
      }

      return success;
    } catch (e) {
      logger.e('❌ Error while preloading: $e');
      return false;
    }
  }
}
