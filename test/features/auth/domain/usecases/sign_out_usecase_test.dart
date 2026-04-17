import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignOutUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockRepository);
  });

  test('should delegate to repository.signOut', () async {
    when(
      () => mockRepository.signOut(),
    ).thenAnswer((_) async => const Right<Failure, void>(null));

    final result = await useCase();

    expect(result, const Right<Failure, void>(null));
    verify(() => mockRepository.signOut()).called(1);
  });

  test('should return failure when repository fails', () async {
    when(
      () => mockRepository.signOut(),
    ).thenAnswer(
      (_) async => const Left<Failure, void>(
        ServerFailure('Sign out failed'),
      ),
    );

    final result = await useCase();

    expect(result, isA<Left<Failure, void>>());
  });
}
