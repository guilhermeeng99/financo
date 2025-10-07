import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/main_flow_item.dart';

class MainFlowScreenTopBar extends StatelessWidget {
  const MainFlowScreenTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).customColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        spacing: 9,
        children: [
          _Item(mainFlowTopBarController.sideBarItem),
          const _OverviewItem(),
          const Spacer(),
          _Item(mainFlowTopBarController.profileItem),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem();

  @override
  Widget build(BuildContext context) {
    final item = mainFlowTopBarController.overviewItem;

    return CWAnimatedScaleButtonWidget(
      onTap: item.onTap,
      child: ColoredBox(
        color: Colors.transparent,
        child: Row(
          children: [
            Text(context.t.navigation.overview),
            const Gap(9),
            const CWDivider(),
            const Gap(12),
            Icon(item.icon, size: 24),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.item);

  final TopBarItem item;

  @override
  Widget build(BuildContext context) {
    return CWAnimatedScaleButtonWidget(
      onTap: item.onTap,
      child: Icon(item.icon, size: 24),
    );
  }
}
