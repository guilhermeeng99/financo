import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/investments/data/datasources/asset_class_remote_datasource.dart';
import 'package:financo/features/investments/data/models/asset_class_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/asset_class_factory.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AssetClassRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = AssetClassRemoteDataSourceImpl(firestore: firestore);
  });

  group('createAssetClass', () {
    test('persists the model and returns it with the generated id', () async {
      final model = AssetClassModel.fromEntity(AssetClassFactory.stocks());

      final created = await datasource.createAssetClass(model);

      expect(created.id, isNotEmpty);
      expect(created.name, model.name);
      expect(created.targetPercent, model.targetPercent);
      expect(created.icon, model.icon);
      expect(created.color, model.color);
      expect(created.userId, userId);
    });

    test('round-trips the parentId of a subclass', () async {
      final parent = await datasource.createAssetClass(
        AssetClassModel.fromEntity(AssetClassFactory.stocks()),
      );
      final child = await datasource.createAssetClass(
        AssetClassModel.fromEntity(
          AssetClassFactory.subclass(
            id: 'sub-1',
            name: 'PETR4',
            parent: parent,
          ),
        ),
      );

      expect(child.parentId, parent.id);
      expect(child.targetPercent, 0);
    });
  });

  group('getAssetClasses', () {
    test("returns only the given user's classes", () async {
      await datasource.createAssetClass(
        AssetClassModel.fromEntity(AssetClassFactory.stocks()),
      );
      await datasource.createAssetClass(
        AssetClassModel.fromEntity(
          AssetClassFactory.crypto(userId: 'user-2'),
        ),
      );

      final classes = await datasource.getAssetClasses(userId: userId);

      expect(classes, hasLength(1));
      expect(classes.single.userId, userId);
    });
  });

  group('updateAssetClass', () {
    test('overwrites stored fields and returns the fresh doc', () async {
      final created = await datasource.createAssetClass(
        AssetClassModel.fromEntity(AssetClassFactory.stocks()),
      );

      final updated = await datasource.updateAssetClass(
        AssetClassModel.fromEntity(
          AssetClassFactory.stocks(
            id: created.id,
            name: 'Renamed',
            targetPercent: 40,
          ),
        ),
      );

      expect(updated.name, 'Renamed');
      expect(updated.targetPercent, 40);
    });
  });

  group('deleteAssetClass', () {
    test('removes the doc, leaving siblings intact', () async {
      final keep = await datasource.createAssetClass(
        AssetClassModel.fromEntity(AssetClassFactory.stocks()),
      );
      final drop = await datasource.createAssetClass(
        AssetClassModel.fromEntity(AssetClassFactory.crypto()),
      );

      await datasource.deleteAssetClass(drop.id);

      final remaining = await datasource.getAssetClasses(userId: userId);
      expect(remaining.map((c) => c.id).toList(), [keep.id]);
    });
  });
}
