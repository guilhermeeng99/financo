import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';
import 'package:financo/screens/loading/loading_module.dart';
import 'package:financo/screens/main_flow/main_flow_module.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [
    AppDatabaseModule(),
  ];

  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r
      ..module('/loading', module: LoadingModule())
      ..module('/main_flow', module: MainFlowModule());
  }
}
