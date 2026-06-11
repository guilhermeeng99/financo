import 'package:financo/core/utils/amount_parser.dart';

/// Shared CSV-cell parsing helpers used by every feature's import use case
/// (transactions, accounts, budgets). Centralised here so the BR/EN
/// number handling and date parsing stay identical across imports instead of
/// being copy-pasted per feature.

/// Reads cell [index] from a parsed CSV [row], returning a trimmed string.
/// Out-of-range or null cells yield `''`.
String readCsvCell(List<dynamic> row, int? index) {
  if (index == null || index >= row.length) return '';
  return '${row[index] ?? ''}'.trim();
}

/// Parses a money cell that may use Brazilian (`1.234,56`) or English
/// (`1,234.56`) formatting. Blank/garbage yields `0`. Set [absolute] when a
/// separate column (e.g. a `Tipo` field) carries the sign, so the magnitude
/// is taken from the amount and the direction from the type.
double parseCsvAmount(String raw, {bool absolute = false}) {
  final value = parseDecimalAmount(raw) ?? 0;
  return absolute ? value.abs() : value;
}

/// Parses a `DD/MM/YYYY` date cell. Returns `null` for malformed input or
/// out-of-range day/month, so callers can skip or flag the offending row.
DateTime? parseDmyDate(String raw) {
  final parts = raw.split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;

  return DateTime(year, month, day);
}
