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
    primary: Color(0xFF1A2B4A),
    primaryLight: Color(0xFF2E4A7A),
    primaryDark: Color(0xFF0D1B2A),
    secondary: Color(0xFF00B4D8),
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEDF0F5),
    onBackground: Color(0xFF1B1B1B),
    onBackgroundLight: Color(0xFF6B7280),
    income: Color(0xFF10B981),
    expense: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
  );

  static const dark = AppColorsData(
    primary: Color(0xFF4A7CC9),
    primaryLight: Color(0xFF6B9FE8),
    primaryDark: Color(0xFF2E5A9E),
    secondary: Color(0xFF00D1FF),
    background: Color(0xFF0D1117),
    surface: Color(0xFF161B22),
    surfaceVariant: Color(0xFF21262D),
    onBackground: Color(0xFFE6EDF3),
    onBackgroundLight: Color(0xFF8B949E),
    income: Color(0xFF34D399),
    expense: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
  );
}
