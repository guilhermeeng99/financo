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
}
