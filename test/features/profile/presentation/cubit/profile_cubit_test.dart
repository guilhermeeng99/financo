import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetProfileUseCase mockGetProfile;

  const userId = 'user-1';

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
  });

  ProfileCubit buildCubit() => ProfileCubit(
    getProfile: mockGetProfile,
    userId: userId,
  );

  group('ProfileCubit', () {
    test('initial state is ProfileInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<ProfileInitial>());
      addTearDown(cubit.close);
    });

    blocTest<ProfileCubit, ProfileState>(
      'emits [Loading, Loaded] on success',
      setUp: () {
        when(
          () => mockGetProfile(userId),
        ).thenAnswer((_) async => Right(UserFactory.entity()));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>().having(
          (s) => s.user.id,
          'user.id',
          'user-1',
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [Loading, Error] on failure',
      setUp: () {
        when(
          () => mockGetProfile(userId),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to fetch profile.')),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>(),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'does not reload when already Loaded and not forceRefresh',
      setUp: () {
        when(
          () => mockGetProfile(userId),
        ).thenAnswer((_) async => Right(UserFactory.entity()));
      },
      build: buildCubit,
      seed: () => ProfileLoaded(UserFactory.entity()),
      act: (cubit) => cubit.loadProfile(),
      expect: () => <ProfileState>[],
      verify: (_) {
        verifyNever(() => mockGetProfile(any()));
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'reloads when forceRefresh is true',
      setUp: () {
        when(
          () => mockGetProfile(userId),
        ).thenAnswer((_) async => Right(UserFactory.entity()));
      },
      build: buildCubit,
      seed: () => ProfileLoaded(UserFactory.entity()),
      act: (cubit) => cubit.loadProfile(forceRefresh: true),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
      ],
    );
  });
}
