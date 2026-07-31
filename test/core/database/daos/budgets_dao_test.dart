import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/budgets_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/budget_factory.dart';

void main() {
  late AppDatabase db;
  late BudgetsDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.budgetsDao;
  });

  tearDown(() => db.close());

  group('upsertBudget + getBudgetById', () {
    test('round-trips a budget exactly', () async {
      final budget = BudgetFactory.make();

      await dao.upsertBudget(budget);

      expect(await dao.getBudgetById(budget.id), budget);
    });

    test('preserves the amount exactly', () async {
      await dao.upsertBudget(BudgetFactory.make(amount: 1234.56));

      expect((await dao.getBudgetById('budget-1'))!.amount, 1234.56);
    });

    test('overwrites on conflict rather than duplicating', () async {
      await dao.upsertBudget(BudgetFactory.make());
      await dao.upsertBudget(BudgetFactory.make(amount: 2000));

      final all = await dao.getBudgets(userId: userId);
      expect(all, hasLength(1));
      expect(all.single.amount, 2000);
    });

    test('returns null for an unknown id', () async {
      expect(await dao.getBudgetById('nope'), isNull);
    });
  });

  group('getBudgets', () {
    test('scopes to the user and orders by createdAt ascending', () async {
      await dao.insertAllBudgets([
        BudgetFactory.make(id: 'budget-new', createdAt: DateTime(2026, 6)),
        BudgetFactory.make(id: 'budget-old', createdAt: DateTime(2026)),
        BudgetFactory.make(id: 'budget-foreign', userId: 'user-2'),
      ]);

      final budgets = await dao.getBudgets(userId: userId);

      expect(budgets.map((b) => b.id).toList(), ['budget-old', 'budget-new']);
    });

    test('returns an empty list when the user has none', () async {
      expect(await dao.getBudgets(userId: userId), isEmpty);
    });
  });

  group('insertAllBudgets', () {
    test('writes the whole batch and is safe to replay', () async {
      final batch = [
        BudgetFactory.make(),
        BudgetFactory.make(id: 'budget-2', categoryId: 'cat-2'),
      ];

      await dao.insertAllBudgets(batch);
      await dao.insertAllBudgets(batch);

      expect(await dao.getBudgets(userId: userId), hasLength(2));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllBudgets([]);

      expect(await dao.getBudgets(userId: userId), isEmpty);
    });
  });

  group('deletes', () {
    test('deleteBudget removes one row only', () async {
      await dao.insertAllBudgets([
        BudgetFactory.make(),
        BudgetFactory.make(id: 'budget-2', categoryId: 'cat-2'),
      ]);

      await dao.deleteBudget('budget-2');

      expect(
        (await dao.getBudgets(userId: userId)).map((b) => b.id).toList(),
        ['budget-1'],
      );
    });

    test('deleteAllBudgets clears every user', () async {
      await dao.insertAllBudgets([
        BudgetFactory.make(),
        BudgetFactory.make(id: 'budget-foreign', userId: 'user-2'),
      ]);

      await dao.deleteAllBudgets();

      expect(await dao.getBudgets(userId: userId), isEmpty);
      expect(await dao.getBudgets(userId: 'user-2'), isEmpty);
    });
  });
}
