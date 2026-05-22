import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/update_asset_class_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/asset_class_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetClassRepository repository;
  late UpdateAssetClassUseCase useCase;

  setUpAll(registerInvestmentFallbackValues);

  setUp(() {
    repository = MockAssetClassRepository();
    useCase = UpdateAssetClassUseCase(repository);
    // Default: empty class list so the sibling-sum guard short-circuits
    // with the full 100% budget. Tests that exercise the parent/sibling
    // rules stub a populated list.
    when(
      () => repository.getAssetClasses(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => const Right<Failure, List<AssetClassEntity>>(
        <AssetClassEntity>[],
      ),
    );
  });

  group('UpdateAssetClassUseCase — local validation', () {
    test('rejects empty names without hitting the repository', () async {
      final entity = AssetClassFactory.stocks(name: '   ');

      final result = await useCase(entity);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => repository.updateAssetClass(any()));
      verifyNever(
        () => repository.getAssetClasses(userId: any(named: 'userId')),
      );
    });

    test('rejects target percent outside [0, 100]', () async {
      final entity = AssetClassFactory.stocks(targetPercent: 120);

      final result = await useCase(entity);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => repository.updateAssetClass(any()));
    });
  });

  group('UpdateAssetClassUseCase — hierarchy rules', () {
    test('rejects when the declared parent does not exist', () async {
      final root = AssetClassFactory.stocks();
      // Candidate references a parent id absent from the stored list.
      final candidate = AssetClassFactory.subclass(
        id: 'sub-orphan',
        name: 'Orphan',
        parent: root,
      );
      when(
        () => repository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetClassEntity>>([candidate]),
      );

      final result = await useCase(candidate);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => repository.updateAssetClass(any()));
    });

    test('rejects nesting a subclass under another subclass', () async {
      final root = AssetClassFactory.stocks();
      final firstSub = AssetClassFactory.subclass(
        id: 'sub-1',
        name: 'Apple',
        parent: root,
      );
      // Candidate tries to hang off `firstSub`, which is itself a subclass.
      final candidate = AssetClassFactory.stocks(
        id: 'sub-2',
        name: 'Microsoft',
        targetPercent: 0,
      ).copyWith(parentId: firstSub.id);
      when(
        () => repository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetClassEntity>>(
          [root, firstSub, candidate],
        ),
      );

      final result = await useCase(candidate);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => repository.updateAssetClass(any()));
    });

    test('rejects a class declaring itself as its own parent', () async {
      // parentId points back at the candidate's own id.
      final candidate = AssetClassFactory.stocks(
        targetPercent: 0,
      ).copyWith(parentId: 'class-stocks');
      when(
        () => repository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetClassEntity>>([candidate]),
      );

      final result = await useCase(candidate);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => repository.updateAssetClass(any()));
    });

    test('rejects demoting a root that still owns subclasses', () async {
      final root = AssetClassFactory.realEstate();
      final ownedSub = AssetClassFactory.subclass(
        id: 'sub-owned',
        name: 'Funds',
        parent: root,
      );
      // The root is being turned into a subclass of `other`, but it still
      // owns `ownedSub` — that would create a 2-level chain.
      final other = AssetClassFactory.stocks();
      final demoted = root.copyWith(parentId: other.id, targetPercent: 0);
      when(
        () => repository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetClassEntity>>(
          [demoted, ownedSub, other],
        ),
      );

      final result = await useCase(demoted);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => repository.updateAssetClass(any()));
    });
  });

  group('UpdateAssetClassUseCase — sibling budget', () {
    test('rejects when sibling targets would exceed 100%', () async {
      final existing = AssetClassFactory.stocks(
        id: 'class-existing',
        targetPercent: 80,
      );
      // Candidate (a different root) wants 30 → 80 + 30 = 110 > 100.
      final candidate = AssetClassFactory.realEstate(targetPercent: 30);
      when(
        () => repository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetClassEntity>>(
          [existing, candidate],
        ),
      );

      final result = await useCase(candidate);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<TargetSumExceededFailure>()),
        (_) => fail('Expected TargetSumExceededFailure'),
      );
      verifyNever(() => repository.updateAssetClass(any()));
    });

    test('excludes the candidate itself from the sibling sum', () async {
      // The candidate is already in the list at 80; editing it to 90 must
      // not double-count its old 80 (90 alone is under budget).
      final candidate = AssetClassFactory.stocks(targetPercent: 90);
      final stored = AssetClassFactory.stocks(targetPercent: 80);
      when(
        () => repository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetClassEntity>>([stored]),
      );
      when(() => repository.updateAssetClass(any())).thenAnswer(
        (_) async => Right<Failure, AssetClassEntity>(candidate),
      );

      final result = await useCase(candidate);

      expect(result.isRight(), isTrue);
      verify(() => repository.updateAssetClass(candidate)).called(1);
    });
  });

  group('UpdateAssetClassUseCase — delegation', () {
    test('delegates to the repository on valid input', () async {
      final entity = AssetClassFactory.stocks();
      when(() => repository.updateAssetClass(any())).thenAnswer(
        (_) async => Right<Failure, AssetClassEntity>(entity),
      );

      final result = await useCase(entity);

      expect(result.isRight(), isTrue);
      verify(() => repository.updateAssetClass(entity)).called(1);
    });

    test('forwards a failure raised while loading sibling classes', () async {
      when(
        () => repository.getAssetClasses(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<AssetClassEntity>>(ServerFailure()),
      );

      final result = await useCase(AssetClassFactory.stocks());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
      verifyNever(() => repository.updateAssetClass(any()));
    });

    test('forwards a failure from updateAssetClass', () async {
      final entity = AssetClassFactory.stocks();
      when(() => repository.updateAssetClass(any())).thenAnswer(
        (_) async => const Left<Failure, AssetClassEntity>(ServerFailure()),
      );

      final result = await useCase(entity);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
