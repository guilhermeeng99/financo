import 'package:app_core/app_core.dart';
import 'package:financo/app/index.dart';

class LoadingModel {
  final ValueNotifier<bool> hasError = ValueNotifier(false);

  Future<void> initialize() async {
    try {
      hasError.value = false;

      await AppIntializer.initializeOnLoading();

      await Future.delayed(const Duration(milliseconds: 500));

      Modular.to.navigate(ro.mainFlow.home.route);
    } on Exception catch (e) {
      hasError.value = true;

      logger.e('LoadingScreen Error: $e');
    }
  }

  Future<void> retry() async {
    await initialize();
  }

  void dispose() {
    hasError.dispose();
  }
}
