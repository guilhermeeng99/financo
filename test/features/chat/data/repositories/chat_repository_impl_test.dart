import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/chat_message_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGeminiDataSource mockGemini;
  late MockChatRemoteDataSource mockRemote;
  late ChatRepositoryImpl repository;

  setUpAll(registerChatFallbackValues);

  setUp(() {
    mockGemini = MockGeminiDataSource();
    mockRemote = MockChatRemoteDataSource();
    repository = ChatRepositoryImpl(
      geminiDataSource: mockGemini,
      chatRemoteDataSource: mockRemote,
    );
  });

  const userId = 'user-1';

  group('sendMessage', () {
    const content = 'Add expense';

    test('should call Gemini, persist response, and return Right', () async {
      final response = ChatMessageFactory.model(
        id: 'resp-1',
        role: ChatRole.assistant,
        content: 'Done!',
      );
      when(
        () => mockGemini.sendMessage(
          userId: any(named: 'userId'),
          content: any(named: 'content'),
          history: any(named: 'history'),
        ),
      ).thenAnswer((_) async => response);
      when(
        () => mockRemote.saveChatMessage(any()),
      ).thenAnswer((_) async {});

      final result = await repository.sendMessage(
        userId: userId,
        content: content,
        history: const [],
      );

      expect(result, Right<Failure, ChatMessageEntity>(response));
      verify(() => mockRemote.saveChatMessage(response)).called(1);
    });

    test('should return AiFailure on AiException', () async {
      when(
        () => mockGemini.sendMessage(
          userId: any(named: 'userId'),
          content: any(named: 'content'),
          history: any(named: 'history'),
        ),
      ).thenThrow(const AiException('AI error'));

      final result = await repository.sendMessage(
        userId: userId,
        content: content,
        history: const [],
      );

      expect(result, isA<Left<Failure, ChatMessageEntity>>());
      result.fold(
        (f) => expect(f, isA<AiFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should return ServerFailure on ServerException', () async {
      final response = ChatMessageFactory.model();
      when(
        () => mockGemini.sendMessage(
          userId: any(named: 'userId'),
          content: any(named: 'content'),
          history: any(named: 'history'),
        ),
      ).thenAnswer((_) async => response);
      when(
        () => mockRemote.saveChatMessage(any()),
      ).thenThrow(const ServerException('Save failed'));

      final result = await repository.sendMessage(
        userId: userId,
        content: content,
        history: const [],
      );

      expect(result, isA<Left<Failure, ChatMessageEntity>>());
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getChatHistory', () {
    test('should return messages on success', () async {
      final models = [
        ChatMessageFactory.model(),
        ChatMessageFactory.model(
          id: 'msg-2',
          role: ChatRole.assistant,
          content: 'Response',
        ),
      ];
      when(
        () => mockRemote.getChatHistory(userId: any(named: 'userId')),
      ).thenAnswer((_) async => models);

      final result = await repository.getChatHistory(userId: userId);

      expect(
        result,
        Right<Failure, List<ChatMessageEntity>>(models),
      );
    });

    test('should return ServerFailure on ServerException', () async {
      when(
        () => mockRemote.getChatHistory(userId: any(named: 'userId')),
      ).thenThrow(const ServerException());

      final result = await repository.getChatHistory(userId: userId);

      expect(result, isA<Left<Failure, List<ChatMessageEntity>>>());
    });
  });

  group('saveChatMessage', () {
    test('should convert to model and persist', () async {
      final entity = ChatMessageFactory.entity();
      when(
        () => mockRemote.saveChatMessage(any()),
      ).thenAnswer((_) async {});

      final result = await repository.saveChatMessage(entity);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemote.saveChatMessage(any())).called(1);
    });

    test('should return ServerFailure on ServerException', () async {
      when(
        () => mockRemote.saveChatMessage(any()),
      ).thenThrow(const ServerException());

      final result = await repository.saveChatMessage(
        ChatMessageFactory.entity(),
      );

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
