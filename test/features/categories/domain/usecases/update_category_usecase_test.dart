import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late UpdateCategoryUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUpAll(registerCategoryFallbackValues);

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = UpdateCategoryUseCase(mockRepository);
  });

  group('UpdateCategoryUseCase', () {
    test('should update category via repository', () async {
      final category = CategoryFactory.expense(name: 'Updated Food');
      when(
        () => mockRepository.updateCategory(any()),
      ).thenAnswer(
        (_) async => Right<Failure, CategoryEntity>(category),
      );

      final result = await useCase(category);

      expect(result, Right<Failure, CategoryEntity>(category));
      verify(() => mockRepository.updateCategory(category)).called(1);
    });

    test('should return failure when repository fails', () async {
      final category = CategoryFactory.expense();
      when(
        () => mockRepository.updateCategory(any()),
      ).thenAnswer(
        (_) async => const Left<Failure, CategoryEntity>(
          ServerFailure('Failed to update category.'),
        ),
      );

      final result = await useCase(category);

      expect(result, isA<Left<Failure, CategoryEntity>>());
    });
  });
}
