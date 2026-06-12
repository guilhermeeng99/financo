import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:financo/features/budgets/data/models/budget_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/budget_factory.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late BudgetRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = BudgetRemoteDataSourceImpl(firestore: firestore);
  });

  group('createBudget', () {
    test('persists the model and returns it with the generated id', () async {
      final model = BudgetModel.fromEntity(BudgetFactory.make());

      final created = await datasource.createBudget(model);

      expect(created.id, isNotEmpty);
      expect(created.categoryId, model.categoryId);
      expect(created.amount, model.amount);
      expect(created.userId, userId);
    });
  });

  group('getBudgets', () {
    test("returns only the given user's budgets ordered by createdAt",
        () async {
      await datasource.createBudget(
        BudgetModel.fromEntity(
          BudgetFactory.make(
            categoryId: 'cat-late',
            createdAt: DateTime(2026, 5),
          ),
        ),
      );
      await datasource.createBudget(
        BudgetModel.fromEntity(
          BudgetFactory.make(
            categoryId: 'cat-early',
            createdAt: DateTime(2026),
          ),
        ),
      );
      await datasource.createBudget(
        BudgetModel.fromEntity(
          BudgetFactory.make(categoryId: 'cat-foreign', userId: 'user-2'),
        ),
      );

      final budgets = await datasource.getBudgets(userId: userId);

      expect(
        budgets.map((b) => b.categoryId).toList(),
        ['cat-early', 'cat-late'],
      );
    });

    test('returns an empty list when the user has no budgets', () async {
      expect(await datasource.getBudgets(userId: userId), isEmpty);
    });
  });

  group('updateBudget', () {
    test('overwrites the stored amount and returns the fresh doc', () async {
      final created = await datasource.createBudget(
        BudgetModel.fromEntity(BudgetFactory.make()),
      );

      final updated = await datasource.updateBudget(
        BudgetModel.fromEntity(
          BudgetFactory.make(id: created.id, amount: 2000),
        ),
      );

      expect(updated.amount, 2000);
      final all = await datasource.getBudgets(userId: userId);
      expect(all.single.amount, 2000);
    });
  });

  group('deleteBudget', () {
    test('removes the doc, leaving siblings intact', () async {
      final keep = await datasource.createBudget(
        BudgetModel.fromEntity(BudgetFactory.make(categoryId: 'cat-keep')),
      );
      final drop = await datasource.createBudget(
        BudgetModel.fromEntity(BudgetFactory.make(categoryId: 'cat-drop')),
      );

      await datasource.deleteBudget(drop.id);

      final remaining = await datasource.getBudgets(userId: userId);
      expect(remaining.map((b) => b.id).toList(), [keep.id]);
    });
  });
}
