import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/datasources/asset_transaction_remote_datasource.dart';
import 'package:financo/features/investing/data/models/asset_transaction_model.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AssetTransactionRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = AssetTransactionRemoteDataSourceImpl(firestore: firestore);
  });

  group('createTransaction + getTransactions', () {
    test('persists the model and returns it with the generated id', () async {
      final model = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.buy(),
      );

      final created = await datasource.createTransaction(model);

      expect(created.id, isNotEmpty);
      expect(created.id, isNot(model.id));
      expect(created.kind, TransactionKind.buy);
      expect(created.assetId, 'asset-aapl');
      expect(created.institutionId, 'inst-avenue');
      expect(created.userId, userId);
    });

    test('money survives the Firestore round-trip to the exact cent', () async {
      // The whole point of this collection is money. An amount that is not an
      // exact number of cents in double-land is the one that would drift.
      final created = await datasource.createTransaction(
        AssetTransactionModel.fromEntity(
          AssetTransactionFactory.buy(
            quantity: 3,
            unitPrice: const Money(3333, Currency.usd),
            fees: const Money(199, Currency.usd),
          ),
        ),
      );

      expect(created.unitPrice.minorUnits, 3333);
      expect(created.fees.minorUnits, 199);
      expect(created.amount.minorUnits, 9999);
      expect(created.amount.currency, Currency.usd);
    });

    test('round-trips the F8 funding-account pair', () async {
      final created = await datasource.createTransaction(
        AssetTransactionModel.fromEntity(
          AssetTransactionFactory.buy(
            fundingAccountId: 'acc-checking-1',
            cashAmount: const Money(52345, Currency.brl),
          ),
        ),
      );

      expect(created.fundingAccountId, 'acc-checking-1');
      expect(created.cashAmount!.minorUnits, 52345);
      expect(created.cashAmount!.currency, Currency.brl);
    });

    test('leaves both halves of the pair null on a plain trade', () async {
      final created = await datasource.createTransaction(
        AssetTransactionModel.fromEntity(AssetTransactionFactory.sell()),
      );

      expect(created.fundingAccountId, isNull);
      expect(created.cashAmount, isNull);
    });

    test('writes into the investment_transactions collection', () async {
      await datasource.createTransaction(
        AssetTransactionModel.fromEntity(AssetTransactionFactory.buy()),
      );

      final docs = await firestore.collection('investment_transactions').get();
      expect(docs.docs, hasLength(1));
    });

    test("returns only the given user's transactions", () async {
      await datasource.createTransaction(
        AssetTransactionModel.fromEntity(AssetTransactionFactory.buy()),
      );
      await datasource.createTransaction(
        AssetTransactionModel.fromEntity(
          AssetTransactionFactory.sell(userId: 'user-2'),
        ),
      );

      final transactions = await datasource.getTransactions(userId: userId);

      expect(transactions, hasLength(1));
      expect(transactions.single.kind, TransactionKind.buy);
    });

    test('returns an empty list when the user has none', () async {
      expect(await datasource.getTransactions(userId: userId), isEmpty);
    });
  });

  group('updateTransaction', () {
    test('overwrites stored fields and returns the fresh doc', () async {
      final created = await datasource.createTransaction(
        AssetTransactionModel.fromEntity(AssetTransactionFactory.buy()),
      );

      final updated = await datasource.updateTransaction(
        AssetTransactionModel.fromEntity(
          AssetTransactionFactory.buy(
            id: created.id,
            quantity: 25,
            unitPrice: const Money(12345, Currency.usd),
            notes: 'corrected',
          ),
        ),
      );

      expect(updated.id, created.id);
      expect(updated.quantity, 25);
      expect(updated.unitPrice.minorUnits, 12345);
      expect(updated.notes, 'corrected');
    });
  });

  group('deleteTransaction', () {
    test('removes the doc, leaving siblings intact', () async {
      final keep = await datasource.createTransaction(
        AssetTransactionModel.fromEntity(AssetTransactionFactory.buy()),
      );
      final drop = await datasource.createTransaction(
        AssetTransactionModel.fromEntity(AssetTransactionFactory.sell()),
      );

      await datasource.deleteTransaction(drop.id);

      final remaining = await datasource.getTransactions(userId: userId);
      expect(remaining.map((t) => t.id).toList(), [keep.id]);
    });
  });

  group('failures', () {
    // fake_cloud_firestore cannot throw transport errors, so the raw client is
    // mocked here.
    late MockFirebaseFirestore mockFirestore;
    late MockMapCollectionReference collection;
    late AssetTransactionRemoteDataSourceImpl flaky;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      collection = MockMapCollectionReference();
      when(
        () => mockFirestore.collection('investment_transactions'),
      ).thenReturn(collection);
      flaky = AssetTransactionRemoteDataSourceImpl(firestore: mockFirestore);
    });

    test('create surfaces a ServerException', () async {
      when(() => collection.add(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        () => flaky.createTransaction(
          AssetTransactionModel.fromEntity(AssetTransactionFactory.buy()),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to create transaction.',
          ),
        ),
      );
    });

    test('fetch surfaces a ServerException', () async {
      when(() => collection.where('userId', isEqualTo: userId)).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      expect(
        () => flaky.getTransactions(userId: userId),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to fetch transactions.',
          ),
        ),
      );
    });

    test('delete surfaces a ServerException', () async {
      final doc = MockMapDocumentReference();
      when(() => collection.doc('tx-1')).thenReturn(doc);
      when(doc.delete).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        () => flaky.deleteTransaction('tx-1'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to delete transaction.',
          ),
        ),
      );
    });
  });
}
