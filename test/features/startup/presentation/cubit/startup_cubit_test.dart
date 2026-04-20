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
        );
        await cubit.initialize();

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
        );
        await cubit.initialize();

        expect(cubit.state, isA<StartupError>());
        addTearDown(cubit.close);
      },
    );

    test(
      'initialize emits Unauthenticated when unauthenticated',
      () async {
        whenListen<AuthState>(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const Unauthenticated(),
        );

        final cubit = StartupCubit(
          authBloc: mockAuthBloc,
          syncService: mockSyncService,
        );
        await cubit.initialize();

        expect(cubit.state, isA<StartupUnauthenticated>());
        addTearDown(cubit.close);
      },
    );

    test('waits for auth stream and syncs on Authenticated', () async {
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
      final future = cubit.initialize();
      controller.add(Authenticated(user));

      await future;

      expect(cubit.state, isA<StartupAuthenticated>());
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });
    });

    test('waits for auth stream and emits Unauthenticated', () async {
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
      final future = cubit.initialize();
      controller.add(const Unauthenticated());

      await future;

      expect(cubit.state, isA<StartupUnauthenticated>());
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });
    });

    test(
      'initialize emits StartupLoading with checking auth step first',
      () async {
        final user = UserFactory.entity();
        final states = <StartupState>[];

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
        );
        cubit.stream.listen(states.add);
        await cubit.initialize();

        expect(states.length, greaterThanOrEqualTo(2));
        final checkingState = states.first;
        expect(checkingState, isA<StartupLoading>());
        expect(
          (checkingState as StartupLoading).step,
          'Checking authentication...',
        );
        expect(checkingState.progress, 0);

        addTearDown(cubit.close);
      },
    );

    test(
      'emits StartupLoading with syncing step before completing',
      () async {
        final user = UserFactory.entity();
        final states = <StartupState>[];

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
        );
        cubit.stream.listen(states.add);
        await cubit.initialize();

        final syncState = states.whereType<StartupLoading>().where(
          (s) => s.step == 'Syncing data...',
        );
        expect(syncState, isNotEmpty);
        expect(syncState.first.progress, 0.3);

        addTearDown(cubit.close);
      },
    );

    test(
      'initialize waits when state is AuthInitial',
      () async {
        final controller = StreamController<AuthState>();

        whenListen<AuthState>(
          mockAuthBloc,
          controller.stream,
          initialState: const AuthInitial(),
        );

        final cubit =
            StartupCubit(
                authBloc: mockAuthBloc,
                syncService: mockSyncService,
              )
              // ignore: unawaited_futures
              ..initialize();

        // Should be loading while waiting for auth
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state, isA<StartupLoading>());
        verifyNever(
          () => mockSyncService.fullSync(
            userId: any(named: 'userId'),
            user: any(named: 'user'),
          ),
        );

        // Resolve auth
        controller.add(const Unauthenticated());
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, isA<StartupUnauthenticated>());
        addTearDown(() async {
          await cubit.close();
          await controller.close();
        });
      },
    );
  });
}
