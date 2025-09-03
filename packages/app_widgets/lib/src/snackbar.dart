import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

enum SnackBarType { success, info, error, warning }

class CWSnackBar {
  static void snackBar({
    required String title,
    required SnackBarType type,
  }) {
    final theme = Theme.of(currentContext);

    PopUpManager.showSnackBar(
      SnackBar(
        content: Row(
          spacing: 12,
          children: [
            Icon(
              _getSnackBarIcon(type),
              color: Colors.white,
              size: 20,
            ),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getSnackBarColor(type, theme),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Color _getSnackBarColor(SnackBarType type, ThemeData theme) {
    switch (type) {
      case SnackBarType.success:
        return theme.customColors.income;
      case SnackBarType.info:
        return theme.customColors.button01;
      case SnackBarType.warning:
        return Colors.orange[700]!;
      case SnackBarType.error:
        return theme.customColors.expense;
    }
  }

  static IconData _getSnackBarIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.info:
        return Icons.info_outline;
      case SnackBarType.warning:
        return Icons.warning_outlined;
      case SnackBarType.error:
        return Icons.error_outline;
    }
  }
}
