import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
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
    test('moves every matching doc to the new category, leaving others',
        () async {
      for (var i = 0; i < 3; i++) {
        await firestore
            .collection('transactions')
            .add({'categoryId': 'old', 'userId': 'u'});
      }
      await firestore
          .collection('transactions')
          .add({'categoryId': 'keep', 'userId': 'u'});

      await datasource.reassignTransactions(
        fromCategoryId: 'old',
        toCategoryId: 'new',
      );

      expect(await countWhere('categoryId', 'old'), 0);
      expect(await countWhere('categoryId', 'new'), 3);
      expect(await countWhere('categoryId', 'keep'), 1);
    });
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
