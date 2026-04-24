import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String userId,
    required String content,
    required List<ChatMessageEntity> history,
    ChatImageAttachment? image,
  });

  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory({
    required String userId,
  });

  Future<Either<Failure, void>> saveChatMessage(ChatMessageEntity message);

  Future<Either<Failure, String>> transcribeAudio({
    required String base64Data,
    required String mimeType,
  });
}
