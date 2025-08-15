import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/home/home_module.dart';

import 'main_flow_model.dart';
import 'main_flow_screen.dart';

class MainFlowModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<MainFlowModel>(MainFlowModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const MainFlowScreen(),
      duration: Duration.zero,
      transition: TransitionType.fadeIn,
      children: [
        ModuleRoute(
          '/home',
          module: HomeModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
      ],
    );
  }
}
