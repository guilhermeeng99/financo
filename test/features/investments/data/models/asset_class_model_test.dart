import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/investments/data/models/asset_class_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/asset_class_factory.dart';

void main() {
  group('AssetClassModel', () {
    group('fromEntity', () {
      test('preserves all fields of a root class', () {
        final entity = AssetClassFactory.stocks();
        final model = AssetClassModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.userId, entity.userId);
        expect(model.name, entity.name);
        expect(model.icon, entity.icon);
        expect(model.color, entity.color);
        expect(model.targetPercent, entity.targetPercent);
        expect(model.parentId, isNull);
        expect(model.createdAt, entity.createdAt);
      });

      test('preserves parentId for a subclass', () {
        final parent = AssetClassFactory.stocks();
        final entity = AssetClassFactory.subclass(
          id: 'class-aapl',
          name: 'Apple',
          parent: parent,
        );
        final model = AssetClassModel.fromEntity(entity);

        expect(model.parentId, parent.id);
        expect(model.targetPercent, 0);
      });
    });

    group('toJson', () {
      test('serialises a root class and omits id and parentId', () {
        final model = AssetClassModel.fromEntity(
          AssetClassFactory.stocks(
            userId: 'user-9',
            icon: 100,
            color: 200,
            targetPercent: 30,
            createdAt: DateTime(2024, 5),
          ),
        );
        final json = model.toJson();

        expect(json['userId'], 'user-9');
        expect(json['name'], 'Ações');
        expect(json['icon'], 100);
        expect(json['color'], 200);
        expect(json['targetPercent'], 30.0);
        expect(json['createdAt'], isA<Timestamp>());
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('parentId'), isFalse);
      });

      test('includes parentId only when present', () {
        final parent = AssetClassFactory.stocks();
        final model = AssetClassModel.fromEntity(
          AssetClassFactory.subclass(
            id: 'class-aapl',
            name: 'Apple',
            parent: parent,
          ),
        );
        final json = model.toJson();

        expect(json['parentId'], parent.id);
      });
    });

    group('fromMap', () {
      test('deserialises a Firestore document', () {
        final createdAt = DateTime(2024, 3, 2, 9, 30);
        final model = AssetClassModel.fromMap(
          id: 'class-1',
          data: {
            'userId': 'user-1',
            'name': 'Renda Fixa',
            'icon': 123,
            'color': 456,
            'targetPercent': 40.0,
            'parentId': 'class-root',
            'createdAt': Timestamp.fromDate(createdAt),
          },
        );

        expect(model.id, 'class-1');
        expect(model.userId, 'user-1');
        expect(model.name, 'Renda Fixa');
        expect(model.icon, 123);
        expect(model.color, 456);
        expect(model.targetPercent, 40.0);
        expect(model.parentId, 'class-root');
        expect(model.createdAt, createdAt);
      });

      test('coerces an int targetPercent to double', () {
        final model = AssetClassModel.fromMap(
          id: 'class-1',
          data: {
            'userId': 'user-1',
            'name': 'Stocks',
            'icon': 1,
            'color': 2,
            'targetPercent': 25,
            'createdAt': Timestamp.fromDate(DateTime(2024)),
          },
        );

        expect(model.targetPercent, 25.0);
        expect(model.targetPercent, isA<double>());
      });

      test('defaults targetPercent to 0 when missing', () {
        final model = AssetClassModel.fromMap(
          id: 'class-1',
          data: {
            'userId': 'user-1',
            'name': 'Stocks',
            'icon': 1,
            'color': 2,
            'createdAt': Timestamp.fromDate(DateTime(2024)),
          },
        );

        expect(model.targetPercent, 0);
        expect(model.parentId, isNull);
      });

      test('parses an ISO-8601 string createdAt', () {
        final model = AssetClassModel.fromMap(
          id: 'class-1',
          data: const {
            'userId': 'user-1',
            'name': 'Stocks',
            'icon': 1,
            'color': 2,
            'targetPercent': 10.0,
            'createdAt': '2024-07-15T08:00:00.000',
          },
        );

        expect(model.createdAt, DateTime(2024, 7, 15, 8));
      });
    });

    test('toJson then fromMap round-trips the data', () {
      final original = AssetClassModel.fromEntity(
        AssetClassFactory.realEstate(
          userId: 'user-3',
          targetPercent: 35,
          createdAt: DateTime(2024, 6, 1, 12),
        ),
      );
      final json = original.toJson();
      final restored = AssetClassModel.fromMap(id: original.id, data: json);

      expect(restored, original);
    });
  });
}
