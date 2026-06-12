import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/presentation/cubit/fifty_thirty_twenty_targets_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetFiftyThirtyTwentyTargetsUseCase getTargets;
  late MockUpdateFiftyThirtyTwentyTargetsUseCase updateTargets;

  const userId = 'user-1';
  const customTargets = FiftyThirtyTwentyTargets(
    needs: 0.6,
    wants: 0.2,
    savings: 0.2,
  );

  setUpAll(registerDashboardFallbackValues);

  setUp(() {
    getTargets = MockGetFiftyThirtyTwentyTargetsUseCase();
    updateTargets = MockUpdateFiftyThirtyTwentyTargetsUseCase();
  });

  FiftyThirtyTwentyTargetsCubit buildCubit() => FiftyThirtyTwentyTargetsCubit(
    getTargets: getTargets,
    updateTargets: updateTargets,
    userId: userId,
  );

  test('initial state defaults to the classic split', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    expect(cubit.state.status, FiftyThirtyTwentyTargetsStatus.initial);
    expect(cubit.state.targets, FiftyThirtyTwentyTargets.classic);
    expect(cubit.state.failure, isNull);
  });

  group('loadTargets', () {
    blocTest<FiftyThirtyTwentyTargetsCubit, FiftyThirtyTwentyTargetsState>(
      'emits loading then ready with the fetched targets',
      setUp: () {
        when(() => getTargets(userId))
            .thenAnswer((_) async => const Right(customTargets));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadTargets(),
      expect: () => const [
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.loading,
          targets: FiftyThirtyTwentyTargets.classic,
        ),
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          targets: customTargets,
        ),
      ],
    );

    blocTest<FiftyThirtyTwentyTargetsCubit, FiftyThirtyTwentyTargetsState>(
      'keeps the classic fallback and carries the failure on error',
      setUp: () {
        when(() => getTargets(userId))
            .thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadTargets(),
      expect: () => const [
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.loading,
          targets: FiftyThirtyTwentyTargets.classic,
        ),
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          targets: FiftyThirtyTwentyTargets.classic,
          failure: ServerFailure(),
        ),
      ],
    );

    blocTest<FiftyThirtyTwentyTargetsCubit, FiftyThirtyTwentyTargetsState>(
      'is a no-op when targets are already loaded cleanly',
      setUp: () {
        when(() => getTargets(userId))
            .thenAnswer((_) async => const Right(customTargets));
      },
      build: buildCubit,
      seed: () => const FiftyThirtyTwentyTargetsState(
        status: FiftyThirtyTwentyTargetsStatus.ready,
        targets: customTargets,
      ),
      act: (cubit) => cubit.loadTargets(),
      expect: () => const <FiftyThirtyTwentyTargetsState>[],
      verify: (_) => verifyNever(() => getTargets(any())),
    );

    blocTest<FiftyThirtyTwentyTargetsCubit, FiftyThirtyTwentyTargetsState>(
      'retries after a failed load instead of treating it as cached',
      setUp: () {
        when(() => getTargets(userId))
            .thenAnswer((_) async => const Right(customTargets));
      },
      build: buildCubit,
      seed: () => const FiftyThirtyTwentyTargetsState(
        status: FiftyThirtyTwentyTargetsStatus.ready,
        targets: FiftyThirtyTwentyTargets.classic,
        failure: ServerFailure(),
      ),
      act: (cubit) => cubit.loadTargets(),
      expect: () => const [
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.loading,
          targets: FiftyThirtyTwentyTargets.classic,
          failure: ServerFailure(),
        ),
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          targets: customTargets,
        ),
      ],
    );
  });

  group('submitTargets', () {
    blocTest<FiftyThirtyTwentyTargetsCubit, FiftyThirtyTwentyTargetsState>(
      'emits saving then ready with the persisted targets',
      setUp: () {
        when(
          () => updateTargets(
            userId: userId,
            targets: customTargets,
          ),
        ).thenAnswer((_) async => const Right(customTargets));
      },
      build: buildCubit,
      act: (cubit) => cubit.submitTargets(customTargets),
      expect: () => const [
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.saving,
          targets: FiftyThirtyTwentyTargets.classic,
        ),
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          targets: customTargets,
        ),
      ],
    );

    blocTest<FiftyThirtyTwentyTargetsCubit, FiftyThirtyTwentyTargetsState>(
      'keeps the previous targets when the save fails',
      setUp: () {
        when(
          () => updateTargets(
            userId: userId,
            targets: customTargets,
          ),
        ).thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: buildCubit,
      act: (cubit) => cubit.submitTargets(customTargets),
      expect: () => const [
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.saving,
          targets: FiftyThirtyTwentyTargets.classic,
        ),
        // Optimistic swap happens only on success: a failed save must not
        // surface the rejected split to the dashboard.
        FiftyThirtyTwentyTargetsState(
          status: FiftyThirtyTwentyTargetsStatus.ready,
          targets: FiftyThirtyTwentyTargets.classic,
          failure: ServerFailure(),
        ),
      ],
    );
  });
}
