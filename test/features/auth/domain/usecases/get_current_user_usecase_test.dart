import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  test('should delegate to repository.getCurrentUser', () async {
    final user = UserFactory.entity();
    when(
      () => mockRepository.getCurrentUser(),
    ).thenAnswer((_) async => Right<Failure, UserEntity?>(user));

    final result = await useCase();

    expect(result, Right<Failure, UserEntity?>(user));
    verify(() => mockRepository.getCurrentUser()).called(1);
  });

  test('should return Right(null) when no current user', () async {
    when(
      () => mockRepository.getCurrentUser(),
    ).thenAnswer((_) async => const Right<Failure, UserEntity?>(null));

    final result = await useCase();

    expect(result, const Right<Failure, UserEntity?>(null));
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.getCurrentUser(),
    ).thenAnswer(
      (_) async => const Left<Failure, UserEntity?>(ServerFailure()),
    );

    final result = await useCase();

    expect(result, isA<Left<Failure, UserEntity?>>());
  });
}
