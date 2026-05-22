import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/usecases/delete_asset_holding_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockAssetHoldingRepository repository;
  late DeleteAssetHoldingUseCase useCase;

  const holdingId = 'holding-1';

  setUp(() {
    repository = MockAssetHoldingRepository();
    useCase = DeleteAssetHoldingUseCase(repository);
  });

  group('DeleteAssetHoldingUseCase', () {
    test('delegates to the repository with the given id', () async {
      when(() => repository.deleteAssetHolding(any())).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );

      final result = await useCase(holdingId);

      expect(result.isRight(), isTrue);
      verify(() => repository.deleteAssetHolding(holdingId)).called(1);
    });

    test('forwards a failure from the repository', () async {
      when(() => repository.deleteAssetHolding(any())).thenAnswer(
        (_) async => const Left<Failure, void>(ServerFailure()),
      );

      final result = await useCase(holdingId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
