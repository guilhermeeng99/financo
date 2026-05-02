import 'package:financo/features/categories/domain/entities/category_entity.dart';

/// Filters a list of categories against a search query, matching either
/// the category's own name or its displayed path (so searching the
/// parent name surfaces its subcategories). Case-insensitive,
/// whitespace-trimmed.
///
/// Returning the input unchanged for an empty query keeps the existing
/// ordering (caller is responsible for `organizeCategoriesForDisplay`).
List<CategoryEntity> filterCategoriesByQuery({
  required List<CategoryEntity> all,
  required String query,
}) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return all;
  return all.where((c) {
    if (c.name.toLowerCase().contains(trimmed)) return true;
    return c.displayPath(all).toLowerCase().contains(trimmed);
  }).toList();
}
