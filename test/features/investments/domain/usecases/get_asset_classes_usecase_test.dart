import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_classes_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/asset_class_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetClassRepository repository;
  late GetAssetClassesUseCase useCase;

  const userId = 'user-1';

  setUp(() {
    repository = MockAssetClassRepository();
    useCase = GetAssetClassesUseCase(repository);
  });

  group('GetAssetClassesUseCase', () {
    test('forwards the repository list on success', () async {
      final classes = AssetClassFactory.arcaList();
      when(
        () => repository.getAssetClasses(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<AssetClassEntity>>(classes),
      );

      final result = await useCase(userId: userId);

      expect(result, Right<Failure, List<AssetClassEntity>>(classes));
    });

    test('passes forceRefresh through to the repository', () async {
      when(
        () => repository.getAssetClasses(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<AssetClassEntity>>(
          <AssetClassEntity>[],
        ),
      );

      await useCase(userId: userId, forceRefresh: true);

      verify(
        () => repository.getAssetClasses(userId: userId, forceRefresh: true),
      ).called(1);
    });

    test('forwards a failure from the repository', () async {
      when(
        () => repository.getAssetClasses(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, List<AssetClassEntity>>(ServerFailure()),
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
