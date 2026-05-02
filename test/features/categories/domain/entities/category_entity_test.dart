import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const root = CategoryEntity(
    id: 'root-1',
    name: 'Moradia',
    icon: 0,
    color: 0xFF000000,
    type: CategoryType.expense,
  );
  const child = CategoryEntity(
    id: 'child-1',
    name: 'Aluguel',
    icon: 0,
    color: 0xFF000000,
    type: CategoryType.expense,
    parentId: 'root-1',
  );

  group('CategoryEntity.displayPath', () {
    test('returns plain name for a root category', () {
      expect(root.displayPath([root, child]), 'Moradia');
    });

    test('returns "Parent › Child" for a subcategory', () {
      expect(child.displayPath([root, child]), 'Moradia › Aluguel');
    });

    test('falls back to plain name when the parent is missing', () {
      // Orphan: parent isn't in the resolved list (e.g. deleted while
      // the screen was open). Should not show a dangling " › " prefix.
      expect(child.displayPath(const [child]), 'Aluguel');
    });

    test('handles an empty resolved list for a root', () {
      expect(root.displayPath(const []), 'Moradia');
    });
  });
}
