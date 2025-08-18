import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_constants.dart';
import 'package:financo/app/app_theme.dart';

import 'loading_model.dart';

class LoadingScreen extends HookWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = useMemoized(LoadingModel.new);

    useEffect(() {
      model.initialize();
      return model.dispose;
    }, [model]);

    return Material(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 50,
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).customColors.button02,
                fontWeight: FontWeight.bold,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: model.hasError,
              builder: (context, hasError, child) {
                if (hasError) {
                  return Icon(
                    Icons.error_outline,
                    size: 100,
                    color: Theme.of(context).colorScheme.error,
                  );
                }
                return LoadingAnimationWidget.threeRotatingDots(
                  color: Theme.of(context).customColors.button02,
                  size: 100,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
