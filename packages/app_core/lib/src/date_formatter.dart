import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateFormatterX on DateTime {
  String _formattedDate({
    required BuildContext context,
    required String format,
  }) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat(format, locale).format(this);
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String formattedDateMMMMd({required BuildContext context}) {
    final locale = Localizations.localeOf(context).toString();
    final isEnglish = locale.startsWith('en');

    final month = DateFormat('MMMM', locale).format(this);
    final day = DateFormat('d', locale).format(this);

    if (isEnglish) {
      final suffix = _getOrdinalSuffix(this.day);
      return '$month $day$suffix';
    }

    return _formattedDate(
      context: context,
      format: 'MMMM d',
    );
  }

  String formattedDateMMMMddyyyy({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'MMMM dd, yyyy',
    );
  }

  String formattedDateMMMddyyyy({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'MMM dd, yyyy',
    );
  }

  String formattedDateMMMyyyy({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'MMM yyyy',
    );
  }

  String formattedDateMMMMyyyy({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'MMMM yyyy',
    );
  }

  String formattedDateMMMMdE({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'MMMM d, E',
    );
  }

  String formattedDateMMMM({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'MMMM',
    );
  }

  String formattedDateHM() {
    final useDate = toLocal();
    final hours = useDate.hour.toString().padLeft(2, '0');
    final minutes = useDate.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String formattedDateTimerHMS() {
    final hourStr = hour.toString();

    final minuteStr = minute.toString().padLeft(2, '0');
    final secondStr = second.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr:$secondStr';
  }
}
