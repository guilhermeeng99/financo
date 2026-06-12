import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/investments/data/datasources/asset_holding_remote_datasource.dart';
import 'package:financo/features/investments/data/models/asset_holding_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/asset_holding_factory.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AssetHoldingRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = AssetHoldingRemoteDataSourceImpl(firestore: firestore);
  });

  Future<AssetHoldingModel> create({
    String accountId = 'acc-inv-1',
    String assetClassId = 'class-stocks',
    double amount = 1000,
    String? notes,
    String holdingUserId = userId,
  }) => datasource.createAssetHolding(
    AssetHoldingModel.fromEntity(
      AssetHoldingFactory.holding(
        userId: holdingUserId,
        accountId: accountId,
        assetClassId: assetClassId,
        amount: amount,
        notes: notes,
      ),
    ),
  );

  group('createAssetHolding + getAssetHoldings', () {
    test('persists the model and reads it back scoped by user', () async {
      final created = await create(amount: 4000, notes: 'long term');
      await create(holdingUserId: 'user-2');

      expect(created.id, isNotEmpty);
      final holdings = await datasource.getAssetHoldings(userId: userId);
      expect(holdings, hasLength(1));
      expect(holdings.single.amount, 4000);
      expect(holdings.single.notes, 'long term');
      expect(holdings.single.accountId, 'acc-inv-1');
      expect(holdings.single.assetClassId, 'class-stocks');
    });
  });

  group('updateAssetHolding', () {
    test('overwrites the stored amount and returns the fresh doc', () async {
      final created = await create();

      final updated = await datasource.updateAssetHolding(
        AssetHoldingModel.fromEntity(
          AssetHoldingFactory.holding(id: created.id, amount: 2500),
        ),
      );

      expect(updated.amount, 2500);
      final holdings = await datasource.getAssetHoldings(userId: userId);
      expect(holdings.single.amount, 2500);
    });
  });

  group('deleteAssetHolding', () {
    test('removes the doc, leaving siblings intact', () async {
      final keep = await create(assetClassId: 'class-keep');
      final drop = await create(assetClassId: 'class-drop');

      await datasource.deleteAssetHolding(drop.id);

      final remaining = await datasource.getAssetHoldings(userId: userId);
      expect(remaining.map((h) => h.id).toList(), [keep.id]);
    });
  });

  group('deleteHoldingsForAccount', () {
    test('batch-deletes every holding of the account for that user only',
        () async {
      await create(accountId: 'acc-gone');
      await create(accountId: 'acc-gone', assetClassId: 'class-crypto');
      final survivor = await create(accountId: 'acc-stays');
      await create(accountId: 'acc-gone', holdingUserId: 'user-2');

      await datasource.deleteHoldingsForAccount(
        userId: userId,
        accountId: 'acc-gone',
      );

      final mine = await datasource.getAssetHoldings(userId: userId);
      expect(mine.map((h) => h.id).toList(), [survivor.id]);
      final theirs = await datasource.getAssetHoldings(userId: 'user-2');
      expect(theirs, hasLength(1));
    });

    test('is a no-op when nothing matches', () async {
      final kept = await create();

      await datasource.deleteHoldingsForAccount(
        userId: userId,
        accountId: 'acc-unknown',
      );

      final mine = await datasource.getAssetHoldings(userId: userId);
      expect(mine.map((h) => h.id).toList(), [kept.id]);
    });
  });

  group('deleteHoldingsForClass', () {
    test('batch-deletes every holding of the class for that user only',
        () async {
      await create(assetClassId: 'class-gone');
      await create(assetClassId: 'class-gone', accountId: 'acc-inv-2');
      final survivor = await create(assetClassId: 'class-stays');
      await create(assetClassId: 'class-gone', holdingUserId: 'user-2');

      await datasource.deleteHoldingsForClass(
        userId: userId,
        classId: 'class-gone',
      );

      final mine = await datasource.getAssetHoldings(userId: userId);
      expect(mine.map((h) => h.id).toList(), [survivor.id]);
      final theirs = await datasource.getAssetHoldings(userId: 'user-2');
      expect(theirs, hasLength(1));
    });
  });
}
