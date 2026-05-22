import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/master_panel/domain/repositories/master_users_repository.dart';
import 'package:financo/features/master_panel/domain/usecases/delete_user_as_admin_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMasterUsersRepository extends Mock
    implements MasterUsersRepository {}

void main() {
  late DeleteUserAsAdminUseCase useCase;
  late _MockMasterUsersRepository repo;

  setUp(() {
    repo = _MockMasterUsersRepository();
    useCase = DeleteUserAsAdminUseCase(repo);
  });

  group('DeleteUserAsAdminUseCase', () {
    const targetUid = 'user-42';

    test('delegates to repository.deleteUserAsAdmin', () async {
      when(
        () => repo.deleteUserAsAdmin(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(targetUid);

      expect(result, const Right<Failure, void>(null));
      verify(() => repo.deleteUserAsAdmin(targetUid)).called(1);
    });

    test('forwards a Left failure from the repository', () async {
      when(() => repo.deleteUserAsAdmin(any())).thenAnswer(
        (_) async => const Left(ServerFailure('delete failed')),
      );

      final result = await useCase(targetUid);

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
