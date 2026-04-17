import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockSignInWithGoogleUseCase mockSignInWithGoogle;
  late MockSignOutUseCase mockSignOut;
  late MockGetCurrentUserUseCase mockGetCurrentUser;

  setUp(() {
    mockSignIn = MockSignInUseCase();
    mockSignUp = MockSignUpUseCase();
    mockSignInWithGoogle = MockSignInWithGoogleUseCase();
    mockSignOut = MockSignOutUseCase();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
    signInUseCase: mockSignIn,
    signInWithGoogleUseCase: mockSignInWithGoogle,
    signUpUseCase: mockSignUp,
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
        'emits [Unauthenticated] on failure',
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

    group('AuthSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Authenticated] on success',
        setUp: () {
          when(
            () => mockSignIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Right(UserFactory.entity()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const AuthSignInRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Error] on failure',
        setUp: () {
          when(
            () => mockSignIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer(
            (_) async => const Left(AuthFailure('Invalid credentials')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const AuthSignInRequested(
            email: 'test@example.com',
            password: 'wrong',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('AuthSignUpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Authenticated] on success',
        setUp: () {
          when(
            () => mockSignUp(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Right(UserFactory.entity()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const AuthSignUpRequested(
            name: 'Test User',
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [Loading, Error] on failure',
        setUp: () {
          when(
            () => mockSignUp(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer(
            (_) async => const Left(AuthFailure('Email in use')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const AuthSignUpRequested(
            name: 'Test',
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
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
        'emits [Loading, Error] on failure',
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
  });
}
