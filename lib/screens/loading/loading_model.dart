import 'package:app_core/app_core.dart';
import 'package:financo/app/index.dart';

LoadingModel get loadingModel => Modular.get<LoadingModel>();

class LoadingModel {
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 4));
    await AppIntializer.initializeOnLoading();
    Modular.to.navigate(ro.mainFlow.home.route);
  }
}
