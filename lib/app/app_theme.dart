
import 'package:financo/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static Color get textColor => const Color(0xff273050);

  static TextStyle get defaultTextStyle => TextStyle(
        fontFamily: FontFamily.inter,
        fontSize: 20,
        color: textColor,
        height: 1,
      );

  static ThemeData get lightTheme {
    final defaultTextStyle = AppTheme.defaultTextStyle;

    final theme = ThemeData(
      scaffoldBackgroundColor: const Color(0xffECEFF9),
      dividerColor: const Color(0xffCCD3EA),
      shadowColor: const Color(0xffCCD3EA),
      cardColor: const Color(0xffF9F9F9),
      inputDecorationTheme: const InputDecorationTheme(isCollapsed: true),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(),
      canvasColor: Colors.transparent,
      textTheme: TextTheme(
        titleLarge: defaultTextStyle,
        titleMedium: defaultTextStyle,
        titleSmall: defaultTextStyle,
        bodyLarge: defaultTextStyle,
        bodyMedium: defaultTextStyle,
        bodySmall: defaultTextStyle,
        displayLarge: defaultTextStyle,
        displayMedium: defaultTextStyle,
        displaySmall: defaultTextStyle,
        labelLarge: defaultTextStyle,
        labelMedium: defaultTextStyle,
        labelSmall: defaultTextStyle,
      ),
    );

    return theme.copyWithCustomColors(
      CustomColorsData(textColor: textColor),
    );
  }
}

class CustomColorsData {
  const CustomColorsData({
    required this.textColor,
    this.secondary = const Color(0xff8AB0D9),
    this.third = const Color(0xFFC3E0FE),
    this.fourth = const Color(0xff4E80B4),
    this.fifth = const Color(0xff9DB7D6),
    this.sixth = const Color(0xff83BFFF),
  });

  final Color secondary;
  final Color third;
  final Color textColor;
  final Color fourth;
  final Color fifth;
  final Color sixth;
}

extension CustomColorsTheme on ThemeData {
  static final Map<ThemeData, CustomColorsData> _customColors = {};

  ThemeData copyWithCustomColors(CustomColorsData customColors) {
    _customColors[this] = customColors;
    return this;
  }

  CustomColorsData get customColors {
    return _customColors[this] ??
        CustomColorsData(textColor: AppTheme.textColor);
  }
}
