import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockProfileRemoteDataSource mockRemote;
  late MockUsersDao mockUsersDao;
  late MockAppDatabase mockDatabase;
  late ProfileRepositoryImpl repository;

  setUpAll(registerAuthFallbackValues);

  setUp(() {
    mockRemote = MockProfileRemoteDataSource();
    mockUsersDao = MockUsersDao();
    mockDatabase = MockAppDatabase();
    repository = ProfileRepositoryImpl(
      remoteDataSource: mockRemote,
      usersDao: mockUsersDao,
      database: mockDatabase,
    );
  });

  const userId = 'user-1';

  group('getProfile', () {
    test('returns local user when DAO has cached data', () async {
      final user = UserFactory.entity();
      when(() => mockUsersDao.getUser(userId)).thenAnswer((_) async => user);

      final result = await repository.getProfile(userId);

      expect(result, Right<Failure, UserEntity>(user));
      verifyNever(() => mockRemote.getProfile(any()));
    });

    test(
      'fetches from remote and caches when DAO returns null',
      () async {
        final user = UserFactory.entity();
        final model = UserModel.fromEntity(user);
        when(() => mockUsersDao.getUser(userId)).thenAnswer(
          (_) async => null,
        );
        when(() => mockRemote.getProfile(userId)).thenAnswer(
          (_) async => model,
        );
        when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.getProfile(userId);

        expect(result.isRight(), isTrue);
        verify(() => mockUsersDao.upsertUser(model)).called(1);
      },
    );

    test('returns ServerFailure when remote throws', () async {
      when(() => mockUsersDao.getUser(userId)).thenAnswer((_) async => null);
      when(() => mockRemote.getProfile(userId)).thenThrow(
        const ServerException('Failed to fetch profile.'),
      );

      final result = await repository.getProfile(userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('updateProfile', () {
    test('forwards to remote and caches locally', () async {
      final user = UserFactory.entity();
      when(() => mockRemote.updateProfile(user)).thenAnswer((_) async {});
      when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

      final result = await repository.updateProfile(user);

      expect(result, Right<Failure, UserEntity>(user));
      verify(() => mockRemote.updateProfile(user)).called(1);
      verify(() => mockUsersDao.upsertUser(any())).called(1);
    });

    test('returns ServerFailure when remote update fails', () async {
      final user = UserFactory.entity();
      when(() => mockRemote.updateProfile(user)).thenThrow(
        const ServerException('Failed to update profile.'),
      );

      final result = await repository.updateProfile(user);

      expect(result.isLeft(), isTrue);
      verifyNever(() => mockUsersDao.upsertUser(any()));
    });
  });

  group('clearAccountData', () {
    test('wipes remote then clears local tables', () async {
      when(() => mockRemote.wipeUserData(userId)).thenAnswer((_) async {});
      when(mockDatabase.clearAllTables).thenAnswer((_) async {});

      final result = await repository.clearAccountData(userId);

      expect(result, const Right<Failure, void>(null));
      verifyInOrder([
        () => mockRemote.wipeUserData(userId),
        mockDatabase.clearAllTables,
      ]);
    });

    test('returns ServerFailure when remote wipe fails', () async {
      when(() => mockRemote.wipeUserData(userId)).thenThrow(
        const ServerException('Failed to clear account data.'),
      );

      final result = await repository.clearAccountData(userId);

      expect(result.isLeft(), isTrue);
      verifyNever(mockDatabase.clearAllTables);
    });
  });
}
