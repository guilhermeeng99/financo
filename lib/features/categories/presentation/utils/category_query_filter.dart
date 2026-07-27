import 'package:financo/core/utils/string_normalize.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';

/// Filters a list of categories against a search query, matching either
/// the category's own name or its displayed path (so searching the
/// parent name surfaces its subcategories). Case- and accent-insensitive
/// (`salario` matches `Salário`), whitespace-trimmed — via
/// [normalizeForMatch].
///
/// Returning the input unchanged for an empty query keeps the existing
/// ordering (caller is responsible for `organizeCategoriesForDisplay`).
List<CategoryEntity> filterCategoriesByQuery({
  required List<CategoryEntity> all,
  required String query,
}) {
  final normalizedQuery = normalizeForMatch(query);
  if (normalizedQuery.isEmpty) return all;
  return all.where((c) {
    if (normalizeForMatch(c.name).contains(normalizedQuery)) return true;
    return normalizeForMatch(c.displayPath(all)).contains(normalizedQuery);
  }).toList();
}
