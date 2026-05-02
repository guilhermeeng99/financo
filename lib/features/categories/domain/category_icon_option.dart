import 'package:flutter/widgets.dart';

/// One entry in the icon picker catalog.
///
/// `keywords` is a single space-separated, lowercase, ASCII-only string
/// covering both English and Portuguese terms a user might type
/// (e.g. `'car carro vehicle veiculo auto'`). Storing it flat keeps the
/// catalog readable as a one-line-per-icon table; search-time
/// normalisation handles accents on the query side.
class CategoryIconOption {
  const CategoryIconOption({required this.icon, required this.keywords});

  final IconData icon;
  final String keywords;

  /// Material icon code point persisted in `CategoryEntity.icon`.
  int get codePoint => icon.codePoint;
}
