import 'package:app_widgets/app_widgets.dart';

enum SnackBarType { success, error }

class AppWidgetsUtils {
  static void snackBar({
    required BuildContext context,
    required SnackBarType type,
  }) {
    PopUpManager.showSnackBar(
      SnackBar(
        content: Text(
          type == SnackBarType.success
              ? context.t.export_successfully
              : context.t.export_error,
        ),
        backgroundColor:
            type == SnackBarType.success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
