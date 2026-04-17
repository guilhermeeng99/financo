import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/chat_message_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockChatRepository mockRepository;
  late SendMessageUseCase useCase;

  setUpAll(registerChatFallbackValues);

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = SendMessageUseCase(mockRepository);
  });

  const userId = 'user-1';
  const content = r'Add expense of R$ 50';

  test('should delegate to repository and return response', () async {
    final response = ChatMessageFactory.assistant();
    when(
      () => mockRepository.sendMessage(
        userId: any(named: 'userId'),
        content: any(named: 'content'),
        history: any(named: 'history'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, ChatMessageEntity>(response),
    );

    final result = await useCase(
      userId: userId,
      content: content,
      history: const [],
    );

    expect(result, Right<Failure, ChatMessageEntity>(response));
    verify(
      () => mockRepository.sendMessage(
        userId: userId,
        content: content,
        history: const [],
      ),
    ).called(1);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.sendMessage(
        userId: any(named: 'userId'),
        content: any(named: 'content'),
        history: any(named: 'history'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, ChatMessageEntity>(
        AiFailure('AI error'),
      ),
    );

    final result = await useCase(
      userId: userId,
      content: content,
      history: const [],
    );

    expect(result, isA<Left<Failure, ChatMessageEntity>>());
  });
}
