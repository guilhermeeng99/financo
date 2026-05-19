/// Trims, lowercases, and strips Portuguese diacritics so user-facing
/// strings (CSV headers, bank-label aliases, picker search queries) can
/// be compared without a brittle synonym list.
///
/// Example: `"Cartão de Crédito"` → `"cartao de credito"`.
String normalizeForMatch(String input) {
  final lower = input.trim().toLowerCase();
  final buffer = StringBuffer();
  for (final ch in lower.split('')) {
    buffer.write(_diacritics[ch] ?? ch);
  }
  return buffer.toString();
}

const _diacritics = <String, String>{
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};
