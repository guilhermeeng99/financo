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
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final totalCents = int.parse(digitsOnly);

    final reais = totalCents ~/ 100;
    final centavos = totalCents % 100;

    final formattedReais = _formatWithThousands(reais);

    final formattedCentavos = centavos.toString().padLeft(2, '0');

    final formattedText = '$formattedReais,$formattedCentavos';

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatWithThousands(int number) {
    if (number == 0) return '0';

    final numberStr = number.toString();
    var result = '';
    var count = 0;

    for (var i = numberStr.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result = '.$result';
      }
      result = '${numberStr[i]}$result';
      count++;
    }

    return result;
  }
}
