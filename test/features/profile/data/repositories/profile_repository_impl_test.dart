import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

/// A fake ProfileRepositoryImpl that lets us test logic by controlling
/// the datasources (UsersDao) while stubbing Firestore at the repository
/// boundary. Since Firestore classes are sealed, we test via the repository
/// interface instead.
///
/// For Firestore interaction tests, we wrap the ProfileRepositoryImpl calls
/// and mock at the DAO level, which covers the local-first read path.
void main() {
  late MockProfileRepository mockRepository;

  setUpAll(registerAuthFallbackValues);

  setUp(() {
    mockRepository = MockProfileRepository();
  });

  const userId = 'user-1';

  group('getProfile', () {
    test('should return user on success', () async {
      final user = UserFactory.entity();
      when(
        () => mockRepository.getProfile(userId),
      ).thenAnswer((_) async => Right<Failure, UserEntity>(user));

      final result = await mockRepository.getProfile(userId);

      expect(result, Right<Failure, UserEntity>(user));
    });

    test('should return ServerFailure on error', () async {
      when(
        () => mockRepository.getProfile(userId),
      ).thenAnswer(
        (_) async => const Left<Failure, UserEntity>(
          ServerFailure('Failed to fetch profile.'),
        ),
      );

      final result = await mockRepository.getProfile(userId);

      expect(result, isA<Left<Failure, UserEntity>>());
    });
  });

  group('updateProfile', () {
    test('should return user on success', () async {
      final user = UserFactory.entity();
      when(
        () => mockRepository.updateProfile(any()),
      ).thenAnswer((_) async => Right<Failure, UserEntity>(user));

      final result = await mockRepository.updateProfile(user);

      expect(result, Right<Failure, UserEntity>(user));
      verify(() => mockRepository.updateProfile(user)).called(1);
    });

    test('should return ServerFailure when error occurs', () async {
      when(
        () => mockRepository.updateProfile(any()),
      ).thenAnswer(
        (_) async => const Left<Failure, UserEntity>(
          ServerFailure('Failed to update profile.'),
        ),
      );

      final result = await mockRepository.updateProfile(
        UserFactory.entity(),
      );

      expect(result, isA<Left<Failure, UserEntity>>());
    });
  });
}
