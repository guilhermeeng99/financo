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

  /// Foreground for content sitting **on** [primary] — a filled button's
  /// label, a selected chip's icon, the outgoing chat bubble's text.
  ///
  /// A computed getter rather than a 24th palette field on purpose: it is
  /// fully determined by [primary], and every one of the 23 catalog palettes
  /// would otherwise have to hand-pick it (and could get it wrong). Before
  /// this existed, ~30 sites hardcoded `Colors.white`, which is only correct
  /// while every selectable palette happens to have a dark primary.
  Color get onPrimary => foregroundOn(primary);

  /// Dimming layer behind a modal, an image overlay or a chart tooltip.
  /// Always black; callers choose the alpha for their context.
  Color get scrim => const Color(0xFF000000);
}

/// Picks black or white for text/icons drawn on [background].
///
/// Used wherever the backdrop is an arbitrary colour the theme does not own —
/// a bank's brand colour, a user-picked category colour, an asset-kind tint —
/// so a semantic token cannot answer the question. Three copies of this
/// luminance check existed before the 2026-07-31 audit (`bank_avatar.dart`,
/// `dashboard_institution_row.dart`, `asset_visuals.dart`), all with the same
/// 0.55 threshold.
///
/// The threshold sits above 0.5 because mid-tone brand colours read better
/// with white than the raw midpoint suggests.
///
/// Example:
/// ```dart
/// final fg = foregroundOn(Color(brand.color));
/// ```
Color foregroundOn(Color background) => background.computeLuminance() > 0.55
    ? const Color(0xFF000000)
    : const Color(0xFFFFFFFF);

class AppColors {
  const AppColors._();

  // The active palettes are mutable so the user can pick any of the
  // catalog options at runtime (LightPaletteCubit / DarkPaletteCubit drive
  // these). Defaults are the originals.
  static AppColorsData light = defaultLight;
  static AppColorsData dark = defaultDark;

  static const defaultLight = AppColorsData(
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

  static const defaultDark = AppColorsData(
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
