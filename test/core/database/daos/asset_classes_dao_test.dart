import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/asset_classes_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/asset_class_factory.dart';

void main() {
  late AppDatabase db;
  late AssetClassesDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.assetClassesDao;
  });

  tearDown(() => db.close());

  group('upsertAssetClass + getAssetClassById', () {
    test('round-trips an asset class exactly', () async {
      final stocks = AssetClassFactory.stocks();

      await dao.upsertAssetClass(stocks);

      expect(await dao.getAssetClassById(stocks.id), stocks);
    });

    test('round-trips a subclass with parentId and a zero target', () async {
      // Subclasses persist `targetPercent: 0` per spec rule 3 — a lost zero
      // would make the allocation totals over-allocate.
      final subclass = AssetClassFactory.subclass(
        id: 'class-petr4',
        name: 'PETR4',
        parent: AssetClassFactory.stocks(),
      );

      await dao.upsertAssetClass(subclass);

      final read = await dao.getAssetClassById('class-petr4');
      expect(read!.parentId, 'class-stocks');
      expect(read.targetPercent, 0);
    });

    test('overwrites on conflict rather than duplicating', () async {
      await dao.upsertAssetClass(AssetClassFactory.stocks());
      await dao.upsertAssetClass(AssetClassFactory.stocks(targetPercent: 40));

      final all = await dao.getAssetClasses(userId);
      expect(all, hasLength(1));
      expect(all.single.targetPercent, 40);
    });

    test('returns null for an unknown id', () async {
      expect(await dao.getAssetClassById('nope'), isNull);
    });
  });

  group('getAssetClasses', () {
    test('scopes to the user and orders by name', () async {
      await dao.insertAllAssetClasses([
        ...AssetClassFactory.arcaList(),
        AssetClassFactory.stocks(id: 'class-foreign', userId: 'user-2'),
      ]);

      final classes = await dao.getAssetClasses(userId);

      expect(classes.map((c) => c.name).toList(), [
        'Ações',
        'Bitcoin',
        'Real Estate',
        'Renda Fixa',
      ]);
    });

    test('returns an empty list when the user has none', () async {
      expect(await dao.getAssetClasses(userId), isEmpty);
    });
  });

  group('insertAllAssetClasses', () {
    test('writes the whole batch and is safe to replay', () async {
      await dao.insertAllAssetClasses(AssetClassFactory.arcaList());
      await dao.insertAllAssetClasses(AssetClassFactory.arcaList());

      expect(await dao.getAssetClasses(userId), hasLength(4));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllAssetClasses([]);

      expect(await dao.getAssetClasses(userId), isEmpty);
    });
  });

  group('deletes', () {
    test('deleteAssetClass removes one row only', () async {
      await dao.insertAllAssetClasses(AssetClassFactory.arcaList());

      await dao.deleteAssetClass('class-crypto');

      final remaining = await dao.getAssetClasses(userId);
      expect(remaining.map((c) => c.id), isNot(contains('class-crypto')));
      expect(remaining, hasLength(3));
    });

    test('deleteAllAssetClasses clears every user', () async {
      await dao.insertAllAssetClasses([
        AssetClassFactory.stocks(),
        AssetClassFactory.stocks(id: 'class-foreign', userId: 'user-2'),
      ]);

      await dao.deleteAllAssetClasses();

      expect(await dao.getAssetClasses(userId), isEmpty);
      expect(await dao.getAssetClasses('user-2'), isEmpty);
    });
  });
}
