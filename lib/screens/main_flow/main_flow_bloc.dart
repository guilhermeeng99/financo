import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/main_flow_item.dart';

MainFlowBloc get mainFlowBloc => Modular.get<MainFlowBloc>();

class MainFlowBloc extends GetxController {
  Rx<bool> isSideBarOn = false.obs;
  Rx<SideBarItemType?> selectedSideBarItem = Rx<SideBarItemType?>(null);
  RxSet<SideBarItemType> expandedItems = <SideBarItemType>{}.obs;

  void selectSideBarItem(SideBarItemType type) {
    if (type.route != null) {
      selectedSideBarItem.value = type;
      isSideBarOn.value = false;
      Modular.to.navigate(type.route!);
    }
  }

  void toggleSideBarItem(SideBarItemType type) {
    if (expandedItems.contains(type)) {
      expandedItems.remove(type);
    } else {
      expandedItems.add(type);
    }
  }

  bool isItemExpanded(SideBarItemType type) {
    return expandedItems.contains(type);
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
    expandedItems.close();
    super.onClose();
  }
}
