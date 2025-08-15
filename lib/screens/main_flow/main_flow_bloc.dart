import 'package:app_core/app_core.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:financo/screens/main_flow/main_flow_model.dart';

MainFlowBloc get mainFlowBloc => Modular.get<MainFlowBloc>();

class MainFlowBloc extends GetxController {
  Rx<bool> isSideBarOn = false.obs;

  @override
  void onClose() {
    isSideBarOn.close();
    super.onClose();
  }
}

class TopBarItem {
  const TopBarItem({required this.onTap, required this.icon});

  final String icon;
  final void Function() onTap;
}

MainFlowTopBarController get mainFlowTopBarController =>
    Modular.get<MainFlowTopBarController>();

class MainFlowTopBarController {
  final List<TopBarItem> topBarItems = [
    TopBarItem(onTap: mainFlowTopBarModel.onTapSideBar, icon: svgs.filter),
    TopBarItem(onTap: mainFlowTopBarModel.onTapOverview, icon: svgs.chartPie),
    TopBarItem(onTap: mainFlowTopBarModel.onTapSearch, icon: svgs.search),
    TopBarItem(onTap: mainFlowTopBarModel.onTapCalculator, icon: svgs.calc),
  ];
}

class SideBarItem {
  const SideBarItem({required this.title, required this.onTap, this.icon});

  final String Function(BuildContext context) title;
  final String? icon;
  final void Function() onTap;
}

MainFlowSideBarController get mainFlowSideBarController =>
    Modular.get<MainFlowSideBarController>();

class MainFlowSideBarController {
  final List<SideBarItem> sideBarItems = [
    SideBarItem(
      title: (context) => context.t.categories,
      onTap: mainFlowSideBarModel.onTapCategories,
    ),
    SideBarItem(
      title: (context) => context.t.accounts,
      onTap: mainFlowSideBarModel.onTapAccounts,
    ),
  ];
}
