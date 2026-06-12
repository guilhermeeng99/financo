import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/app/theme/light_palette_cubit.dart';
import 'package:financo/app/theme/light_palettes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('LightPaletteCubit', () {
    test('defaults to indigoCloud and applies it to AppColors.light',
        () async {
      final cubit = LightPaletteCubit(prefs: await prefsWith({}));
      addTearDown(cubit.close);
      expect(cubit.state, LightPalette.indigoCloud);
      expect(
        AppColors.light,
        LightPalettes.byId(LightPalette.indigoCloud).colors,
      );
    });

    test('restores a persisted palette on construction', () async {
      final cubit = LightPaletteCubit(
        prefs: await prefsWith({'light_palette': 'mintFresh'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, LightPalette.mintFresh);
      expect(
        AppColors.light,
        LightPalettes.byId(LightPalette.mintFresh).colors,
      );
    });

    test('falls back to the default when the stored name is unknown',
        () async {
      final cubit = LightPaletteCubit(
        prefs: await prefsWith({'light_palette': 'doesNotExist'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, LightPalette.indigoCloud);
    });

    test('setPalette emits, persists and swaps the active colors', () async {
      final prefs = await prefsWith({});
      final cubit = LightPaletteCubit(prefs: prefs);
      addTearDown(cubit.close);

      await cubit.setPalette(LightPalette.oceanBreeze);

      expect(cubit.state, LightPalette.oceanBreeze);
      expect(prefs.getString('light_palette'), 'oceanBreeze');
      expect(
        AppColors.light,
        LightPalettes.byId(LightPalette.oceanBreeze).colors,
      );
    });
  });
}
