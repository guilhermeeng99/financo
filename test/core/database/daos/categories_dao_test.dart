// `show Value` only — drift's query builder exports matcher-shadowing names.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/category_factory.dart';

void main() {
  late AppDatabase db;
  late CategoriesDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.categoriesDao;
  });

  tearDown(() => db.close());

  group('upsertCategory + getCategoryById', () {
    test('round-trips an expense category', () async {
      final category = CategoryFactory.expense();

      await dao.upsertCategory(category);

      expect(await dao.getCategoryById(category.id), category);
    });

    test('round-trips the 50/30/20 bucket and opt-out flag', () async {
      // `bucket` drives needs/wants and `countsIn50_30_20` excludes a category
      // from the split entirely — both are the inputs the dashboard reports on.
      await dao.upsertCategory(
        CategoryFactory.expense(bucket: CategoryBucket.needs),
      );
      await dao.upsertCategory(
        CategoryFactory.income(id: 'cat-x', countsIn50_30_20: false),
      );

      expect(
        (await dao.getCategoryById('cat-expense-1'))!.bucket,
        CategoryBucket.needs,
      );
      expect(
        (await dao.getCategoryById('cat-x'))!.countsIn50_30_20,
        isFalse,
      );
    });

    test('overwrites on conflict rather than duplicating', () async {
      await dao.upsertCategory(CategoryFactory.expense());
      await dao.upsertCategory(CategoryFactory.expense(name: 'Groceries'));

      final all = await dao.getCategories(userId);
      expect(all, hasLength(1));
      expect(all.single.name, 'Groceries');
    });

    test('returns null for an unknown id', () async {
      expect(await dao.getCategoryById('nope'), isNull);
    });
  });

  group('getCategories', () {
    test('scopes to the user and orders by name', () async {
      await dao.insertAllCategories([
        ...CategoryFactory.list(),
        CategoryFactory.expense(id: 'cat-foreign', userId: 'user-2'),
      ]);

      final categories = await dao.getCategories(userId);

      expect(categories.map((c) => c.name).toList(), [
        'Food',
        'Freelance',
        'Salary',
        'Transport',
      ]);
    });

    test('returns an empty list when the user has none', () async {
      expect(await dao.getCategories(userId), isEmpty);
    });
  });

  group('getChildCategories', () {
    test("returns only the given parent's children, by name", () async {
      await dao.insertAllCategories([
        CategoryFactory.expense(),
        CategoryFactory.subcategory(id: 'cat-sub-b', name: 'Supermarket'),
        CategoryFactory.subcategory(id: 'cat-sub-a', name: 'Bakery'),
        CategoryFactory.subcategory(
          id: 'cat-sub-other',
          name: 'Fuel',
          parentId: 'cat-expense-2',
        ),
      ]);

      final children = await dao.getChildCategories('cat-expense-1');

      expect(children.map((c) => c.name).toList(), ['Bakery', 'Supermarket']);
    });

    test('returns empty for a leaf category', () async {
      await dao.upsertCategory(CategoryFactory.expense());

      expect(await dao.getChildCategories('cat-expense-1'), isEmpty);
    });
  });

  group('insertAllCategories', () {
    test('writes the whole batch and is safe to replay', () async {
      await dao.insertAllCategories(CategoryFactory.list());
      await dao.insertAllCategories(CategoryFactory.list());

      expect(await dao.getCategories(userId), hasLength(4));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllCategories([]);

      expect(await dao.getCategories(userId), isEmpty);
    });
  });

  group('deletes', () {
    test('deleteCategory removes one row only', () async {
      await dao.insertAllCategories(CategoryFactory.list());

      await dao.deleteCategory('cat-expense-1');

      final remaining = await dao.getCategories(userId);
      expect(remaining.map((c) => c.id), isNot(contains('cat-expense-1')));
      expect(remaining, hasLength(3));
    });

    test('deleteAllCategories clears every user', () async {
      await dao.insertAllCategories([
        CategoryFactory.expense(),
        CategoryFactory.expense(id: 'cat-foreign', userId: 'user-2'),
      ]);

      await dao.deleteAllCategories();

      expect(await dao.getCategories(userId), isEmpty);
      expect(await dao.getCategories('user-2'), isEmpty);
    });
  });

  group('degraded rows', () {
    test('unknown type falls back, unknown bucket becomes null', () async {
      // Deliberately different fallbacks: a category must still have a type,
      // but an unrecognised bucket has to read as "unclassified" so the
      // 50/30/20 pipeline skips it instead of mis-bucketing it.
      await db
          .into(db.localCategories)
          .insert(
            LocalCategoriesCompanion.insert(
              id: 'cat-junk',
              userId: const Value(userId),
              name: 'Legacy',
              icon: 1,
              color: 2,
              type: 'transfer',
              bucket: const Value('luxuries'),
            ),
          );

      final read = await dao.getCategoryById('cat-junk');
      expect(read!.type, CategoryType.expense);
      expect(read.bucket, isNull);
    });
  });
}
