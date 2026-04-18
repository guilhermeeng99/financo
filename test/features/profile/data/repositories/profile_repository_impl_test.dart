import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late FirebaseFirestore firestore;
  late MockUsersDao mockUsersDao;
  late ProfileRepositoryImpl repository;

  setUpAll(registerAuthFallbackValues);

  setUp(() {
    firestore = FakeFirebaseFirestore();
    mockUsersDao = MockUsersDao();
    repository = ProfileRepositoryImpl(
      firestore: firestore,
      usersDao: mockUsersDao,
    );
  });

  const userId = 'user-1';

  group('getProfile', () {
    test('returns local user when DAO has cached data', () async {
      final mockFirestore = MockFirebaseFirestore();
      final user = UserFactory.entity();
      repository = ProfileRepositoryImpl(
        firestore: mockFirestore,
        usersDao: mockUsersDao,
      );
      when(() => mockUsersDao.getUser(userId)).thenAnswer((_) async => user);

      final result = await repository.getProfile(userId);

      expect(result, Right<Failure, UserEntity>(user));
      verify(() => mockUsersDao.getUser(userId)).called(1);
      verifyNever(() => mockFirestore.collection(any()));
    });

    test(
      'fetches from Firestore and caches when DAO returns null',
      () async {
        when(() => mockUsersDao.getUser(userId)).thenAnswer((_) async => null);
        await firestore.collection('users').doc(userId).set({
          'name': 'Test User',
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(DateTime(2024)),
        });
        when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.getProfile(userId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (user) {
            expect(user.id, userId);
            expect(user.name, 'Test User');
            expect(user.email, 'test@example.com');
          },
        );
        verify(() => mockUsersDao.upsertUser(any())).called(1);
      },
    );

    test('returns ServerFailure when DAO throws', () async {
      when(
        () => mockUsersDao.getUser(userId),
      ).thenThrow(Exception('DB error'));

      final result = await repository.getProfile(userId);

      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure when Firestore throws', () async {
      final mockFirestore = MockFirebaseFirestore();
      repository = ProfileRepositoryImpl(
        firestore: mockFirestore,
        usersDao: mockUsersDao,
      );
      when(() => mockUsersDao.getUser(userId)).thenAnswer((_) async => null);
      when(() => mockFirestore.collection('users')).thenThrow(
        Exception('Network error'),
      );

      final result = await repository.getProfile(userId);

      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) => expect(failure.message, 'Failed to fetch profile.'),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('updateProfile', () {
    test(
      'updates Firestore then caches locally and returns user',
      () async {
        final user = UserFactory.entity();
        await firestore.collection('users').doc(user.id).set({
          'name': 'Old Name',
          'email': 'old@example.com',
          'createdAt': Timestamp.fromDate(user.createdAt),
        });
        when(() => mockUsersDao.upsertUser(any())).thenAnswer((_) async {});

        final result = await repository.updateProfile(user);
        final snapshot = await firestore.collection('users').doc(user.id).get();

        expect(result, Right<Failure, UserEntity>(user));
        expect(snapshot.exists, isTrue);
        expect(snapshot.data(), isNotNull);
        expect(snapshot.data()!['name'], user.name);
        expect(snapshot.data()!['email'], user.email);
        verify(() => mockUsersDao.upsertUser(any())).called(1);
      },
    );

    test('returns ServerFailure when Firestore update throws', () async {
      final mockFirestore = MockFirebaseFirestore();
      final user = UserFactory.entity();
      repository = ProfileRepositoryImpl(
        firestore: mockFirestore,
        usersDao: mockUsersDao,
      );
      when(() => mockFirestore.collection('users')).thenThrow(
        Exception('Permission denied'),
      );

      final result = await repository.updateProfile(user);

      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) => expect(failure.message, 'Failed to update profile.'),
        (_) => fail('Expected Left'),
      );
      verifyNever(() => mockUsersDao.upsertUser(any()));
    });

    test('returns ServerFailure when DAO upsert throws', () async {
      final user = UserFactory.entity();
      await firestore.collection('users').doc(user.id).set({
        'name': 'Old Name',
        'email': 'old@example.com',
        'createdAt': Timestamp.fromDate(user.createdAt),
      });
      when(
        () => mockUsersDao.upsertUser(any()),
      ).thenThrow(Exception('DB error'));

      final result = await repository.updateProfile(user);

      expect(result, isA<Left<Failure, UserEntity>>());
    });
  });
}
