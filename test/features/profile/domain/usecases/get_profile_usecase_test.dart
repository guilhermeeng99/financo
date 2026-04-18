import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockProfileRepository mockRepository;
  late GetProfileUseCase useCase;

  const userId = 'user-1';

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfileUseCase(mockRepository);
  });

  test('delegates to repository.getProfile', () async {
    final user = UserFactory.entity();
    when(
      () => mockRepository.getProfile(userId),
    ).thenAnswer((_) async => Right(user));

    final result = await useCase(userId);

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (u) => expect(u, user),
    );
    verify(() => mockRepository.getProfile(userId)).called(1);
  });

  test('returns failure from repository', () async {
    when(
      () => mockRepository.getProfile(userId),
    ).thenAnswer(
      (_) async => const Left(ServerFailure('Failed')),
    );

    final result = await useCase(userId);

    expect(result.isLeft(), isTrue);
  });
}
