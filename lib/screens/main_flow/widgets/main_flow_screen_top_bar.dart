import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/main_flow_bloc.dart';

class MainFlowScreenTopBar extends StatelessWidget {
  const MainFlowScreenTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).customColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          _Item(mainFlowTopBarController.topBarItems[0]),
          const Gap(9),
          Text(context.t.navigation.overview),
          const Gap(9),
          const CWDivider(),
          const Gap(12),
          _Item(mainFlowTopBarController.topBarItems[1]),
        ],
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
