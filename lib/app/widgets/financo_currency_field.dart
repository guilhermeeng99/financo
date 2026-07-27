import 'package:financo/core/money/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Money input field that adapts to a [currency]. Renders the value as e.g.
/// `R$ 2.000,00`, `$ 2,000.00` or `€ 2.000,00` using the currency's symbol as a
/// static prefix plus a real-time formatter that treats user input as cents —
/// every digit shifts the value left, like the Nubank / Itaú apps. The
/// controller text is the numeric part only (no symbol), and its grouping/
/// decimal separators follow the currency's locale, so callers'
/// `parseDecimalAmount` (which reads both BR and EN styles) continues to work.
///
/// Defaults to [Currency.brl] so existing single-currency call sites keep their
/// `R$` behaviour; multi-currency screens pass the account/asset currency so the
/// field speaks the right money (F9 multi-currency accounts).
class FinancoCurrencyField extends StatelessWidget {
  const FinancoCurrencyField({
    required this.label,
    this.currency = Currency.brl,
    this.controller,
    this.validator,
    this.onChanged,
    this.hintText,
    this.autofocus = false,
    super.key,
  });

  final String label;

  /// The currency the entered amount is denominated in — drives the prefix
  /// symbol and the number formatting.
  final Currency currency;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  /// Grabs focus the moment the field mounts. Used on web so the user can
  /// start typing the amount the instant the new-transaction form opens,
  /// without an extra click. Off by default to avoid popping the mobile
  /// soft keyboard on screens where the amount isn't the primary action.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [CurrencyInputFormatter(currency)],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixText: '${currency.symbol} ',
      ),
    );
  }
}

/// `TextInputFormatter` that reformats the field on every keystroke into the
/// [currency]'s locale style (e.g. `1.234,56` for BRL/EUR, `1,234.56` for USD).
/// Strategy: pull every digit out of the input, treat the resulting integer as
/// cents (so two trailing zeros = one unit), then format with the currency's
/// `NumberFormat`. The cursor is parked at the end because the value grows from
/// the right. The symbol is drawn separately as a non-editable prefix.
class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter([this.currency = Currency.brl]);

  final Currency currency;

  // `symbol: ''` keeps locale-aware grouping/decimal separators while the field
  // draws the currency symbol as a prefix in the decoration. Cached per
  // currency — building a `NumberFormat` is not free.
  static final Map<Currency, NumberFormat> _formatters = {};

  static NumberFormat _formatterFor(Currency currency) =>
      _formatters.putIfAbsent(
        currency,
        () => NumberFormat.currency(
          locale: currency.locale,
          symbol: '',
          decimalDigits: 2,
        ),
      );

  /// Pre-format an existing model [value] in [currency] — used by `initState`
  /// to seed the field from a saved amount.
  static String format(double value, [Currency currency = Currency.brl]) =>
      _formatterFor(currency).format(value).trim();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return TextEditingValue.empty;
    }
    // int.parse can blow up on absurdly long inputs (>19 digits). Cap at
    // 15 — enough for trillions, well under int64 — and ignore the rest so
    // the field never throws under a paste-of-the-Iliad.
    final clamped = digits.length > 15 ? digits.substring(0, 15) : digits;
    final cents = int.parse(clamped);
    final value = cents / 100.0;
    final formatted = format(value, currency);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
