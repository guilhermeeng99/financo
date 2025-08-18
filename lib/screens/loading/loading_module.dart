import 'package:app_core/app_core.dart';

import 'loading_screen.dart';

class LoadingModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<LoadingScreen>(LoadingScreen.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const LoadingScreen());
  }
}
