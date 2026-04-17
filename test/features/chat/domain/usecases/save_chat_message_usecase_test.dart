import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/chat_message_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockChatRepository mockRepository;
  late SaveChatMessageUseCase useCase;

  setUpAll(registerChatFallbackValues);

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = SaveChatMessageUseCase(mockRepository);
  });

  test('should delegate to repository and return void', () async {
    final message = ChatMessageFactory.entity();
    when(
      () => mockRepository.saveChatMessage(any()),
    ).thenAnswer(
      (_) async => const Right<Failure, void>(null),
    );

    final result = await useCase(message);

    expect(result, const Right<Failure, void>(null));
    verify(() => mockRepository.saveChatMessage(message)).called(1);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.saveChatMessage(any()),
    ).thenAnswer(
      (_) async => const Left<Failure, void>(ServerFailure()),
    );

    final result = await useCase(ChatMessageFactory.entity());

    expect(result, isA<Left<Failure, void>>());
  });
}
