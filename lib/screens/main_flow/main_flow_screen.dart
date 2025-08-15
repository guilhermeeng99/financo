import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

class MainFlowScreen extends StatelessWidget {
  const MainFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(children: [_TopBar()]),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Theme.of(context).customColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          SvgPicture.asset(svgs.filter, width: 18, height: 17),
          const Gap(9),
          Text(context.t.common.overview),
        ],
      ),
    );
  }
}
