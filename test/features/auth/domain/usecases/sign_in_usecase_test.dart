import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignInUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  const email = 'test@example.com';
  const password = 'password123';

  test('should delegate to repository.signIn', () async {
    final user = UserFactory.entity();
    when(
      () => mockRepository.signIn(email: email, password: password),
    ).thenAnswer((_) async => Right<Failure, UserEntity>(user));

    final result = await useCase(email: email, password: password);

    expect(result, Right<Failure, UserEntity>(user));
    verify(
      () => mockRepository.signIn(email: email, password: password),
    ).called(1);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.signIn(email: email, password: password),
    ).thenAnswer(
      (_) async => const Left<Failure, UserEntity>(
        AuthFailure('Invalid credentials'),
      ),
    );

    final result = await useCase(email: email, password: password);

    expect(result, isA<Left<Failure, UserEntity>>());
  });
}
