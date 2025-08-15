import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_routes.dart';
import 'package:financo/screens/main_flow/main_flow_bloc.dart';

MainFlowTopBarModel get mainFlowTopBarModel =>
    Modular.get<MainFlowTopBarModel>();

class MainFlowTopBarModel {
  void onTapSideBar() => mainFlowBloc.isSideBarOn.toggle();

  void onTapOverview() => Modular.to.navigate(ro.mainFlow.home.route);

  void onTapSearch() {}

  void onTapCalculator() {}
}

MainFlowSideBarModel get mainFlowSideBarModel =>
    Modular.get<MainFlowSideBarModel>();

class MainFlowSideBarModel {
  void onTapCategories() => Modular.to.navigate(ro.mainFlow.categories.route);

  void onTapAccounts() => Modular.to.navigate(ro.mainFlow.accounts.route);
}
