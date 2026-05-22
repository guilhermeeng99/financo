import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/domain/services/compute_category_drill_down.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';

void main() {
  final parent = CategoryFactory.expense(id: 'p');
  final dining = CategoryFactory.expense(
    id: 'c1',
    name: 'Dining',
  ).copyWith(parentId: 'p');
  final groceries = CategoryFactory.expense(
    id: 'c2',
    name: 'Groceries',
  ).copyWith(parentId: 'p');
  final unrelated = CategoryFactory.expense(id: 'x', name: 'Transport');
  final categoryMap = <String, CategoryEntity>{
    'p': parent,
    'c1': dining,
    'c2': groceries,
    'x': unrelated,
  };

  group('filterTransactionsForCategory', () {
    test('keeps parent + subcategory expenses, newest first', () {
      final onParent = TransactionFactory.expense(
        id: 'e1',
        categoryId: 'p',
        date: DateTime(2024, 3, 20),
      );
      final onDining = TransactionFactory.expense(
        id: 'e2',
        categoryId: 'c1',
        date: DateTime(2024, 3, 18),
      );
      final onGroceries = TransactionFactory.expense(
        id: 'e3',
        categoryId: 'c2',
        date: DateTime(2024, 3, 10),
      );
      final onUnrelated = TransactionFactory.expense(id: 'e4', categoryId: 'x');

      final result = filterTransactionsForCategory(
        parentCategoryId: 'p',
        periodTransactions: [onGroceries, onParent, onDining, onUnrelated],
        categoryMap: categoryMap,
      );

      expect(result.map((t) => t.id), ['e1', 'e2', 'e3']);
    });

    test('excludes income and transfers', () {
      final income = TransactionFactory.income(categoryId: 'c1');
      final transfer = TransactionFactory.transfer().expense;

      final result = filterTransactionsForCategory(
        parentCategoryId: 'p',
        periodTransactions: [income, transfer],
        categoryMap: categoryMap,
      );

      expect(result, isEmpty);
    });
  });

  group('aggregateSubcategorySpend', () {
    test('rolls up by subcategory (excluding the parent), largest first', () {
      final txns = [
        TransactionFactory.expense(id: 'a', categoryId: 'p', amount: 100),
        TransactionFactory.expense(id: 'b', categoryId: 'c1', amount: 50),
        TransactionFactory.expense(id: 'c', categoryId: 'c1', amount: 20),
        TransactionFactory.expense(id: 'd', categoryId: 'c2', amount: 80),
      ];

      final result = aggregateSubcategorySpend(
        parentCategoryId: 'p',
        transactions: txns,
        categoryMap: categoryMap,
        fallbackName: 'Uncategorized',
      );

      // c2 = 80 sorts ahead of c1 = 50 + 20 = 70.
      expect(result.map((e) => e.categoryId), ['c2', 'c1']);
      expect(result[0].amount, 80);
      expect(result[1].amount, 70);
      expect(result[1].categoryName, 'Dining');
    });

    test('uses the fallback name/colour for unknown category ids', () {
      final result = aggregateSubcategorySpend(
        parentCategoryId: 'p',
        transactions: [
          TransactionFactory.expense(id: 'g', categoryId: 'ghost', amount: 5),
        ],
        categoryMap: categoryMap,
        fallbackName: 'Uncategorized',
        fallbackColor: 0xFF123456,
      );

      expect(result.single.categoryName, 'Uncategorized');
      expect(result.single.categoryColor, 0xFF123456);
    });
  });
}
