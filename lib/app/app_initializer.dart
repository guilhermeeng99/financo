import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class AppIntializer {
  static Future<void> initializeBeforeApp() async {
    await LocaleSettings.useDeviceLocale();
  }

  static Future<void> initializeOnLoading() async {
    try {
      final databaseManager = Modular.get<DatabaseManager>();

      await databaseManager.customSelect('SELECT 1').get();

    } catch (e) {
      logger.e('❌ Error during database initialization: $e');
    }
  }
}
