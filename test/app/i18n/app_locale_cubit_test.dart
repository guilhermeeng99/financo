import 'package:financo/app/i18n/app_locale_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('AppLocaleCubit', () {
    test('defaults to follow-system (null) when nothing is stored', () async {
      final cubit = AppLocaleCubit(prefs: await prefsWith({}));
      addTearDown(cubit.close);
      expect(cubit.state, isNull);
    });

    test('restores a persisted language tag on construction', () async {
      final cubit = AppLocaleCubit(
        prefs: await prefsWith({'app_locale': 'pt-BR'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, AppLocale.ptBr);
      expect(LocaleSettings.currentLocale, AppLocale.ptBr);
    });

    test('treats the system sentinel as follow-system', () async {
      final cubit = AppLocaleCubit(
        prefs: await prefsWith({'app_locale': 'system'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, isNull);
    });

    test('ignores an unknown persisted tag', () async {
      final cubit = AppLocaleCubit(
        prefs: await prefsWith({'app_locale': 'xx-YY'}),
      );
      addTearDown(cubit.close);
      expect(cubit.state, isNull);
    });

    test('setLocale persists the tag, emits and applies the locale',
        () async {
      final prefs = await prefsWith({});
      final cubit = AppLocaleCubit(prefs: prefs);
      addTearDown(cubit.close);

      await cubit.setLocale(AppLocale.ptBr);

      expect(cubit.state, AppLocale.ptBr);
      expect(prefs.getString('app_locale'), 'pt-BR');
      expect(LocaleSettings.currentLocale, AppLocale.ptBr);
    });

    test('setLocale(null) stores the system sentinel', () async {
      final prefs = await prefsWith({'app_locale': 'en'});
      final cubit = AppLocaleCubit(prefs: prefs);
      addTearDown(cubit.close);

      await cubit.setLocale(null);

      expect(cubit.state, isNull);
      expect(prefs.getString('app_locale'), 'system');
    });

    test('activeFlutterLocale resolves the explicit choice when set',
        () async {
      final cubit = AppLocaleCubit(
        prefs: await prefsWith({'app_locale': 'pt-BR'}),
      );
      addTearDown(cubit.close);
      expect(cubit.activeFlutterLocale(), AppLocale.ptBr);
    });

    test('activeFlutterLocale falls back to the device locale on system',
        () async {
      final cubit = AppLocaleCubit(prefs: await prefsWith({}));
      addTearDown(cubit.close);
      expect(
        cubit.activeFlutterLocale(),
        AppLocaleUtils.findDeviceLocale(),
      );
    });
  });
}
