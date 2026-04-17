import 'package:financo/features/chat/data/models/chat_message_model.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/chat_message_factory.dart';

void main() {
  group('ChatMessageModel', () {
    group('fromEntity', () {
      test('should convert entity with all fields', () {
        final entity = ChatMessageFactory.withMetadata(
          content: 'Created!',
          metadata: {'actionType': 'transaction', 'amount': 50.0},
          createdAt: DateTime(2024, 6, 15),
        );

        final model = ChatMessageModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.userId, entity.userId);
        expect(model.role, entity.role);
        expect(model.content, entity.content);
        expect(model.metadata, entity.metadata);
        expect(model.createdAt, entity.createdAt);
      });

      test('should convert entity with null metadata', () {
        final entity = ChatMessageFactory.entity();

        final model = ChatMessageModel.fromEntity(entity);

        expect(model.metadata, isNull);
      });
    });

    group('toJson', () {
      test('should exclude id and serialize correctly', () {
        final model = ChatMessageFactory.model(
          metadata: {'actionType': 'account'},
          createdAt: DateTime(2024, 6, 15),
        );

        final json = model.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json['userId'], 'user-1');
        expect(json['role'], 'user');
        expect(json['content'], 'Hello');
        expect(json['metadata'], {'actionType': 'account'});
        expect(json['createdAt'], isNotNull);
      });

      test('should serialize assistant role as name', () {
        final model = ChatMessageFactory.model(
          role: ChatRole.assistant,
          content: 'Hi!',
        );

        final json = model.toJson();

        expect(json['role'], 'assistant');
      });

      test('should include null metadata', () {
        final model = ChatMessageFactory.model();

        final json = model.toJson();

        expect(json['metadata'], isNull);
      });
    });
  });
}
