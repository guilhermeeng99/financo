import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockSignInWithGoogleUseCase mockSignInWithGoogle;
  late MockSignOutUseCase mockSignOut;
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late StreamController<UserEntity?> authStreamController;

  setUp(() {
    mockSignInWithGoogle = MockSignInWithGoogleUseCase();
    mockSignOut = MockSignOutUseCase();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    authStreamController = StreamController<UserEntity?>.broadcast();

    when(
      () => mockGetCurrentUser.authStateChanges,
    ).thenAnswer((_) => authStreamController.stream);
  });

  tearDown(() => authStreamController.close());

  AuthBloc buildBloc() => AuthBloc(
    signInWithGoogleUseCase: mockSignInWithGoogle,
    signOutUseCase: mockSignOut,
    getCurrentUser: mockGetCurrentUser,
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<AuthInitial>());
      addTearDown(bloc.close);
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Authenticated] when user found',
        setUp: () {
          when(
            () => mockGetCurrentUser(),
          ).thenAnswer((_) async => Right(UserFactory.entity()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [isA<Authenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when user is null',
        setUp: () {
          when(
            () => mockGetCurrentUser(),
          ).thenAnswer((_) async => const Right(null));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [isA<Unauthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AccessDenied] when allowlist gate blocks',
        setUp: () {
          when(
            () => mockGetCurrentUser(),
          ).thenAnswer(
            (_) async =>
                const Left(AccessDeniedFailure('blocked@example.com')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          predicate<AuthState>(
            (state) =>
                state is AccessDenied &&
                state.email == 'blocked@example.com',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] on generic failure',
        setUp: () {
          when(
            () => mockGetCurrentUser(),
          ).thenAnswer((_) async => const Left(ServerFailure()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [isA<Unauthenticated>()],
      );
    });

    group('AuthGoogleSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Authenticated] on success',
        setUp: () {
          when(
            () => mockSignInWithGoogle(),
          ).thenAnswer((_) async => Right(UserFactory.entity()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Loading, AccessDenied] when allowlist gate blocks',
        setUp: () {
          when(() => mockSignInWithGoogle()).thenAnswer(
            (_) async =>
                const Left(AccessDeniedFailure('friend@example.com')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          isA<AuthLoading>(),
          predicate<AuthState>(
            (state) => state is AccessDenied &&
                state.email == 'friend@example.com',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Error] on generic failure',
        setUp: () {
          when(
            () => mockSignInWithGoogle(),
          ).thenAnswer(
            (_) async => const Left(AuthFailure('Google sign-in failed')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] on success',
        setUp: () {
          when(
            () => mockSignOut(),
          ).thenAnswer((_) async => const Right(null));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [isA<Unauthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Error] on failure',
        setUp: () {
          when(
            () => mockSignOut(),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Sign out failed')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [isA<AuthError>()],
      );
    });

    group('AuthUserChanged', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Authenticated] when user is not null',
        build: buildBloc,
        act: (bloc) => bloc.add(AuthUserChanged(UserFactory.entity())),
        expect: () => [isA<Authenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when user is null',
        build: buildBloc,
        act: (bloc) => bloc.add(const AuthUserChanged(null)),
        expect: () => [isA<Unauthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'reacts to authStateChanges stream',
        build: buildBloc,
        act: (bloc) async {
          authStreamController.add(UserFactory.entity());
          await Future<void>.delayed(Duration.zero);
        },
        expect: () => [isA<Authenticated>()],
      );
    });
  });
}
