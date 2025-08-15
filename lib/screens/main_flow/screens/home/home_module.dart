import 'package:app_core/app_core.dart';

import 'home_model.dart';
import 'home_screen.dart';

class HomeModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<HomeModel>(HomeModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const HomeScreen());
  }
}
