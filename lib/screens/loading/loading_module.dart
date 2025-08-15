import 'package:app_core/app_core.dart';

import 'loading_model.dart';
import 'loading_screen.dart';

class LoadingModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<LoadingModel>(LoadingModel.new)
      ..addSingleton<LoadingScreen>(LoadingScreen.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const LoadingScreen());
  }
}
