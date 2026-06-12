import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/master_panel/data/repositories/master_users_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../harness/factories/user_factory.dart';
import '../../../harness/mocks.dart';

void main() {
  late MasterUsersRepositoryImpl repository;
  late MockMasterUsersRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockMasterUsersRemoteDataSource();
    repository = MasterUsersRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('listAllUsers', () {
    test('returns users on success', () async {
      final users = [UserFactory.model()];
      when(() => mockRemote.listAllUsers()).thenAnswer((_) async => users);

      final result = await repository.listAllUsers();

      expect(result.isRight(), isTrue);
    });

    test('returns ServerFailure on exception', () async {
      when(
        () => mockRemote.listAllUsers(),
      ).thenThrow(const ServerException('boom'));

      final result = await repository.listAllUsers();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('deleteUserAsAdmin', () {
    test('returns Right on success', () async {
      when(() => mockRemote.deleteUserAsAdmin(any())).thenAnswer((_) async {});

      final result = await repository.deleteUserAsAdmin('uid-1');

      expect(result, const Right<Failure, void>(null));
    });

    test('returns AuthFailure on AuthException', () async {
      when(
        () => mockRemote.deleteUserAsAdmin(any()),
      ).thenThrow(const AuthException('not master'));

      final result = await repository.deleteUserAsAdmin('uid-1');

      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on ServerException', () async {
      when(
        () => mockRemote.deleteUserAsAdmin(any()),
      ).thenThrow(const ServerException('internal'));

      final result = await repository.deleteUserAsAdmin('uid-1');

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
