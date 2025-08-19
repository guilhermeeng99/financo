import 'dart:ui';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static double parseAmount(String input, BuildContext context) {
    final locale = Localizations.localeOf(context);

    if (input.isEmpty) return 0;

    try {
      final formatter = NumberFormat.decimalPattern(locale.toString());
      return formatter.parse(input).toDouble();
    } catch (e) {
      return _parseAmountFallback(input, locale);
    }
  }

  static double _parseAmountFallback(String input, Locale locale) {
    var cleanInput = input.replaceAll(' ', '').replaceAll('\u00A0', '');

    final formatter = NumberFormat.decimalPattern(locale.toString());
    final decimalSeparator = _getDecimalSeparator(formatter);
    final groupingSeparator = _getGroupingSeparator(formatter);

    if (decimalSeparator == ',' && groupingSeparator == '.') {
      final parts = cleanInput.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        cleanInput = '${parts[0].replaceAll('.', '')}.${parts[1]}';
      } else {
        cleanInput = cleanInput.replaceAll(',', '').replaceAll('.', '');
      }
    } else {
      cleanInput = cleanInput.replaceAll(',', '');
    }

    return double.tryParse(cleanInput) ?? 0.0;
  }

  static String _getDecimalSeparator(NumberFormat formatter) {
    final formatted = formatter.format(1.1);
    if (formatted.contains(',')) return ',';
    return '.';
  }

  static String _getGroupingSeparator(NumberFormat formatter) {
    final formatted = formatter.format(1000);
    if (formatted.contains('.')) return '.';
    if (formatted.contains(',')) return ',';
    if (formatted.contains(' ')) return ' ';
    return '';
  }

  static String formatAmount(
    double value,
    BuildContext context, {
    String? currencySymbol,
    int decimalDigits = 2,
    bool showSymbol = false,
  }) {
    final locale = Localizations.localeOf(context);

    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: showSymbol ? (currencySymbol ?? '') : '',
      decimalDigits: decimalDigits,
    );

    return formatter.format(value).trim();
  }

  static Locale getCurrentLocale() {
    return PlatformDispatcher.instance.locale;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  const CurrencyInputFormatter({this.locale});

  final Locale? locale;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    final currentLocale = locale ?? CurrencyFormatter.getCurrentLocale();

    final allowedPattern = _getAllowedPattern(currentLocale);

    if (!RegExp(allowedPattern).hasMatch(text)) {
      return oldValue;
    }

    return newValue;
  }

  String _getAllowedPattern(Locale locale) {
    final formatter = NumberFormat.decimalPattern(locale.toString());
    final testNumber = formatter.format(1234.56);

    final hasCommaAsDecimal = testNumber.contains(',') &&
        testNumber.indexOf(',') > testNumber.lastIndexOf('.');
    final hasSpaceAsGrouping = testNumber.contains(' ');

    if (hasCommaAsDecimal) {
      return hasSpaceAsGrouping ? r'^[0-9., ]+$' : r'^[0-9.,]+$';
    } else {
      return hasSpaceAsGrouping ? r'^[0-9., ]+$' : r'^[0-9.,]+$';
    }
  }
}
