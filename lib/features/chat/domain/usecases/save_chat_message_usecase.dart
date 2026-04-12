import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';

class SaveChatMessageUseCase {
  const SaveChatMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, void>> call(ChatMessageEntity message) =>
      _repository.saveChatMessage(message);
}
