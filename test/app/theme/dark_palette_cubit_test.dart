import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/app/theme/dark_palette_cubit.dart';
import 'package:financo/app/theme/dark_palettes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('DarkPaletteCubit', () {
    test('defaults to midnightIndigo and applies it to AppColors.dark',
        () async {
      final cubit = DarkPaletteCubit(prefs: await prefsWith({}));
      addTearDown(cubit.close);
      expect(cubit.state, DarkPalette.midnightIndigo);
      expect(
        AppColors.dark,
        DarkPalettes.byId(DarkPalette.midnightIndigo).colors,
      );
    });

    test('restores a persisted palette on construction', () async {
      final cubit = DarkPaletteCubit(
        prefs: await prefsWith({'dark_palette': 'pureBlack'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, DarkPalette.pureBlack);
      expect(
        AppColors.dark,
        DarkPalettes.byId(DarkPalette.pureBlack).colors,
      );
    });

    test('falls back to the default when the stored name is unknown',
        () async {
      final cubit = DarkPaletteCubit(
        prefs: await prefsWith({'dark_palette': 'glitter'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, DarkPalette.midnightIndigo);
    });

    test('setPalette emits, persists and swaps the active colors', () async {
      final prefs = await prefsWith({});
      final cubit = DarkPaletteCubit(prefs: prefs);
      addTearDown(cubit.close);

      await cubit.setPalette(DarkPalette.deepOcean);

      expect(cubit.state, DarkPalette.deepOcean);
      expect(prefs.getString('dark_palette'), 'deepOcean');
      expect(
        AppColors.dark,
        DarkPalettes.byId(DarkPalette.deepOcean).colors,
      );
    });
  });
}
