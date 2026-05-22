import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/master_panel/domain/repositories/master_users_repository.dart';
import 'package:financo/features/master_panel/domain/usecases/list_all_users_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';

class _MockMasterUsersRepository extends Mock
    implements MasterUsersRepository {}

void main() {
  late ListAllUsersUseCase useCase;
  late _MockMasterUsersRepository repo;

  setUp(() {
    repo = _MockMasterUsersRepository();
    useCase = ListAllUsersUseCase(repo);
  });

  group('ListAllUsersUseCase', () {
    test('delegates to repository.listAllUsers and forwards the list',
        () async {
      final users = UserFactory.list();
      when(() => repo.listAllUsers()).thenAnswer((_) async => Right(users));

      final result = await useCase();

      expect(result, Right<Failure, List<UserEntity>>(users));
      verify(() => repo.listAllUsers()).called(1);
    });

    test('forwards a Left failure from the repository', () async {
      when(() => repo.listAllUsers()).thenAnswer(
        (_) async => const Left(ServerFailure('list failed')),
      );

      final result = await useCase();

      expect(result, isA<Left<Failure, List<UserEntity>>>());
    });
  });
}
