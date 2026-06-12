import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/core/utils/string_normalize.dart';

/// Shared CSV-cell parsing helpers used by every feature's import use case
/// (transactions, accounts, budgets). Centralised here so the BR/EN
/// number handling and date parsing stay identical across imports instead of
/// being copy-pasted per feature.

/// Resolves CSV [header] cells to logical field keys (`'amount'`, `'date'`,
/// …) via per-feature [synonyms], so importers tolerate extra columns,
/// reordered layouts, and PT-BR/EN headers. Matching is accent- and
/// case-insensitive via [normalizeForMatch]; the first matching cell wins.
///
/// ```dart
/// final colIndex = mapCsvHeaderColumns(
///   rows.first,
///   synonyms: {'amount': ['valor', 'amount']},
/// );
/// final raw = readCsvCell(rows[1], colIndex['amount']);
/// ```
Map<String, int> mapCsvHeaderColumns(
  List<dynamic> header, {
  required Map<String, List<String>> synonyms,
}) {
  final out = <String, int>{};
  for (var i = 0; i < header.length; i++) {
    final norm = normalizeForMatch('${header[i] ?? ''}');
    if (norm.isEmpty) continue;
    _assignHeaderColumn(out, synonyms: synonyms, cell: norm, index: i);
  }
  return out;
}

void _assignHeaderColumn(
  Map<String, int> out, {
  required Map<String, List<String>> synonyms,
  required String cell,
  required int index,
}) {
  for (final entry in synonyms.entries) {
    if (out.containsKey(entry.key)) continue;
    if (!entry.value.contains(cell)) continue;
    out[entry.key] = index;
    return;
  }
}

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
