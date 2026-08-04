import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/transaction_factory.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TransactionRemoteDataSourceImpl datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = TransactionRemoteDataSourceImpl(firestore: firestore);
  });

  Future<int> countWhere(String field, Object value) async {
    final snap = await firestore
        .collection('transactions')
        .where(field, isEqualTo: value)
        .get();
    return snap.docs.length;
  }

  group('getTransactions', () {
    // Rows whose `date` order is the exact reverse of their `dueDate` order,
    // so the assertion can only pass under one of the two orderings.
    Future<void> seedSequence() async {
      await datasource.createTransactions([
        for (final row in const [
          ('first', 1, 3),
          ('second', 2, 2),
          ('third', 3, 1),
        ])
          TransactionModel.fromEntity(
            TransactionFactory.expense(
              id: 'tx-${row.$1}',
              description: row.$1,
              date: DateTime(2024, row.$2, 10),
              dueDate: DateTime(2024, row.$3, 10),
              recurrence: TransactionRecurrence.installment,
              recurrenceGroupId: 'grp-1',
            ),
          ),
      ]);
    }

    test('orders a recurrenceGroupId lookup by dueDate', () async {
      // Regression: the sequence delete query (userId + recurrenceGroupId,
      // no date range) used to order by `date` — a shape with no composite
      // index, so Firestore answered FAILED_PRECONDITION and the UI showed
      // "Couldn't reach the server" on "delete this and following".
      await seedSequence();

      final result = await datasource.getTransactions(
        userId: 'user-1',
        recurrenceGroupId: 'grp-1',
      );

      expect(
        result.map((tx) => tx.description),
        ['first', 'second', 'third'],
      );
    });

    test('still orders by date when a date range is given', () async {
      await seedSequence();

      final result = await datasource.getTransactions(
        userId: 'user-1',
        startDate: DateTime(2024),
        endDate: DateTime(2024, 12, 31),
        recurrenceGroupId: 'grp-1',
      );

      expect(
        result.map((tx) => tx.description),
        ['third', 'second', 'first'],
      );
    });
  });

  group('createTransfer', () {
    test('persists both legs with cross-links set atomically', () async {
      final pair = TransactionFactory.transfer();
      final expense = TransactionModel.fromEntity(pair.expense);
      final income = TransactionModel.fromEntity(pair.income);

      final result = await datasource.createTransfer(
        expense: expense,
        income: income,
      );

      expect(result, hasLength(2));
      final createdExpense = result[0];
      final createdIncome = result[1];

      // Regression: links must point at the *generated* ids, and both legs
      // must exist — the old sequential writes could drop a link mid-flow.
      expect(createdExpense.linkedTransactionId, createdIncome.id);
      expect(createdIncome.linkedTransactionId, createdExpense.id);

      final all = await firestore.collection('transactions').get();
      expect(all.docs, hasLength(2));
    });
  });

  group('reassignTransactions', () {
    test(
      'moves every matching doc to the new category, leaving others',
      () async {
        for (var i = 0; i < 3; i++) {
          await firestore.collection('transactions').add({
            'categoryId': 'old',
            'userId': 'u',
          });
        }
        await firestore.collection('transactions').add({
          'categoryId': 'keep',
          'userId': 'u',
        });

        await datasource.reassignTransactions(
          fromCategoryId: 'old',
          toCategoryId: 'new',
        );

        expect(await countWhere('categoryId', 'old'), 0);
        expect(await countWhere('categoryId', 'new'), 3);
        expect(await countWhere('categoryId', 'keep'), 1);
      },
    );
  });

  group('deleteTransfer', () {
    test('removes both legs and leaves unrelated docs', () async {
      final a = await firestore.collection('transactions').add({'x': 1});
      final b = await firestore.collection('transactions').add({'x': 2});
      final c = await firestore.collection('transactions').add({'x': 3});

      await datasource.deleteTransfer(a.id, b.id);

      final remaining = await firestore.collection('transactions').get();
      expect(remaining.docs.map((d) => d.id), [c.id]);
    });
  });
}
