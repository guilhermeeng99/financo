import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/main_flow_item.dart';

MainFlowBloc get mainFlowBloc => Modular.get<MainFlowBloc>();

class MainFlowBloc extends GetxController {
  Rx<bool> isSideBarOn = false.obs;
  Rx<SideBarItem?> selectedSideBarItem = Rx<SideBarItem?>(null);
  RxSet<SideBarItem> expandedItems = <SideBarItem>{}.obs;

  void selectSideBarItem(SideBarItem item) {
    if (item.route != null) {
      selectedSideBarItem.value = item;
      isSideBarOn.value = false;
      Modular.to.navigate(item.route!);
    }
  }

  void toggleSideBarItem(SideBarItem item) {
    if (expandedItems.contains(item)) {
      expandedItems.remove(item);
    } else {
      expandedItems.add(item);
    }
    expandedItems.refresh();
  }

  bool isItemExpanded(SideBarItem item) {
    return expandedItems.contains(item);
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
