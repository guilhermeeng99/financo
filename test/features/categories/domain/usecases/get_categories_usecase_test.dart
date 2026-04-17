import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late GetCategoriesUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = GetCategoriesUseCase(mockRepository);
  });

  const userId = 'user-1';

  group('GetCategoriesUseCase', () {
    test('should return categories from repository', () async {
      final categories = CategoryFactory.list();
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer(
        (_) async => Right<Failure, List<CategoryEntity>>(categories),
      );

      final result = await useCase(userId: userId);

      expect(
        result,
        Right<Failure, List<CategoryEntity>>(categories),
      );
      verify(() => mockRepository.getCategories(userId: userId)).called(1);
    });

    test('should pass forceRefresh parameter', () async {
      when(
        () => mockRepository.getCategories(
          userId: userId,
          forceRefresh: true,
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<CategoryEntity>>([]),
      );

      await useCase(userId: userId, forceRefresh: true);

      verify(
        () => mockRepository.getCategories(
          userId: userId,
          forceRefresh: true,
        ),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer(
        (_) async => const Left<Failure, List<CategoryEntity>>(ServerFailure()),
      );

      final result = await useCase(userId: userId);

      expect(result, isA<Left<Failure, List<CategoryEntity>>>());
    });
  });
}
