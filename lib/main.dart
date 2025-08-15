import 'package:app_core/app_core.dart';
import 'package:financo/app/index.dart';

void main() async {
  await AppIntializer.initializeBeforeApp();
  _errorTrack();
  runApp(const AppWidget());
}

void _errorTrack() {
  FlutterError.onError = (FlutterErrorDetails details) {
    final isRenderFlexOverflowed = details.exceptionAsString().contains(
      'A RenderFlex overflowed by',
    );
    if (!isRenderFlexOverflowed) {
      FlutterError.dumpErrorToConsole(details);
    }
  };
}
