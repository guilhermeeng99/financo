import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late DeleteCategoryUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = DeleteCategoryUseCase(mockRepository);
  });

  group('DeleteCategoryUseCase', () {
    const categoryId = 'cat-1';

    test('should delete category via repository', () async {
      when(
        () => mockRepository.deleteCategory(any()),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await useCase(categoryId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.deleteCategory(categoryId)).called(1);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockRepository.deleteCategory(any()),
      ).thenAnswer(
        (_) async => const Left<Failure, void>(
          ServerFailure('Failed to delete category.'),
        ),
      );

      final result = await useCase(categoryId);

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
