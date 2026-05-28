import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/chat/domain/usecases/transcribe_audio_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockChatRepository mockRepository;
  late TranscribeAudioUseCase useCase;

  const base64Data = 'AAECAwQF';
  const mimeType = 'audio/webm';

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = TranscribeAudioUseCase(mockRepository);
  });

  test('should forward args to repository and return Right unchanged',
      () async {
    const transcript = 'spent fifty reais on lunch';
    when(
      () => mockRepository.transcribeAudio(
        base64Data: any(named: 'base64Data'),
        mimeType: any(named: 'mimeType'),
      ),
    ).thenAnswer((_) async => const Right<Failure, String>(transcript));

    final result = await useCase(base64Data: base64Data, mimeType: mimeType);

    expect(result, const Right<Failure, String>(transcript));
    final captured = verify(
      () => mockRepository.transcribeAudio(
        base64Data: captureAny(named: 'base64Data'),
        mimeType: captureAny(named: 'mimeType'),
      ),
    ).captured;
    expect(captured, <String>[base64Data, mimeType]);
  });

  test('should return Left unchanged when repository fails', () async {
    const failure = ServerFailure();
    when(
      () => mockRepository.transcribeAudio(
        base64Data: any(named: 'base64Data'),
        mimeType: any(named: 'mimeType'),
      ),
    ).thenAnswer((_) async => const Left<Failure, String>(failure));

    final result = await useCase(base64Data: base64Data, mimeType: mimeType);

    expect(result, const Left<Failure, String>(failure));
  });
}
