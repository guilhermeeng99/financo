import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/usecases/remove_allowed_email_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late RemoveAllowedEmailUseCase useCase;
  late MockAccessControlRepository repo;

  setUp(() {
    repo = MockAccessControlRepository();
    useCase = RemoveAllowedEmailUseCase(repo);
  });

  group('RemoveAllowedEmailUseCase', () {
    const email = 'gone@example.com';

    test('delegates to repository.removeAllowedEmail', () async {
      when(
        () => repo.removeAllowedEmail(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(email);

      expect(result, const Right<Failure, void>(null));
      verify(() => repo.removeAllowedEmail(email)).called(1);
    });

    test('forwards a Left failure from the repository', () async {
      when(() => repo.removeAllowedEmail(any())).thenAnswer(
        (_) async => const Left(ServerFailure('remove failed')),
      );

      final result = await useCase(email);

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
