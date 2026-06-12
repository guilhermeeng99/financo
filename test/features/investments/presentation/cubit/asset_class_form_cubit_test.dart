import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/presentation/cubit/asset_class_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/asset_class_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateAssetClassUseCase createAssetClass;
  late MockUpdateAssetClassUseCase updateAssetClass;

  const userId = 'user-1';

  setUpAll(registerInvestmentFallbackValues);

  setUp(() {
    createAssetClass = MockCreateAssetClassUseCase();
    updateAssetClass = MockUpdateAssetClassUseCase();
  });

  AssetClassFormCubit buildCubit({
    AssetClassEntity? existing,
    String? presetParentId,
    int? presetParentIcon,
    int? presetParentColor,
  }) => AssetClassFormCubit(
    createAssetClass: createAssetClass,
    updateAssetClass: updateAssetClass,
    userId: userId,
    existingAssetClass: existing,
    presetParentId: presetParentId,
    presetParentIcon: presetParentIcon,
    presetParentColor: presetParentColor,
  );

  group('initial state', () {
    test('create mode starts blank and invalid', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      expect(cubit.state.isEditing, isFalse);
      expect(cubit.state.name, isEmpty);
      expect(cubit.state.isValid, isFalse);
    });

    test('edit mode hydrates from the existing class', () {
      final existing = AssetClassFactory.stocks(targetPercent: 30);
      final cubit = buildCubit(existing: existing);
      addTearDown(cubit.close);
      expect(cubit.state.isEditing, isTrue);
      expect(cubit.state.name, existing.name);
      expect(cubit.state.targetPercent, 30);
      expect(cubit.state.isValid, isTrue);
    });

    test('preset parent mirrors icon and color into the form', () {
      final parent = AssetClassFactory.stocks();
      final cubit = buildCubit(
        presetParentId: parent.id,
        presetParentIcon: parent.icon,
        presetParentColor: parent.color,
      );
      addTearDown(cubit.close);
      expect(cubit.state.isSubclass, isTrue);
      expect(cubit.state.parentId, parent.id);
      expect(cubit.state.icon, parent.icon);
      expect(cubit.state.color, parent.color);
    });
  });

  group('field updates', () {
    test('updateTargetPercent clamps to the [0, 100] range', () {
      final cubit = buildCubit()
        ..updateName('Stocks')
        ..updateTargetPercent(140);
      addTearDown(cubit.close);
      expect(cubit.state.targetPercent, 100);

      cubit.updateTargetPercent(-5);
      expect(cubit.state.targetPercent, 0);
    });

    test('updateParent copies the parent appearance, clearing promotes back '
        'to root', () {
      final parent = AssetClassFactory.realEstate();
      final cubit = buildCubit()..updateParent(parent);
      addTearDown(cubit.close);
      expect(cubit.state.parentId, parent.id);
      expect(cubit.state.icon, parent.icon);
      expect(cubit.state.color, parent.color);

      cubit.updateParent(null);
      expect(cubit.state.parentId, isNull);
      expect(cubit.state.isSubclass, isFalse);
    });

    test('a blank name keeps the form invalid', () {
      final cubit = buildCubit()..updateName('   ');
      addTearDown(cubit.close);
      expect(cubit.state.isValid, isFalse);
    });
  });

  group('submit', () {
    blocTest<AssetClassFormCubit, AssetClassFormState>(
      'is a no-op while invalid',
      build: buildCubit,
      act: (cubit) => cubit.submit(),
      expect: () => const <AssetClassFormState>[],
      verify: (_) {
        verifyNever(() => createAssetClass(any()));
        verifyNever(() => updateAssetClass(any()));
      },
    );

    blocTest<AssetClassFormCubit, AssetClassFormState>(
      'creates a new class with a trimmed name and emits success',
      setUp: () {
        when(() => createAssetClass(any()))
            .thenAnswer((_) async => Right(AssetClassFactory.stocks()));
      },
      build: buildCubit,
      act: (cubit) async {
        cubit
          ..updateName('  Stocks  ')
          ..updateTargetPercent(25);
        await cubit.submit();
      },
      skip: 2,
      expect: () => [
        isA<AssetClassFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<AssetClassFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.success,
        ),
      ],
      verify: (_) {
        final entity = verify(() => createAssetClass(captureAny()))
            .captured
            .single as AssetClassEntity;
        expect(entity.name, 'Stocks');
        expect(entity.targetPercent, 25);
        expect(entity.userId, userId);
        expect(entity.id, isEmpty);
        verifyNever(() => updateAssetClass(any()));
      },
    );

    blocTest<AssetClassFormCubit, AssetClassFormState>(
      'routes edits through the update use case keeping the id',
      setUp: () {
        when(() => updateAssetClass(any()))
            .thenAnswer((_) async => Right(AssetClassFactory.stocks()));
      },
      build: () => buildCubit(existing: AssetClassFactory.stocks()),
      act: (cubit) async {
        cubit.updateName('Renamed');
        await cubit.submit();
      },
      skip: 1,
      expect: () => [
        isA<AssetClassFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<AssetClassFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.success,
        ),
      ],
      verify: (_) {
        final entity = verify(() => updateAssetClass(captureAny()))
            .captured
            .single as AssetClassEntity;
        expect(entity.id, AssetClassFactory.stocks().id);
        expect(entity.name, 'Renamed');
        verifyNever(() => createAssetClass(any()));
      },
    );

    blocTest<AssetClassFormCubit, AssetClassFormState>(
      'emits failure carrying the domain failure when the save is rejected',
      setUp: () {
        when(() => createAssetClass(any())).thenAnswer(
          (_) async => const Left(
            TargetSumExceededFailure(availablePercent: 10, isRoot: true),
          ),
        );
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.updateName('Stocks');
        await cubit.submit();
      },
      skip: 1,
      expect: () => [
        isA<AssetClassFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<AssetClassFormState>()
            .having((s) => s.status, 'status', FormStatus.failure)
            .having(
              (s) => s.failure,
              'failure',
              isA<TargetSumExceededFailure>(),
            ),
      ],
    );
  });
}
