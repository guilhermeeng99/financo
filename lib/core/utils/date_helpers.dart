import 'package:financo/gen/i18n/strings.g.dart';
import 'package:intl/intl.dart';

/// User's active locale as an Intl tag (e.g. `pt_BR`, `en`). Drives every
/// locale-aware [DateFormat] in the app — keep this the single source of
/// truth so date display stays consistent across screens after a language
/// switch.
String _currentLocaleTag() {
  final locale = LocaleSettings.instance.currentLocale;
  final country = locale.countryCode;
  if (country == null) return locale.languageCode;
  return '${locale.languageCode}_$country';
}

/// Full date: `01/05/2026` in pt-BR, `5/1/2026` in en. Pass [locale] to
/// override (chat handlers do this when the conversation language differs
/// from the app UI locale).
String formatDate(DateTime date, {String? locale}) =>
    DateFormat.yMd(locale ?? _currentLocaleTag()).format(date);

/// Month + year: `maio de 2026` in pt-BR, `May 2026` in en.
String formatMonthYear(DateTime date, {String? locale}) =>
    DateFormat.yMMMM(locale ?? _currentLocaleTag()).format(date);

/// Day + month: `01/05` in pt-BR, `5/1` in en. Numeric, no year — used
/// in compact tile views.
String formatDayMonth(DateTime date, {String? locale}) =>
    DateFormat.Md(locale ?? _currentLocaleTag()).format(date);

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

DateTime endOfMonth(DateTime date) =>
    DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
