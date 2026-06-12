import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/create_asset_class_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/asset_class_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetClassRepository repository;
  late CreateAssetClassUseCase useCase;

  setUpAll(registerInvestmentFallbackValues);

  setUp(() {
    repository = MockAssetClassRepository();
    useCase = CreateAssetClassUseCase(repository);
    // Default: empty class list so the sibling-sum guard short-
    // circuits with budget = 100%. Tests that exercise the limit
    // stub a populated list.
    when(
      () => repository.getAssetClasses(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => const Right<Failure, List<AssetClassEntity>>(
        <AssetClassEntity>[],
      ),
    );
  });

  group('CreateAssetClassUseCase', () {
    test('rejects empty names without hitting the repository', () async {
      final entity = AssetClassFactory.stocks(name: '   ');

      final result = await useCase(entity);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<EmptyNameFailure>()),
        (_) => fail('Expected EmptyNameFailure'),
      );
      verifyNever(() => repository.createAssetClass(any()));
    });

    test('rejects target percent outside [0, 100]', () async {
      final entity = AssetClassFactory.stocks(targetPercent: 120);

      final result = await useCase(entity);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<TargetPercentOutOfRangeFailure>()),
        (_) => fail('Expected TargetPercentOutOfRangeFailure'),
      );
      verifyNever(() => repository.createAssetClass(any()));
    });

    test('delegates to repository on valid input', () async {
      final entity = AssetClassFactory.stocks();
      when(() => repository.createAssetClass(any())).thenAnswer(
        (_) async => Right<Failure, AssetClassEntity>(entity),
      );

      final result = await useCase(entity);

      expect(result.isRight(), isTrue);
      verify(() => repository.createAssetClass(entity)).called(1);
    });
  });
}
