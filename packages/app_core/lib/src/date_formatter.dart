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

  String formattedDateddMMyyyy({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'dd/MM/yyyy',
    );
  }

  String formattedDateddMM({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'dd/MM',
    );
  }

  String formattedMonthYear({required BuildContext context}) {
    return _formattedDate(
      context: context,
      format: 'MMMM yyyy',
    );
  }
}
