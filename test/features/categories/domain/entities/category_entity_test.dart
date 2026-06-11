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

  group('CategoryEntity.displayAppearance', () {
    test('returns own icon and color for a root category', () {
      final appearance = root.displayAppearance([root, child]);

      expect(appearance.icon, root.icon);
      expect(appearance.color, root.color);
    });

    test('inherits parent icon and color for a subcategory', () {
      const parent = CategoryEntity(
        id: 'parent-1',
        name: 'Gato',
        icon: 0xe91d,
        color: 0xFF8A2BE2,
        type: CategoryType.expense,
      );
      const subcategory = CategoryEntity(
        id: 'child-1',
        name: 'Areia',
        icon: 0xe3c9,
        color: 0xFF00AA99,
        type: CategoryType.expense,
        parentId: 'parent-1',
      );

      final appearance = subcategory.displayAppearance([
        parent,
        subcategory,
      ]);

      expect(appearance.icon, parent.icon);
      expect(appearance.color, parent.color);
    });

    test('falls back to own icon and color when parent is missing', () {
      final appearance = child.displayAppearance(const [child]);

      expect(appearance.icon, child.icon);
      expect(appearance.color, child.color);
    });
  });
}
