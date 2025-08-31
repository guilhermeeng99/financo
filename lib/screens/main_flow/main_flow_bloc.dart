import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_routes.dart';
import 'package:financo/screens/main_flow/main_flow_model.dart';

MainFlowBloc get mainFlowBloc => Modular.get<MainFlowBloc>();

class MainFlowBloc extends GetxController {
  Rx<bool> isSideBarOn = false.obs;
  Rx<SideBarItemType?> selectedSideBarItem = Rx<SideBarItemType?>(null);

  void selectSideBarItem(SideBarItemType type) {
    selectedSideBarItem.value = type;
    isSideBarOn.value = false;
    Modular.to.navigate(type.route);
  }

  void clearSelection() {
    selectedSideBarItem.value = null;
  }

  void toggleSideBar() {
    isSideBarOn.toggle();
  }

  @override
  void onClose() {
    isSideBarOn.close();
    selectedSideBarItem.close();
    super.onClose();
  }
}

class TopBarItem {
  const TopBarItem({required this.onTap, required this.icon});

  final IconData icon;
  final void Function() onTap;
}

MainFlowTopBarController get mainFlowTopBarController =>
    Modular.get<MainFlowTopBarController>();

class MainFlowTopBarController {
  final List<TopBarItem> topBarItems = [
    TopBarItem(onTap: mainFlowTopBarModel.onTapSideBar, icon: Icons.menu),
    TopBarItem(onTap: mainFlowTopBarModel.onTapOverview, icon: Icons.pie_chart),
  ];
}


enum SideBarItemType {
  releases,
  categories,
  accounts;

  String get route {
    switch (this) {
      case SideBarItemType.releases:
        return ro.mainFlow.releases.route;
      case SideBarItemType.categories:
        return ro.mainFlow.categories.route;
      case SideBarItemType.accounts:
        return ro.mainFlow.accounts.route;
    }
  }

  String title(BuildContext context) {
    switch (this) {
      case SideBarItemType.releases:
        return context.t.navigation.releases;
      case SideBarItemType.categories:
        return context.t.navigation.categories;
      case SideBarItemType.accounts:
        return context.t.navigation.accounts;
    }
  }

  String? get icon => null; 
}


class SideBarItem {
  const SideBarItem({
    required this.type,
    this.icon,
  });

  final SideBarItemType type;
  final String? icon;

  String title(BuildContext context) => type.title(context);
  void Function() get onTap => () => mainFlowBloc.selectSideBarItem(type);
}

MainFlowSideBarController get mainFlowSideBarController =>
    Modular.get<MainFlowSideBarController>();

class MainFlowSideBarController {
  final List<SideBarItem> sideBarItems = SideBarItemType.values
      .map((type) => SideBarItem(type: type))
      .toList();
}
