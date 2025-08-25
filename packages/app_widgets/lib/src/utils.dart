import 'package:app_widgets/app_widgets.dart';

enum SnackBarType { success, error }

class AppWidgetsUtils {
  static void snackBar({
    required String title,
    required SnackBarType type,
  }) {
    PopUpManager.showSnackBar(
      SnackBar(
        content: Text(title),
        backgroundColor:
            type == SnackBarType.success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
