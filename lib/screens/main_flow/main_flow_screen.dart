import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/main_flow_bloc.dart';
import 'package:financo/screens/main_flow/widgets/main_flow_screen_side_bar.dart';
import 'package:financo/screens/main_flow/widgets/main_flow_screen_top_bar.dart';

class MainFlowScreen extends StatelessWidget {
  const MainFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MainFlowScreenTopBar(),
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    const MainFlowScreenSideBar(),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (mainFlowBloc.isSideBarOn.value) {
                            mainFlowBloc.isSideBarOn.value = false;
                          }
                        },
                        child: const RouterOutlet(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
