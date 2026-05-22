import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';
import 'package:financo/features/access_control/domain/usecases/list_allowed_emails_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late ListAllowedEmailsUseCase useCase;
  late MockAccessControlRepository repo;

  setUp(() {
    repo = MockAccessControlRepository();
    useCase = ListAllowedEmailsUseCase(repo);
  });

  group('ListAllowedEmailsUseCase', () {
    test('delegates to repository.listAllowedEmails and forwards the list',
        () async {
      final emails = [
        AllowedEmailEntity(email: 'a@example.com', addedAt: DateTime(2026)),
        AllowedEmailEntity(
          email: 'b@example.com',
          addedAt: DateTime(2026, 2),
          note: 'beta tester',
        ),
      ];
      when(
        () => repo.listAllowedEmails(),
      ).thenAnswer((_) async => Right(emails));

      final result = await useCase();

      expect(result, Right<Failure, List<AllowedEmailEntity>>(emails));
      verify(() => repo.listAllowedEmails()).called(1);
    });

    test('forwards a Left failure from the repository', () async {
      when(() => repo.listAllowedEmails()).thenAnswer(
        (_) async => const Left(ServerFailure('list failed')),
      );

      final result = await useCase();

      expect(result, isA<Left<Failure, List<AllowedEmailEntity>>>());
    });
  });
}
