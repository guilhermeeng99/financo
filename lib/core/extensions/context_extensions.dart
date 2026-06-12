import 'package:financo/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  AppColorsData get appColors => isDarkMode ? AppColors.dark : AppColors.light;

  /// Shows a plain-text snackbar — the project's default feedback channel.
  ///
  /// Replaces the
  /// `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` boilerplate
  /// for simple confirmations and errors. Snackbars needing actions, custom
  /// content, or durations still call `ScaffoldMessenger` directly.
  ///
  /// Example:
  /// ```dart
  /// context.showSnack(t.accounts.accountCreated);
  /// ```
  void showSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
