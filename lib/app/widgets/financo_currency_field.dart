import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Brazilian-style currency field. Renders the value as `R$ 2.000,00`
/// using a static `R$` prefix in the decoration plus a real-time
/// formatter that treats user input as cents — every digit shifts the
/// value left, like the Nubank / Itaú apps. The controller text is the
/// numeric part only (`2.000,00`), so callers' existing
/// `parseDecimalAmount` continues to work without special casing the
/// `R$` prefix.
class FinancoCurrencyField extends StatelessWidget {
  const FinancoCurrencyField({
    required this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.hintText,
    this.autofocus = false,
    super.key,
  });

  final String label;
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
      inputFormatters: [BrlCurrencyInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixText: r'R$ ',
      ),
    );
  }
}

/// `TextInputFormatter` that reformats the field on every keystroke into
/// BR-style `1.234,56`. Strategy: pull every digit out of the input,
/// treat the resulting integer as cents (so two trailing zeros = one
/// real), then format with a pt_BR `NumberFormat`. The cursor is parked
/// at the end because the value grows from the right.
class BrlCurrencyInputFormatter extends TextInputFormatter {
  BrlCurrencyInputFormatter();

  // `symbol: ''` keeps locale-aware grouping/decimal separators while
  // letting us draw `R$ ` as a non-editable prefix in the decoration.
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  /// Public so initState() can pre-format an existing model value.
  static String format(double value) => _formatter.format(value).trim();

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
    // 15 — enough for trillions of reais, well under int64 — and ignore
    // the rest so the field never throws under a paste-of-the-Iliad.
    final clamped = digits.length > 15 ? digits.substring(0, 15) : digits;
    final cents = int.parse(clamped);
    final value = cents / 100.0;
    final formatted = format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
