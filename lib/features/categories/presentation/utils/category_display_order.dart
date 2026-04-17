import 'package:financo/features/categories/domain/entities/category_entity.dart';

List<CategoryEntity> organizeCategoriesForDisplay(
  List<CategoryEntity> categories,
) {
  final byId = {for (final category in categories) category.id: category};
  final roots = <CategoryEntity>[];
  final orphaned = <CategoryEntity>[];
  final childrenByParent = <String, List<CategoryEntity>>{};

  for (final category in categories) {
    final parentId = category.parentId;
    if (parentId == null) {
      roots.add(category);
      continue;
    }

    if (byId.containsKey(parentId)) {
      childrenByParent.putIfAbsent(parentId, () => []).add(category);
    } else {
      orphaned.add(category);
    }
  }

  int compareByName(CategoryEntity a, CategoryEntity b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  roots.sort(compareByName);
  orphaned.sort(compareByName);
  for (final children in childrenByParent.values) {
    children.sort(compareByName);
  }

  final ordered = <CategoryEntity>[];
  for (final root in roots) {
    ordered
      ..add(root)
      ..addAll(childrenByParent[root.id] ?? const []);
  }
  ordered.addAll(orphaned);

  return ordered;
}
