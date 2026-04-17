import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignUpUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpUseCase(mockRepository);
  });

  const name = 'Test User';
  const email = 'test@example.com';
  const password = 'password123';

  test('should delegate to repository.signUp', () async {
    final user = UserFactory.entity();
    when(
      () => mockRepository.signUp(
        name: name,
        email: email,
        password: password,
      ),
    ).thenAnswer((_) async => Right<Failure, UserEntity>(user));

    final result = await useCase(
      name: name,
      email: email,
      password: password,
    );

    expect(result, Right<Failure, UserEntity>(user));
    verify(
      () => mockRepository.signUp(
        name: name,
        email: email,
        password: password,
      ),
    ).called(1);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.signUp(
        name: name,
        email: email,
        password: password,
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, UserEntity>(
        AuthFailure('Email already in use'),
      ),
    );

    final result = await useCase(
      name: name,
      email: email,
      password: password,
    );

    expect(result, isA<Left<Failure, UserEntity>>());
  });
}
