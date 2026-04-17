import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/chat_message_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockChatRepository mockRepository;
  late GetChatHistoryUseCase useCase;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = GetChatHistoryUseCase(mockRepository);
  });

  const userId = 'user-1';

  test('should delegate to repository and return messages', () async {
    final messages = ChatMessageFactory.history();
    when(
      () => mockRepository.getChatHistory(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => Right<Failure, List<ChatMessageEntity>>(messages),
    );

    final result = await useCase(userId: userId);

    expect(
      result,
      Right<Failure, List<ChatMessageEntity>>(messages),
    );
    verify(
      () => mockRepository.getChatHistory(userId: userId),
    ).called(1);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.getChatHistory(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => const Left<Failure, List<ChatMessageEntity>>(
        ServerFailure(),
      ),
    );

    final result = await useCase(userId: userId);

    expect(result, isA<Left<Failure, List<ChatMessageEntity>>>());
  });
}
