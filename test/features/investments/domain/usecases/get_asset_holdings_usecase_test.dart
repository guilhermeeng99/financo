import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_holdings_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/asset_holding_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetHoldingRepository repository;
  late GetAssetHoldingsUseCase useCase;

  const userId = 'user-1';

  setUp(() {
    repository = MockAssetHoldingRepository();
    useCase = GetAssetHoldingsUseCase(repository);
  });

  group('GetAssetHoldingsUseCase', () {
    test('forwards the repository list on success', () async {
      final holdings = [AssetHoldingFactory.holding()];
      when(
        () => repository.getAssetHoldings(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetHoldingEntity>>(holdings),
      );

      final result = await useCase(userId: userId);

      expect(result, Right<Failure, List<AssetHoldingEntity>>(holdings));
    });

    test('passes forceRefresh through to the repository', () async {
      when(
        () => repository.getAssetHoldings(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<AssetHoldingEntity>>(
          <AssetHoldingEntity>[],
        ),
      );

      await useCase(userId: userId, forceRefresh: true);

      verify(
        () => repository.getAssetHoldings(userId: userId, forceRefresh: true),
      ).called(1);
    });

    test('forwards a failure from the repository', () async {
      when(
        () => repository.getAssetHoldings(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<AssetHoldingEntity>>(ServerFailure()),
      );

      final result = await useCase(userId: userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
