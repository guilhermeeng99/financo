import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/data/datasources/chat_datasources.dart';
import 'package:financo/features/chat/data/models/chat_message_model.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required GeminiDataSource geminiDataSource,
    required ChatRemoteDataSource chatRemoteDataSource,
  }) : _gemini = geminiDataSource,
       _chatRemote = chatRemoteDataSource;

  final GeminiDataSource _gemini;
  final ChatRemoteDataSource _chatRemote;

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String userId,
    required String content,
    required List<ChatMessageEntity> history,
  }) async {
    try {
      final response = await _gemini.sendMessage(
        userId: userId,
        content: content,
        history: history,
      );

      await _chatRemote.saveChatMessage(response);
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
}
