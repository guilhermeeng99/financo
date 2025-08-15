
import 'package:financo/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static Color get textColor => const Color(0xffFFFFFF);

  static TextStyle get defaultTextStyle => TextStyle(
        fontFamily: FontFamily.inter,
        fontSize: 12,
        color: textColor,
        height: 1,
      );

  static ThemeData get lightTheme {
    final defaultTextStyle = AppTheme.defaultTextStyle;

    final theme = ThemeData(
      scaffoldBackgroundColor: const Color(0xff181818),
      dividerColor: const Color(0xffFFFFFF),
      shadowColor: const Color(0xffCCD3EA),
      cardColor: const Color(0xff282828),
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
    this.secondary = const Color(0xff212121),
    this.third = const Color(0xFF282828),
    this.fourth = const Color(0xff232323),
    this.income = const Color(0xff199428),
    this.expense = const Color(0xffCE6050),
    this.button01 = const Color(0xff00A797),
    this.button02 = const Color(0xffFF4081),
  });

  final Color secondary;
  final Color third;
  final Color textColor;
  final Color fourth;
  final Color income;
  final Color expense;
  final Color button01;
  final Color button02;
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
