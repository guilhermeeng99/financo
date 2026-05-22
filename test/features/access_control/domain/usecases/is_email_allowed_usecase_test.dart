import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/usecases/is_email_allowed_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late IsEmailAllowedUseCase useCase;
  late MockAccessControlRepository repo;

  setUp(() {
    repo = MockAccessControlRepository();
    useCase = IsEmailAllowedUseCase(repo);
  });

  group('IsEmailAllowedUseCase', () {
    const email = 'someone@example.com';

    test('delegates to repository.isEmailAllowed and forwards true', () async {
      when(
        () => repo.isEmailAllowed(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await useCase(email);

      expect(result, const Right<Failure, bool>(true));
      verify(() => repo.isEmailAllowed(email)).called(1);
    });

    test('forwards a false Right value from the repository', () async {
      when(
        () => repo.isEmailAllowed(any()),
      ).thenAnswer((_) async => const Right(false));

      final result = await useCase(email);

      expect(result, const Right<Failure, bool>(false));
    });

    test('forwards a Left failure from the repository', () async {
      when(() => repo.isEmailAllowed(any())).thenAnswer(
        (_) async => const Left(ServerFailure('lookup failed')),
      );

      final result = await useCase(email);

      expect(result, isA<Left<Failure, bool>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
