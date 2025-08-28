import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/main_flow_bloc.dart';

class MainFlowScreenSideBar extends StatelessWidget {
  const MainFlowScreenSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSideBarOn = mainFlowBloc.isSideBarOn.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isSideBarOn ? 300 : 0,
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          children: mainFlowSideBarController.sideBarItems
              .map(_Item.new)
              .toList(),
        ),
      );
    });
  }
}

class _Item extends StatelessWidget {
  const _Item(this.item);

  final SideBarItem item;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedItem = mainFlowBloc.selectedSideBarItem.value;
      final isSelected = selectedItem == item.type;

      return CWAnimatedScaleButtonWidget(
        onTap: item.onTap,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
          child: Row(
            children: [
              if (item.icon != null)
                SvgPicture.asset(
                  item.icon!,
                  width: 16,
                  height: 16,
                  colorFilter: isSelected
                      ? ColorFilter.mode(
                          Theme.of(context).customColors.button02,
                          BlendMode.srcIn,
                        )
                      : null,
                ),
              const SizedBox(width: 8),
              Text(
                item.title(context),
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).customColors.button02
                      : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
