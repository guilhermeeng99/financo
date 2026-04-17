import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/user_factory.dart';

void main() {
  group('UserModel', () {
    group('fromEntity', () {
      test('should create model from entity with all fields', () {
        final entity = UserFactory.entity(
          photoUrl: 'https://example.com/photo.jpg',
        );
        final model = UserModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.name, entity.name);
        expect(model.email, entity.email);
        expect(model.photoUrl, 'https://example.com/photo.jpg');
        expect(model.createdAt, entity.createdAt);
      });

      test('should create model from entity with null photoUrl', () {
        final entity = UserFactory.entity();
        final model = UserModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.photoUrl, isNull);
      });
    });

    group('toJson', () {
      test('should serialize all fields except id', () {
        final model = UserFactory.model(
          photoUrl: 'https://example.com/photo.jpg',
        );
        final json = model.toJson();

        expect(json['name'], 'Test User');
        expect(json['email'], 'test@example.com');
        expect(json['photoUrl'], 'https://example.com/photo.jpg');
        expect(json['createdAt'], isA<Timestamp>());
        expect(json.containsKey('id'), isFalse);
      });

      test('should include null photoUrl', () {
        final model = UserFactory.model();
        final json = model.toJson();

        expect(json['photoUrl'], isNull);
      });
    });
  });
}
