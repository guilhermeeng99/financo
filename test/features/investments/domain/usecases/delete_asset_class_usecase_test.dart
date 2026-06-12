import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/usecases/delete_asset_class_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/asset_class_factory.dart';
import '../../../../harness/factories/asset_holding_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetClassRepository classRepository;
  late MockAssetHoldingRepository holdingRepository;
  late DeleteAssetClassUseCase useCase;

  const classId = 'class-stocks';
  const userId = 'user-1';

  setUpAll(registerInvestmentFallbackValues);

  setUp(() {
    classRepository = MockAssetClassRepository();
    holdingRepository = MockAssetHoldingRepository();
    useCase = DeleteAssetClassUseCase(
      assetClassRepository: classRepository,
      assetHoldingRepository: holdingRepository,
    );
    // Default: no other classes (so the subclass guard is a no-op).
    // Specific tests override this with a populated list when they
    // need to assert the subclass block.
    when(
      () => classRepository.getAssetClasses(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => const Right<Failure, List<AssetClassEntity>>(
        <AssetClassEntity>[],
      ),
    );
  });

  group('DeleteAssetClassUseCase', () {
    test('blocks deletion when holdings still reference the class', () async {
      when(
        () => holdingRepository.getAssetHoldings(userId: userId),
      ).thenAnswer(
        (_) async =>
            Right<Failure, List<AssetHoldingEntity>>(
              [AssetHoldingFactory.holding()],
            ),
      );

      final result = await useCase(id: classId, userId: userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AssetClassHasHoldingsFailure>());
          expect((failure as AssetClassHasHoldingsFailure).count, 1);
        },
        (_) => fail('Expected AssetClassHasHoldingsFailure'),
      );
      verifyNever(() => classRepository.deleteAssetClass(any()));
    });

    test('proceeds when no holdings reference the class', () async {
      when(
        () => holdingRepository.getAssetHoldings(userId: userId),
      ).thenAnswer(
        (_) async => const Right<Failure, List<AssetHoldingEntity>>(
          <AssetHoldingEntity>[],
        ),
      );
      when(
        () => classRepository.deleteAssetClass(classId),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await useCase(id: classId, userId: userId);

      expect(result.isRight(), isTrue);
      verify(() => classRepository.deleteAssetClass(classId)).called(1);
    });

    test('blocks deletion when subclasses still reference the class',
        () async {
      final root = AssetClassFactory.stocks();
      final sub = AssetClassFactory.subclass(
        id: 'sub-apple',
        name: 'Apple',
        parent: root,
      );
      when(
        () => classRepository.getAssetClasses(userId: userId),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetClassEntity>>([root, sub]),
      );

      final result = await useCase(id: root.id, userId: userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AssetClassHasSubclassesFailure>());
          expect((failure as AssetClassHasSubclassesFailure).count, 1);
        },
        (_) => fail('Expected AssetClassHasSubclassesFailure'),
      );
      verifyNever(() => classRepository.deleteAssetClass(any()));
      verifyNever(
        () => holdingRepository.getAssetHoldings(userId: any(named: 'userId')),
      );
    });

    test('callWithCascade purges holdings then deletes the class', () async {
      when(
        () => holdingRepository.deleteHoldingsForClass(classId),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      when(
        () => classRepository.deleteAssetClass(classId),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await useCase.callWithCascade(id: classId);

      expect(result.isRight(), isTrue);
      verifyInOrder([
        () => holdingRepository.deleteHoldingsForClass(classId),
        () => classRepository.deleteAssetClass(classId),
      ]);
    });
  });
}
