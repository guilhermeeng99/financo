import 'package:flutter/material.dart';

class AppColorsData {
  const AppColorsData({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onBackground,
    required this.onBackgroundLight,
    required this.income,
    required this.expense,
    required this.warning,
    required this.success,
    required this.error,
  });

  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onBackground;
  final Color onBackgroundLight;
  final Color income;
  final Color expense;
  final Color warning;
  final Color success;
  final Color error;
}

class AppColors {
  const AppColors._();

  static const light = AppColorsData(
    primary: Color(0xFF5B5FEF),
    primaryLight: Color(0xFF7C83FF),
    primaryDark: Color(0xFF3F43C9),

    secondary: Color(0xFF22C55E),

    background: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEEF0F6),

    onBackground: Color(0xFF1A1B1F),
    onBackgroundLight: Color(0xFF6B7280),

    income: Color(0xFF22C55E),
    expense: Color(0xFFEF4444),

    warning: Color(0xFFF59E0B),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
  );

  static const dark = AppColorsData(
    primary: Color(0xFF7C83FF),
    primaryLight: Color(0xFFA5ABFF),
    primaryDark: Color(0xFF5B5FEF),

    secondary: Color(0xFF22C55E),

    background: Color(0xFF0F1117),
    surface: Color(0xFF181C24),
    surfaceVariant: Color(0xFF212632),

    onBackground: Color(0xFFE6E9F0),
    onBackgroundLight: Color(0xFF9AA3B2),

    income: Color(0xFF22C55E),
    expense: Color(0xFFF87171),

    warning: Color(0xFFFBBF24),
    success: Color(0xFF22C55E),
    error: Color(0xFFF87171),
  );
}
