/// Parses a decimal number that may use Brazilian (`421,95`, `1.234,56`)
/// or English (`421.95`, `1,234.56`) formatting, preserving the sign.
///
/// Strategy: when both `,` and `.` are present, the rightmost one is the
/// decimal separator and the other is treated as a thousands grouper and
/// stripped. With only one separator, that one is the decimal. A leading
/// `-` keeps the result negative.
///
/// Returns `null` when the input is empty or cannot be parsed — callers
/// can choose between fallback (e.g. `?? 0`) or surfacing a validation
/// error to the user.
///
/// Example:
/// ```dart
/// parseDecimalAmount('-431,72'); // -> -431.72
/// parseDecimalAmount('1.234,56'); // -> 1234.56
/// parseDecimalAmount('1,234.56'); // -> 1234.56
/// parseDecimalAmount('foo'); // -> null
/// ```
double? parseDecimalAmount(String raw) {
  var cleaned = raw.replaceAll('"', '').trim();
  if (cleaned.isEmpty) return null;

  final hasComma = cleaned.contains(',');
  final hasDot = cleaned.contains('.');

  if (hasComma && hasDot) {
    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');
    if (lastComma > lastDot) {
      // BR: 1.234,56
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else {
      // EN: 1,234.56
      cleaned = cleaned.replaceAll(',', '');
    }
  } else if (hasComma) {
    cleaned = cleaned.replaceAll(',', '.');
  }
  // hasDot-only, pure integer, and a leading `-` are all parsed
  // natively by `double.tryParse`. Pathological inputs like `--1`
  // therefore fall through to `null` rather than silently flipping.

  return double.tryParse(cleaned);
}
