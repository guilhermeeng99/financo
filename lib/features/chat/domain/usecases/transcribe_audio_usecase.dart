import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/repositories/chat_repository.dart';

class TranscribeAudioUseCase {
  const TranscribeAudioUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, String>> call({
    required String base64Data,
    required String mimeType,
  }) => _repository.transcribeAudio(
    base64Data: base64Data,
    mimeType: mimeType,
  );
}
