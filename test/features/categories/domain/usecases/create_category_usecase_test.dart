import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late CreateCategoryUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUpAll(registerCategoryFallbackValues);

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = CreateCategoryUseCase(mockRepository);
  });

  group('CreateCategoryUseCase', () {
    test('should create category via repository', () async {
      final category = CategoryFactory.expense();
      when(
        () => mockRepository.createCategory(any()),
      ).thenAnswer(
        (_) async => Right<Failure, CategoryEntity>(category),
      );

      final result = await useCase(category);

      expect(result, Right<Failure, CategoryEntity>(category));
      verify(() => mockRepository.createCategory(category)).called(1);
    });

    test('should return failure when repository fails', () async {
      final category = CategoryFactory.expense();
      when(
        () => mockRepository.createCategory(any()),
      ).thenAnswer(
        (_) async => const Left<Failure, CategoryEntity>(
          ServerFailure('Failed to create category.'),
        ),
      );

      final result = await useCase(category);

      expect(result, isA<Left<Failure, CategoryEntity>>());
    });
  });
}
