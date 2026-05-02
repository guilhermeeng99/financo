import 'package:financo/features/categories/domain/category_icon_option.dart';

/// Filters [options] by [query]. The query is normalised (lowercase +
/// diacritic-stripped) and split on whitespace; an option matches when
/// every query token appears as a prefix of any of its keywords. This
/// gives "carro" the same hits as "car", and "alimentação" the same hits
/// as "alimentacao".
///
/// An empty/whitespace-only query returns the catalog unchanged so the
/// picker still shows everything before the user starts typing.
List<CategoryIconOption> searchCategoryIcons(
  String query,
  List<CategoryIconOption> options,
) {
  final tokens = _tokenize(query);
  if (tokens.isEmpty) return options;
  return options.where((opt) {
    final words = opt.keywords.split(' ');
    return tokens.every(
      (t) => words.any((w) => w.startsWith(t)),
    );
  }).toList();
}

List<String> _tokenize(String input) => normalizeForSearch(input)
    .split(RegExp(r'\s+'))
    .where((s) => s.isNotEmpty)
    .toList();

/// Lowercases [input] and strips Latin diacritics so the search matches
/// "Café" against the keyword "cafe". Exposed for tests.
String normalizeForSearch(String input) {
  final buffer = StringBuffer();
  for (final ch in input.toLowerCase().split('')) {
    buffer.write(_diacritics[ch] ?? ch);
  }
  return buffer.toString();
}

const _diacritics = <String, String>{
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
};
