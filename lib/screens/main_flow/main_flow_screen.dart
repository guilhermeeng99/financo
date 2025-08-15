import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/widgets/main_flow_screen_side_bar.dart';
import 'package:financo/screens/main_flow/widgets/main_flow_screen_top_bar.dart';

class MainFlowScreen extends StatelessWidget {
  const MainFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          MainFlowScreenTopBar(),
          Expanded(
            child: Row(
              children: [
                MainFlowScreenSideBar(),
                Expanded(child: RouterOutlet()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
