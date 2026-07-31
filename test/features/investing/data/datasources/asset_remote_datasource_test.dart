import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/data/datasources/asset_remote_datasource.dart';
import 'package:financo/features/investing/data/models/asset_model.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

// Tests go through the public `AssetRemoteDataSource` interface only — the impl
// was moved onto `FirestoreCrudDataSource` and the interface is what must not
// change.
void main() {
  late FakeFirebaseFirestore firestore;
  late AssetRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = AssetRemoteDataSourceImpl(firestore: firestore);
  });

  group('createAsset + getAssets', () {
    test('persists the model and returns it with the generated id', () async {
      final model = AssetModel.fromEntity(AssetFactory.stockUs());

      final created = await datasource.createAsset(model);

      expect(created.id, isNotEmpty);
      expect(created.id, isNot(model.id));
      expect(created.ticker, 'AAPL');
      expect(created.kind, AssetKind.stockUs);
      expect(created.market, Market.us);
      expect(created.currency, Currency.usd);
      expect(created.institutionId, 'inst-avenue');
      expect(created.userId, userId);
    });

    test('writes into the investment_assets collection', () async {
      await datasource.createAsset(
        AssetModel.fromEntity(AssetFactory.stockBr()),
      );

      final docs = await firestore.collection('investment_assets').get();
      expect(docs.docs, hasLength(1));
    });

    test('round-trips the metadata map through Firestore', () async {
      final created = await datasource.createAsset(
        AssetModel.fromEntity(
          AssetFactory.stockBr(
            metadata: const {
              'allocationClassId': 'class-stocks',
              'fiRate': '110',
            },
          ),
        ),
      );

      expect(created.metadata, {
        'allocationClassId': 'class-stocks',
        'fiRate': '110',
      });
    });

    test("returns only the given user's assets", () async {
      await datasource.createAsset(
        AssetModel.fromEntity(AssetFactory.stockUs()),
      );
      await datasource.createAsset(
        AssetModel.fromEntity(AssetFactory.stockBr(userId: 'user-2')),
      );

      final assets = await datasource.getAssets(userId: userId);

      expect(assets, hasLength(1));
      expect(assets.single.ticker, 'AAPL');
    });

    test('returns an empty list when the user has none', () async {
      expect(await datasource.getAssets(userId: userId), isEmpty);
    });
  });

  group('updateAsset', () {
    test('overwrites stored fields and returns the fresh doc', () async {
      final created = await datasource.createAsset(
        AssetModel.fromEntity(AssetFactory.stockUs()),
      );

      final updated = await datasource.updateAsset(
        AssetModel.fromEntity(
          AssetFactory.stockUs(
            id: created.id,
            name: 'Apple',
            metadata: const {'allocationClassId': 'class-us'},
          ),
        ),
      );

      expect(updated.id, created.id);
      expect(updated.name, 'Apple');
      expect(updated.metadata['allocationClassId'], 'class-us');
    });
  });

  group('deleteAsset', () {
    test('removes the doc, leaving siblings intact', () async {
      final keep = await datasource.createAsset(
        AssetModel.fromEntity(AssetFactory.stockUs()),
      );
      final drop = await datasource.createAsset(
        AssetModel.fromEntity(AssetFactory.stockBr()),
      );

      await datasource.deleteAsset(drop.id);

      final remaining = await datasource.getAssets(userId: userId);
      expect(remaining.map((a) => a.id).toList(), [keep.id]);
    });
  });

  group('failures', () {
    // fake_cloud_firestore cannot throw transport errors, so the raw client is
    // mocked. The wording is asserted because the shared base derives it from
    // `entityLabel`.
    late MockFirebaseFirestore mockFirestore;
    late MockMapCollectionReference collection;
    late AssetRemoteDataSourceImpl flaky;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      collection = MockMapCollectionReference();
      when(
        () => mockFirestore.collection('investment_assets'),
      ).thenReturn(collection);
      flaky = AssetRemoteDataSourceImpl(firestore: mockFirestore);
    });

    test('create surfaces a ServerException', () async {
      when(() => collection.add(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        () => flaky.createAsset(AssetModel.fromEntity(AssetFactory.stockUs())),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to create asset.',
          ),
        ),
      );
    });

    test('fetch surfaces a ServerException', () async {
      when(() => collection.where('userId', isEqualTo: userId)).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      expect(
        () => flaky.getAssets(userId: userId),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to fetch assets.',
          ),
        ),
      );
    });

    test('delete surfaces a ServerException', () async {
      final doc = MockMapDocumentReference();
      when(() => collection.doc('asset-1')).thenReturn(doc);
      when(doc.delete).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        () => flaky.deleteAsset('asset-1'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to delete asset.',
          ),
        ),
      );
    });
  });
}
