import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignInWithGoogleUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithGoogleUseCase(mockRepository);
  });

  test('should delegate to repository.signInWithGoogle', () async {
    final user = UserFactory.entity();
    when(
      () => mockRepository.signInWithGoogle(),
    ).thenAnswer((_) async => Right<Failure, UserEntity>(user));

    final result = await useCase();

    expect(result, Right<Failure, UserEntity>(user));
    verify(() => mockRepository.signInWithGoogle()).called(1);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.signInWithGoogle(),
    ).thenAnswer(
      (_) async => const Left<Failure, UserEntity>(
        AuthFailure('Google sign-in failed'),
      ),
    );

    final result = await useCase();

    expect(result, isA<Left<Failure, UserEntity>>());
  });
}
