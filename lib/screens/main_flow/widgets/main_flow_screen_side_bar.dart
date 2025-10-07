import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/main_flow_bloc.dart';
import 'package:financo/screens/main_flow/main_flow_item.dart';

class MainFlowScreenSideBar extends StatelessWidget {
  const MainFlowScreenSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSideBarOn = mainFlowBloc.isSideBarOn.value;

      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0, end: isSideBarOn ? 1 : 0),
        builder: (context, factor, child) {
          return Align(
            alignment: Alignment.centerLeft,
            widthFactor: factor,
            child: child,
          );
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.only(top: 25),
          child: IntrinsicWidth(
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mainFlowSideBarController.flattenedItems
                    .map(_Item.new)
                    .toList(),
              );
            }),
          ),
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
      final isSelected = selectedItem == item;
      final isExpanded = item.isParent && mainFlowBloc.isItemExpanded(item);

      return CWAnimatedScaleButtonWidget(
        onTap: item.onTap,
        scale: item.isParent ? 1.0 : 1.1,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 20 + (item.level * 20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.level > 0) const Gap(15),
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).customColors.button02
                      : null,
                ),
                const Gap(10),
              ],
              Text(
                item.title(context),
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).customColors.button02
                      : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Gap(8),
              if (item.isParent)
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 30,
                  color: isSelected
                      ? Theme.of(context).customColors.button02
                      : null,
                ),
              const Gap(15),
            ],
          ),
        ),
      );
    });
  }
}
