import 'package:financo/features/categories/presentation/utils/category_query_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/category_factory.dart';

void main() {
  final food = CategoryFactory.expense(id: 'p');
  final dining = CategoryFactory.expense(
    id: 'c',
    name: 'Dining',
  ).copyWith(parentId: 'p');
  final transport = CategoryFactory.expense(id: 't', name: 'Transport');
  final all = [food, dining, transport];

  group('filterCategoriesByQuery', () {
    test('returns the full list unchanged for an empty query', () {
      expect(filterCategoriesByQuery(all: all, query: '   '), all);
    });

    test('matches a category by its own name (case-insensitive)', () {
      final result = filterCategoriesByQuery(all: all, query: 'DINING');
      expect(result, contains(dining));
      expect(result, isNot(contains(transport)));
    });

    test('surfaces a subcategory when the parent name matches its path', () {
      final result = filterCategoriesByQuery(all: all, query: 'food');
      // "Food" matches the root by name and the child via "Food › Dining".
      expect(result, containsAll(<Object>[food, dining]));
      expect(result, isNot(contains(transport)));
    });

    test('returns empty when nothing matches', () {
      expect(filterCategoriesByQuery(all: all, query: 'zzz'), isEmpty);
    });
  });
}
