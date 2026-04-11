import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatMessageEntity>> call({
    required String userId,
    required String content,
    required List<ChatMessageEntity> history,
  }) => _repository.sendMessage(
    userId: userId,
    content: content,
    history: history,
  );
}
