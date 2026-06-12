import 'package:financo/app/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('ThemeCubit', () {
    test('defaults to system when nothing is stored', () async {
      final cubit = ThemeCubit(prefs: await prefsWith({}));
      addTearDown(cubit.close);
      expect(cubit.state, ThemeMode.system);
    });

    test('restores the persisted mode on construction', () async {
      final cubit = ThemeCubit(
        prefs: await prefsWith({'theme_mode': 'dark'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, ThemeMode.dark);
    });

    test('ignores an unknown persisted value', () async {
      final cubit = ThemeCubit(
        prefs: await prefsWith({'theme_mode': 'neon'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, ThemeMode.system);
    });

    test('setThemeMode emits and persists the choice', () async {
      final prefs = await prefsWith({});
      final cubit = ThemeCubit(prefs: prefs);
      addTearDown(cubit.close);

      await cubit.setThemeMode(ThemeMode.light);

      expect(cubit.state, ThemeMode.light);
      expect(prefs.getString('theme_mode'), 'light');
    });
  });
}
