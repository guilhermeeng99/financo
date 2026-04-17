import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_event.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/startup/presentation/cubit/startup_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockSyncService mockSyncService;

  setUpAll(registerAuthFallbackValues);

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockSyncService = MockSyncService();
  });

  group('StartupCubit', () {
    test('initial state is StartupInitial', () {
      whenListen<AuthState>(
        mockAuthBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthInitial(),
      );

      final cubit = StartupCubit(
        authBloc: mockAuthBloc,
        syncService: mockSyncService,
      );

      expect(cubit.state, isA<StartupInitial>());
      addTearDown(cubit.close);
    });

    test(
      'initialize emits Authenticated when already authenticated',
      () async {
        final user = UserFactory.entity();
        whenListen<AuthState>(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: Authenticated(user),
        );
        when(
          () => mockSyncService.fullSync(
            userId: any(named: 'userId'),
            user: any(named: 'user'),
          ),
        ).thenAnswer((_) async {});

        final cubit = StartupCubit(
          authBloc: mockAuthBloc,
          syncService: mockSyncService,
        )..initialize();

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, isA<StartupAuthenticated>());
        verify(
          () => mockSyncService.fullSync(userId: user.id, user: user),
        ).called(1);
        addTearDown(cubit.close);
      },
    );

    test(
      'initialize emits Error when sync fails',
      () async {
        final user = UserFactory.entity();
        whenListen<AuthState>(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: Authenticated(user),
        );
        when(
          () => mockSyncService.fullSync(
            userId: any(named: 'userId'),
            user: any(named: 'user'),
          ),
        ).thenThrow(Exception('Sync failed'));

        final cubit = StartupCubit(
          authBloc: mockAuthBloc,
          syncService: mockSyncService,
        )..initialize();

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, isA<StartupError>());
        addTearDown(cubit.close);
      },
    );

    test(
      'initialize emits Unauthenticated when unauthenticated',
      () {
        whenListen<AuthState>(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const Unauthenticated(),
        );

        final cubit = StartupCubit(
          authBloc: mockAuthBloc,
          syncService: mockSyncService,
        )..initialize();

        expect(cubit.state, isA<StartupUnauthenticated>());
        addTearDown(cubit.close);
      },
    );

    test('responds to auth stream Authenticated event', () async {
      final user = UserFactory.entity();
      final controller = StreamController<AuthState>();

      whenListen<AuthState>(
        mockAuthBloc,
        controller.stream,
        initialState: const AuthInitial(),
      );
      when(
        () => mockSyncService.fullSync(
          userId: any(named: 'userId'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async {});

      final cubit = StartupCubit(
        authBloc: mockAuthBloc,
        syncService: mockSyncService,
      );
      controller.add(Authenticated(user));

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<StartupAuthenticated>());
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });
    });

    test('responds to auth stream Unauthenticated event', () async {
      final controller = StreamController<AuthState>();

      whenListen<AuthState>(
        mockAuthBloc,
        controller.stream,
        initialState: const AuthInitial(),
      );

      final cubit = StartupCubit(
        authBloc: mockAuthBloc,
        syncService: mockSyncService,
      );
      controller.add(const Unauthenticated());

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<StartupUnauthenticated>());
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });
    });
  });
}
