import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/usecases/add_allowed_email_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late AddAllowedEmailUseCase useCase;
  late MockAccessControlRepository repo;

  setUp(() {
    repo = MockAccessControlRepository();
    useCase = AddAllowedEmailUseCase(repo);
  });

  group('AddAllowedEmailUseCase', () {
    const email = 'new@example.com';

    test('delegates to repository.addAllowedEmail with email and note',
        () async {
      when(
        () => repo.addAllowedEmail(
          email: any(named: 'email'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(email: email, note: 'invited');

      expect(result, const Right<Failure, void>(null));
      verify(
        () => repo.addAllowedEmail(email: email, note: 'invited'),
      ).called(1);
    });

    test('passes a null note through to the repository', () async {
      when(
        () => repo.addAllowedEmail(
          email: any(named: 'email'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await useCase(email: email);

      verify(() => repo.addAllowedEmail(email: email)).called(1);
    });

    test('forwards a Left failure from the repository', () async {
      when(
        () => repo.addAllowedEmail(
          email: any(named: 'email'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('add failed')));

      final result = await useCase(email: email);

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
