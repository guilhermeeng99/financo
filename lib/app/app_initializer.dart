import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';

class AppIntializer {
  static Future<void> initializeBeforeApp() async {}

  static Future<void> initializeOnLoading() async {
    try {
      logger.i('🔄 Inicializando banco de dados...');
      await DatabaseService().initialize();
      logger.i('✅ Inicialização completa!');
    } catch (e) {
      logger.e('❌ Erro na inicialização: $e');
    }
  }
}
