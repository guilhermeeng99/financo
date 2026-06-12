import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/presentation/cubit/asset_holding_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/asset_holding_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateAssetHoldingUseCase createAssetHolding;
  late MockUpdateAssetHoldingUseCase updateAssetHolding;

  const userId = 'user-1';

  setUpAll(registerInvestmentFallbackValues);

  setUp(() {
    createAssetHolding = MockCreateAssetHoldingUseCase();
    updateAssetHolding = MockUpdateAssetHoldingUseCase();
  });

  AssetHoldingFormCubit buildCubit({
    double availableForAccount = 5000,
    AssetHoldingEntity? existing,
    String? presetAccountId,
    String? presetClassId,
  }) => AssetHoldingFormCubit(
    createAssetHolding: createAssetHolding,
    updateAssetHolding: updateAssetHolding,
    userId: userId,
    availableForAccount: availableForAccount,
    existingHolding: existing,
    presetAccountId: presetAccountId,
    presetClassId: presetClassId,
  );

  group('initial state', () {
    test('create mode starts blank and invalid', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      expect(cubit.state.isEditing, isFalse);
      expect(cubit.state.accountId, isEmpty);
      expect(cubit.state.assetClassId, isEmpty);
      expect(cubit.state.isValid, isFalse);
    });

    test('presets pre-fill the pickers', () {
      final cubit = buildCubit(
        presetAccountId: 'acc-inv-1',
        presetClassId: 'class-stocks',
      );
      addTearDown(cubit.close);
      expect(cubit.state.accountId, 'acc-inv-1');
      expect(cubit.state.assetClassId, 'class-stocks');
    });

    test('edit mode hydrates from the existing holding', () {
      final existing = AssetHoldingFactory.holding(amount: 2000);
      final cubit = buildCubit(existing: existing);
      addTearDown(cubit.close);
      expect(cubit.state.isEditing, isTrue);
      expect(cubit.state.amount, 2000);
      expect(cubit.state.isValid, isTrue);
    });
  });

  group('validation against the available balance', () {
    test('an amount above the account availability is invalid', () {
      final cubit = buildCubit(
        availableForAccount: 1000,
        presetAccountId: 'acc-inv-1',
        presetClassId: 'class-stocks',
      )..updateAmount(1500);
      addTearDown(cubit.close);
      expect(cubit.state.isValid, isFalse);
    });

    test('switching account refreshes the availability ceiling', () {
      final cubit = buildCubit(
        availableForAccount: 1000,
        presetAccountId: 'acc-inv-1',
        presetClassId: 'class-stocks',
      )..updateAmount(1500);
      addTearDown(cubit.close);
      expect(cubit.state.isValid, isFalse);

      cubit.updateAccount('acc-inv-2', newAvailable: 2000);
      expect(cubit.state.accountId, 'acc-inv-2');
      expect(cubit.state.isValid, isTrue);
    });

    test('negative amounts are floored to zero', () {
      final cubit = buildCubit()..updateAmount(-50);
      addTearDown(cubit.close);
      expect(cubit.state.amount, 0);
    });

    test('updateNotes stores text and clears on empty input', () {
      final cubit = buildCubit()..updateNotes('long term');
      addTearDown(cubit.close);
      expect(cubit.state.notes, 'long term');

      cubit.updateNotes('');
      expect(cubit.state.notes, isNull);
    });
  });

  group('submit', () {
    blocTest<AssetHoldingFormCubit, AssetHoldingFormState>(
      'is a no-op while invalid',
      build: buildCubit,
      act: (cubit) => cubit.submit(),
      expect: () => const <AssetHoldingFormState>[],
      verify: (_) {
        verifyNever(() => createAssetHolding(any()));
        verifyNever(() => updateAssetHolding(any()));
      },
    );

    blocTest<AssetHoldingFormCubit, AssetHoldingFormState>(
      'creates a new holding and emits success',
      setUp: () {
        when(() => createAssetHolding(any()))
            .thenAnswer((_) async => Right(AssetHoldingFactory.holding()));
      },
      build: () => buildCubit(
        presetAccountId: 'acc-inv-1',
        presetClassId: 'class-stocks',
      ),
      act: (cubit) async {
        cubit.updateAmount(1200);
        await cubit.submit();
      },
      skip: 1,
      expect: () => [
        isA<AssetHoldingFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<AssetHoldingFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.success,
        ),
      ],
      verify: (_) {
        final entity = verify(() => createAssetHolding(captureAny()))
            .captured
            .single as AssetHoldingEntity;
        expect(entity.id, isEmpty);
        expect(entity.userId, userId);
        expect(entity.accountId, 'acc-inv-1');
        expect(entity.assetClassId, 'class-stocks');
        expect(entity.amount, 1200);
        verifyNever(() => updateAssetHolding(any()));
      },
    );

    blocTest<AssetHoldingFormCubit, AssetHoldingFormState>(
      'routes edits through the update use case keeping the id',
      setUp: () {
        when(() => updateAssetHolding(any()))
            .thenAnswer((_) async => Right(AssetHoldingFactory.holding()));
      },
      build: () => buildCubit(existing: AssetHoldingFactory.holding()),
      act: (cubit) async {
        cubit.updateAmount(750);
        await cubit.submit();
      },
      skip: 1,
      expect: () => [
        isA<AssetHoldingFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<AssetHoldingFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.success,
        ),
      ],
      verify: (_) {
        final entity = verify(() => updateAssetHolding(captureAny()))
            .captured
            .single as AssetHoldingEntity;
        expect(entity.id, AssetHoldingFactory.holding().id);
        expect(entity.amount, 750);
        verifyNever(() => createAssetHolding(any()));
      },
    );

    blocTest<AssetHoldingFormCubit, AssetHoldingFormState>(
      'emits failure carrying the domain failure when the save is rejected',
      setUp: () {
        when(() => createAssetHolding(any())).thenAnswer(
          (_) async => const Left(AllocationExceedsBalanceFailure(800)),
        );
      },
      build: () => buildCubit(
        presetAccountId: 'acc-inv-1',
        presetClassId: 'class-stocks',
      ),
      act: (cubit) async {
        cubit.updateAmount(900);
        await cubit.submit();
      },
      skip: 1,
      expect: () => [
        isA<AssetHoldingFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<AssetHoldingFormState>()
            .having((s) => s.status, 'status', FormStatus.failure)
            .having(
              (s) => s.failure,
              'failure',
              isA<AllocationExceedsBalanceFailure>(),
            ),
      ],
    );
  });
}
