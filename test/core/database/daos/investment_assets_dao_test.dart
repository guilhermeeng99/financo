import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/investment_assets_dao.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/investing_factories.dart';

void main() {
  late AppDatabase db;
  late InvestmentAssetsDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.investmentAssetsDao;
  });

  tearDown(() => db.close());

  group('upsertAsset + getAssets', () {
    test('round-trips an asset exactly', () async {
      final asset = AssetFactory.stockUs();

      await dao.upsertAsset(asset);

      expect((await dao.getAssets(userId)).single, asset);
    });

    test('round-trips the metadata map through its JSON column', () async {
      // Metadata is stored as a JSON blob, not columns — the allocation link
      // and the fixed-income terms all live in here.
      await dao.upsertAsset(
        AssetFactory.stockBr(
          metadata: const {
            'allocationClassId': 'class-stocks',
            'allocationTargetPercent': '12.5',
            'fiBasis': 'cdi',
            'fiRate': '110',
          },
        ),
      );

      final read = (await dao.getAssets(userId)).single;
      expect(read.metadata, {
        'allocationClassId': 'class-stocks',
        'allocationTargetPercent': '12.5',
        'fiBasis': 'cdi',
        'fiRate': '110',
      });
    });

    test('round-trips an empty metadata map', () async {
      await dao.upsertAsset(AssetFactory.stockUs());

      expect((await dao.getAssets(userId)).single.metadata, isEmpty);
    });

    test('keeps institutionId null for an unlinked legacy asset', () async {
      await dao.upsertAsset(AssetFactory.stockBr(institutionId: null));

      expect((await dao.getAssets(userId)).single.institutionId, isNull);
    });

    test('overwrites on conflict rather than duplicating', () async {
      await dao.upsertAsset(AssetFactory.stockUs());
      await dao.upsertAsset(AssetFactory.stockUs(name: 'Apple'));

      final all = await dao.getAssets(userId);
      expect(all, hasLength(1));
      expect(all.single.name, 'Apple');
    });
  });

  group('getAssets', () {
    test('scopes to the user and orders by ticker', () async {
      await dao.insertAllAssets([
        AssetFactory.stockBr(),
        AssetFactory.stockUs(),
        AssetFactory.stockUs(id: 'asset-foreign', userId: 'user-2'),
      ]);

      final assets = await dao.getAssets(userId);

      expect(assets.map((a) => a.ticker).toList(), ['AAPL', 'PETR4']);
    });

    test('returns an empty list when the user has none', () async {
      expect(await dao.getAssets(userId), isEmpty);
    });
  });

  group('insertAllAssets', () {
    test('writes the whole batch and is safe to replay', () async {
      final batch = [AssetFactory.stockUs(), AssetFactory.stockBr()];

      await dao.insertAllAssets(batch);
      await dao.insertAllAssets(batch);

      expect(await dao.getAssets(userId), hasLength(2));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllAssets([]);

      expect(await dao.getAssets(userId), isEmpty);
    });
  });

  group('deletes', () {
    test('deleteAsset removes one row only', () async {
      await dao.insertAllAssets([
        AssetFactory.stockUs(),
        AssetFactory.stockBr(),
      ]);

      await dao.deleteAsset('asset-petr4');

      expect(
        (await dao.getAssets(userId)).map((a) => a.id).toList(),
        ['asset-aapl'],
      );
    });

    test('deleteAllAssets clears every user', () async {
      await dao.insertAllAssets([
        AssetFactory.stockUs(),
        AssetFactory.stockBr(id: 'asset-foreign', userId: 'user-2'),
      ]);

      await dao.deleteAllAssets();

      expect(await dao.getAssets(userId), isEmpty);
      expect(await dao.getAssets('user-2'), isEmpty);
    });
  });

  group('degraded rows', () {
    test('falls back instead of throwing on unknown enum names', () async {
      await db
          .into(db.localInvestmentAssets)
          .insert(
            LocalInvestmentAssetsCompanion.insert(
              id: 'asset-junk',
              userId: userId,
              ticker: 'ZZZZ',
              name: 'Legacy',
              kind: 'debentureBr',
              market: 'lse',
              currency: 'gbp',
              createdAt: DateTime(2024),
            ),
          );

      final read = (await dao.getAssets(userId)).single;
      expect(read.kind, AssetKind.cash);
      expect(read.market, Market.global);
      expect(read.currency, Currency.brl);
    });
  });
}
