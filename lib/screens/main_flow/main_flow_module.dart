import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/main_flow_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/accounts_module.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_module.dart';
import 'package:financo/screens/main_flow/screens/home/home_module.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_module.dart';

import 'main_flow_model.dart';
import 'main_flow_screen.dart';

class MainFlowModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<MainFlowTopBarModel>(MainFlowTopBarModel.new)
      ..addSingleton<MainFlowTopBarController>(MainFlowTopBarController.new)
      ..addSingleton<MainFlowSideBarController>(MainFlowSideBarController.new)
      ..addSingleton<MainFlowBloc>(MainFlowBloc.new);
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
        ModuleRoute(
          '/categories',
          module: CategoriesModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          '/accounts',
          module: AccountsModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
        ModuleRoute(
          '/releases',
          module: ReleasesModule(),
          duration: Duration.zero,
          transition: TransitionType.fadeIn,
        ),
      ],
    );
  }
}
