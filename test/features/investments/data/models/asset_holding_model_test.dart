import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/investments/data/models/asset_holding_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/asset_holding_factory.dart';

void main() {
  group('AssetHoldingModel', () {
    group('fromEntity', () {
      test('preserves all fields', () {
        final entity = AssetHoldingFactory.holding(
          amount: 2500,
          notes: 'long term',
        );
        final model = AssetHoldingModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.userId, entity.userId);
        expect(model.accountId, entity.accountId);
        expect(model.assetClassId, entity.assetClassId);
        expect(model.amount, entity.amount);
        expect(model.notes, 'long term');
        expect(model.updatedAt, entity.updatedAt);
      });
    });

    group('toJson', () {
      test('serialises a holding and omits id', () {
        final model = AssetHoldingModel.fromEntity(
          AssetHoldingFactory.holding(
            userId: 'user-9',
            accountId: 'acc-inv-9',
            assetClassId: 'class-9',
            amount: 1234.5,
            updatedAt: DateTime(2024, 5),
          ),
        );
        final json = model.toJson();

        expect(json['userId'], 'user-9');
        expect(json['accountId'], 'acc-inv-9');
        expect(json['assetClassId'], 'class-9');
        expect(json['amount'], 1234.5);
        expect(json['updatedAt'], isA<Timestamp>());
        expect(json.containsKey('id'), isFalse);
      });

      test('omits notes when null but includes them when present', () {
        final withoutNotes = AssetHoldingModel.fromEntity(
          AssetHoldingFactory.holding(),
        ).toJson();
        expect(withoutNotes.containsKey('notes'), isFalse);

        final withNotes = AssetHoldingModel.fromEntity(
          AssetHoldingFactory.holding(notes: 'rebalance Q3'),
        ).toJson();
        expect(withNotes['notes'], 'rebalance Q3');
      });
    });

    group('fromMap', () {
      test('deserialises a Firestore document', () {
        final updatedAt = DateTime(2024, 3, 2, 9, 30);
        final model = AssetHoldingModel.fromMap(
          id: 'holding-1',
          data: {
            'userId': 'user-1',
            'accountId': 'acc-inv-1',
            'assetClassId': 'class-stocks',
            'amount': 5000.0,
            'notes': 'core position',
            'updatedAt': Timestamp.fromDate(updatedAt),
          },
        );

        expect(model.id, 'holding-1');
        expect(model.userId, 'user-1');
        expect(model.accountId, 'acc-inv-1');
        expect(model.assetClassId, 'class-stocks');
        expect(model.amount, 5000.0);
        expect(model.notes, 'core position');
        expect(model.updatedAt, updatedAt);
      });

      test('coerces an int amount to double', () {
        final model = AssetHoldingModel.fromMap(
          id: 'holding-1',
          data: {
            'userId': 'user-1',
            'accountId': 'acc-inv-1',
            'assetClassId': 'class-stocks',
            'amount': 1000,
            'updatedAt': Timestamp.fromDate(DateTime(2024)),
          },
        );

        expect(model.amount, 1000.0);
        expect(model.amount, isA<double>());
      });

      test('defaults amount to 0 and notes to null when missing', () {
        final model = AssetHoldingModel.fromMap(
          id: 'holding-1',
          data: {
            'userId': 'user-1',
            'accountId': 'acc-inv-1',
            'assetClassId': 'class-stocks',
            'updatedAt': Timestamp.fromDate(DateTime(2024)),
          },
        );

        expect(model.amount, 0);
        expect(model.notes, isNull);
      });

      test('parses an ISO-8601 string updatedAt', () {
        final model = AssetHoldingModel.fromMap(
          id: 'holding-1',
          data: const {
            'userId': 'user-1',
            'accountId': 'acc-inv-1',
            'assetClassId': 'class-stocks',
            'amount': 10.0,
            'updatedAt': '2024-07-15T08:00:00.000',
          },
        );

        expect(model.updatedAt, DateTime(2024, 7, 15, 8));
      });
    });

    test('toJson then fromMap round-trips the data', () {
      final original = AssetHoldingModel.fromEntity(
        AssetHoldingFactory.holding(
          userId: 'user-3',
          amount: 7777.77,
          notes: 'keep',
          updatedAt: DateTime(2024, 6, 1, 12),
        ),
      );
      final json = original.toJson();
      final restored = AssetHoldingModel.fromMap(id: original.id, data: json);

      expect(restored, original);
    });
  });
}
