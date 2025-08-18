import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class AppIntializer {
  static Future<void> initializeBeforeApp() async {
    await LocaleSettings.useDeviceLocale();
  }

  static Future<void> initializeOnLoading() async {
    try {
      logger.i('🔄 Initializing application...');
      final success = await DataCacheManager().preloadAllData();

      if (!success) {
        throw Exception('📦❌ Failed to preload data');
      }

      logger.i('✅ Initialization complete!');
    } catch (e) {
      logger.e('❌ Error during initialization: $e');
      rethrow;
    }
  }
}
