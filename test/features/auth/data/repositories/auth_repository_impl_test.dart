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

  setUpAll(registerAuthFallbackValues);

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockUsersDao = MockUsersDao();
    mockSyncService = MockSyncService();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      usersDao: mockUsersDao,
      syncService: mockSyncService,
    );
  });

  group('signIn', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('should return user and upsert local on success', () async {
      final model = UserFactory.model();
      when(
        () => mockRemote.signIn(email: email, password: password),
      ).thenAnswer((_) async => model);
      when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

      final result = await repository.signIn(email: email, password: password);

      expect(result, Right<Failure, UserEntity>(model));
      verify(() => mockUsersDao.upsertUser(model)).called(1);
    });

    test('should return AuthFailure when AuthException thrown', () async {
      when(
        () => mockRemote.signIn(email: email, password: password),
      ).thenThrow(const AuthException('Invalid credentials'));

      final result = await repository.signIn(email: email, password: password);

      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should return ServerFailure when generic Exception thrown', () async {
      when(
        () => mockRemote.signIn(email: email, password: password),
      ).thenThrow(Exception('Network error'));

      final result = await repository.signIn(email: email, password: password);

      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('signInWithGoogle', () {
    test('should return user and upsert local on success', () async {
      final model = UserFactory.model();
      when(
        () => mockRemote.signInWithGoogle(),
      ).thenAnswer((_) async => model);
      when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

      final result = await repository.signInWithGoogle();

      expect(result, Right<Failure, UserEntity>(model));
      verify(() => mockUsersDao.upsertUser(model)).called(1);
    });

    test('should return AuthFailure when AuthException thrown', () async {
      when(
        () => mockRemote.signInWithGoogle(),
      ).thenThrow(const AuthException('Google sign-in cancelled'));

      final result = await repository.signInWithGoogle();

      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should return ServerFailure when generic Exception thrown', () async {
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

  group('signUp', () {
    const name = 'Test User';
    const email = 'test@example.com';
    const password = 'password123';

    test('should return user and upsert local on success', () async {
      final model = UserFactory.model();
      when(
        () => mockRemote.signUp(
          name: name,
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => model);
      when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

      final result = await repository.signUp(
        name: name,
        email: email,
        password: password,
      );

      expect(result, Right<Failure, UserEntity>(model));
      verify(() => mockUsersDao.upsertUser(model)).called(1);
    });

    test('should return AuthFailure when AuthException thrown', () async {
      when(
        () => mockRemote.signUp(
          name: name,
          email: email,
          password: password,
        ),
      ).thenThrow(const AuthException('Email already in use'));

      final result = await repository.signUp(
        name: name,
        email: email,
        password: password,
      );

      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should return ServerFailure when generic Exception thrown', () async {
      when(
        () => mockRemote.signUp(
          name: name,
          email: email,
          password: password,
        ),
      ).thenThrow(Exception('Network error'));

      final result = await repository.signUp(
        name: name,
        email: email,
        password: password,
      );

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('signOut', () {
    test('should call remote and clearLocalData on success', () async {
      when(() => mockRemote.signOut()).thenAnswer((_) async {});
      when(() => mockSyncService.clearLocalData()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemote.signOut()).called(1);
      verify(() => mockSyncService.clearLocalData()).called(1);
    });

    test('should return AuthFailure when AuthException thrown', () async {
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

    test('should return ServerFailure when generic Exception thrown', () async {
      when(() => mockRemote.signOut()).thenThrow(Exception('Network error'));

      final result = await repository.signOut();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => mockSyncService.clearLocalData());
    });
  });

  group('getCurrentUser', () {
    test('should return user and upsert local when found', () async {
      final model = UserFactory.model();
      when(
        () => mockRemote.getCurrentUser(),
      ).thenAnswer((_) async => model);
      when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      expect(result, Right<Failure, UserEntity?>(model));
      verify(() => mockUsersDao.upsertUser(model)).called(1);
    });

    test('should return Right(null) when no current user', () async {
      when(
        () => mockRemote.getCurrentUser(),
      ).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result, const Right<Failure, UserEntity?>(null));
      verifyNever(() => mockUsersDao.upsertUser(any()));
    });

    test('should return ServerFailure when exception thrown', () async {
      when(
        () => mockRemote.getCurrentUser(),
      ).thenThrow(Exception('Network error'));

      final result = await repository.getCurrentUser();

      expect(result, isA<Left<Failure, UserEntity?>>());
    });
  });

  group('authStateChanges', () {
    test('should delegate to remote datasource', () {
      final user = UserFactory.model();
      when(
        () => mockRemote.authStateChanges,
      ).thenAnswer((_) => Stream.value(user));

      final stream = repository.authStateChanges;

      expect(stream, emits(user));
    });
  });
}
