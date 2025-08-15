import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

import 'loading_model.dart';

class LoadingScreen extends HookWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      loadingModel.initialize();
      return null;
    }, const []);
    return Material(
      child: Center(
        child: LoadingAnimationWidget.threeRotatingDots(
          color: Theme.of(context).customColors.button02,
          size: 100,
        ),
      ),
    );
  }
}
