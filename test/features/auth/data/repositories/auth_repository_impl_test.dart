import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockUsersDao mockUsersDao;
  late MockSyncService mockSyncService;
  late MockAccessControlRepository mockAccessControl;

  setUpAll(registerAuthFallbackValues);

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockUsersDao = MockUsersDao();
    mockSyncService = MockSyncService();
    mockAccessControl = MockAccessControlRepository();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      usersDao: mockUsersDao,
      syncService: mockSyncService,
      accessControlRepository: mockAccessControl,
    );
  });

  void stubAllowed({required bool allowed}) {
    when(
      () => mockAccessControl.isEmailAllowed(any()),
    ).thenAnswer((_) async => Right(allowed));
  }

  group('signInWithGoogle', () {
    test('returns user and upserts local when allowlist allows', () async {
      final model = UserFactory.model();
      when(
        () => mockRemote.signInWithGoogle(),
      ).thenAnswer((_) async => model);
      stubAllowed(allowed: true);
      when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

      final result = await repository.signInWithGoogle();

      expect(result, Right<Failure, UserEntity>(model));
      verify(() => mockUsersDao.upsertUser(model)).called(1);
      verifyNever(() => mockRemote.signOut());
    });

    test('returns AccessDeniedFailure and signs out when blocked', () async {
      final model = UserFactory.model();
      when(
        () => mockRemote.signInWithGoogle(),
      ).thenAnswer((_) async => model);
      stubAllowed(allowed: false);
      when(() => mockRemote.signOut()).thenAnswer((_) async {});

      final result = await repository.signInWithGoogle();

      result.fold(
        (failure) {
          expect(failure, isA<AccessDeniedFailure>());
          expect((failure as AccessDeniedFailure).email, model.email);
        },
        (_) => fail('Expected Left'),
      );
      verify(() => mockRemote.signOut()).called(1);
      verifyNever(() => mockUsersDao.upsertUser(any()));
    });

    test('returns AuthFailure when AuthException thrown', () async {
      when(
        () => mockRemote.signInWithGoogle(),
      ).thenThrow(const AuthException('Google sign-in cancelled'));

      final result = await repository.signInWithGoogle();

      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure when generic Exception thrown', () async {
      when(
        () => mockRemote.signInWithGoogle(),
      ).thenThrow(Exception('Network error'));

      final result = await repository.signInWithGoogle();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('signOut', () {
    test('calls remote and clearLocalData on success', () async {
      when(() => mockRemote.signOut()).thenAnswer((_) async {});
      when(() => mockSyncService.clearLocalData()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemote.signOut()).called(1);
      verify(() => mockSyncService.clearLocalData()).called(1);
    });

    test('returns AuthFailure when AuthException thrown', () async {
      when(
        () => mockRemote.signOut(),
      ).thenThrow(const AuthException('Sign out failed'));

      final result = await repository.signOut();

      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => mockSyncService.clearLocalData());
    });
  });

  group('getCurrentUser', () {
    test('returns user when allowlist allows', () async {
      final model = UserFactory.model();
      when(
        () => mockRemote.getCurrentUser(),
      ).thenAnswer((_) async => model);
      stubAllowed(allowed: true);
      when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      expect(result, Right<Failure, UserEntity?>(model));
      verify(() => mockUsersDao.upsertUser(model)).called(1);
    });

    test('returns AccessDeniedFailure and signs out when blocked', () async {
      final model = UserFactory.model();
      when(
        () => mockRemote.getCurrentUser(),
      ).thenAnswer((_) async => model);
      stubAllowed(allowed: false);
      when(() => mockRemote.signOut()).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      result.fold(
        (failure) => expect(failure, isA<AccessDeniedFailure>()),
        (_) => fail('Expected Left'),
      );
      verify(() => mockRemote.signOut()).called(1);
    });

    test('returns Right(null) when no current user', () async {
      when(
        () => mockRemote.getCurrentUser(),
      ).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result, const Right<Failure, UserEntity?>(null));
      verifyNever(() => mockUsersDao.upsertUser(any()));
      verifyNever(() => mockAccessControl.isEmailAllowed(any()));
    });

    test('returns ServerFailure on remote exception', () async {
      when(
        () => mockRemote.getCurrentUser(),
      ).thenThrow(Exception('Network error'));

      final result = await repository.getCurrentUser();

      expect(result, isA<Left<Failure, UserEntity?>>());
    });
  });

  group('authStateChanges', () {
    test('passes user through when allowlist allows', () async {
      final user = UserFactory.model();
      when(
        () => mockRemote.authStateChanges,
      ).thenAnswer((_) => Stream.value(user));
      stubAllowed(allowed: true);

      await expectLater(repository.authStateChanges, emits(user));
    });

    test('signs out and yields null when allowlist blocks', () async {
      final user = UserFactory.model();
      when(
        () => mockRemote.authStateChanges,
      ).thenAnswer((_) => Stream.value(user));
      stubAllowed(allowed: false);
      when(() => mockRemote.signOut()).thenAnswer((_) async {});

      await expectLater(repository.authStateChanges, emits(null));
      verify(() => mockRemote.signOut()).called(1);
    });
  });
}
