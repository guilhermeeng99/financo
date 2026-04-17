import 'package:financo/features/categories/presentation/utils/category_display_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/category_factory.dart';

void main() {
  group('organizeCategoriesForDisplay', () {
    test('groups subcategories directly below their parent', () {
      final health = CategoryFactory.expense(id: 'health', name: 'Saúde');
      final gym = CategoryFactory.subcategory(
        id: 'gym',
        name: 'Academia',
        parentId: 'health',
      );
      final housing = CategoryFactory.expense(id: 'housing', name: 'Moradia');
      final rent = CategoryFactory.subcategory(
        id: 'rent',
        name: 'Aluguel',
        parentId: 'housing',
      );
      final cat = CategoryFactory.expense(id: 'pet', name: 'Gato');
      final food = CategoryFactory.subcategory(
        id: 'food',
        name: 'Alimentação / sanitário',
        parentId: 'pet',
      );

      final ordered = organizeCategoriesForDisplay([
        gym,
        food,
        health,
        rent,
        housing,
        cat,
      ]);

      expect(
        ordered.map((category) => category.name).toList(),
        [
          'Gato',
          'Alimentação / sanitário',
          'Moradia',
          'Aluguel',
          'Saúde',
          'Academia',
        ],
      );
    });

    test('keeps orphaned subcategories at the end', () {
      final root = CategoryFactory.expense(id: 'root', name: 'Casa');
      final orphan = CategoryFactory.subcategory(
        id: 'orphan',
        name: 'Órfã',
        parentId: 'missing-parent',
      );

      final ordered = organizeCategoriesForDisplay([orphan, root]);

      expect(ordered.first.name, 'Casa');
      expect(ordered.last.name, 'Órfã');
    });
  });
}
