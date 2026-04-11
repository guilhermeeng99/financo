import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'theme_mode';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(ThemeMode.system) {
    _loadThemeMode();
  }

  final SharedPreferences _prefs;

  void _loadThemeMode() {
    final value = _prefs.getString(_themeKey);
    if (value == null) return;
    final mode = ThemeMode.values.where((m) => m.name == value).firstOrNull;
    if (mode != null) emit(mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
    emit(mode);
  }
}
