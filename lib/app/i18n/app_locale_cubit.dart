import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';
const _systemSentinel = 'system';

/// User-facing locale preference.
///
/// `null` means "follow system" — slang's [AppLocaleUtils.findDeviceLocale]
/// picks the closest supported [AppLocale] from the device locale. Any
/// explicit choice is persisted and survives restarts.
class AppLocaleCubit extends Cubit<AppLocale?> {
  AppLocaleCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(null) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final stored = _prefs.getString(_localeKey);
    final resolved = _resolveStored(stored);
    // Sync apply for the very first frame so the boot UI is already in the
    // right language. setLocale (async) is used afterwards because it also
    // pings TranslationProvider listeners, forcing the running widget tree
    // to rebuild with the new strings.
    LocaleSettings.setLocaleSync(resolved ?? AppLocaleUtils.findDeviceLocale());
    if (resolved != state) emit(resolved);
  }

  Future<void> setLocale(AppLocale? locale) async {
    await _prefs.setString(
      _localeKey,
      locale == null ? _systemSentinel : _languageTag(locale),
    );
    await LocaleSettings.setLocale(
      locale ?? AppLocaleUtils.findDeviceLocale(),
    );
    emit(locale);
  }

  AppLocale activeFlutterLocale() =>
      state ?? AppLocaleUtils.findDeviceLocale();

  AppLocale? _resolveStored(String? stored) {
    if (stored == null || stored == _systemSentinel) return null;
    return AppLocale.values
        .where((l) => _languageTag(l) == stored)
        .firstOrNull;
  }

  static String _languageTag(AppLocale locale) {
    if (locale.countryCode == null) return locale.languageCode;
    return '${locale.languageCode}-${locale.countryCode}';
  }
}
