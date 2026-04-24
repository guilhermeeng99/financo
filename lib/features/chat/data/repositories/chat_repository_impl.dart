import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/data/datasources/chat_datasources.dart';
import 'package:financo/features/chat/data/models/chat_message_model.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatBackendDataSource chatBackendDataSource,
    required ChatRemoteDataSource chatRemoteDataSource,
  }) : _backend = chatBackendDataSource,
       _chatRemote = chatRemoteDataSource;

  final ChatBackendDataSource _backend;
  final ChatRemoteDataSource _chatRemote;

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String userId,
    required String content,
    required List<ChatMessageEntity> history,
    ChatImageAttachment? image,
  }) async {
    try {
      final response = await _backend.sendMessage(
        userId: userId,
        content: content,
        history: history,
        image: image,
      );
      return Right(response);
    } on AiException catch (e) {
      return Left(AiFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory({
    required String userId,
  }) async {
    try {
      final messages = await _chatRemote.getChatHistory(userId: userId);
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveChatMessage(
    ChatMessageEntity message,
  ) async {
    try {
      final model = ChatMessageModel.fromEntity(message);
      await _chatRemote.saveChatMessage(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> transcribeAudio({
    required String base64Data,
    required String mimeType,
  }) async {
    try {
      final transcript = await _backend.transcribeAudio(
        base64Data: base64Data,
        mimeType: mimeType,
      );
      return Right(transcript);
    } on AiException catch (e) {
      return Left(AiFailure(e.message));
    }
  }
}
