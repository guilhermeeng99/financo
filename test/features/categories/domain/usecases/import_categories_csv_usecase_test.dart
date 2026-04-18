import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late ImportCategoriesCsvUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUpAll(registerCategoryFallbackValues);

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = ImportCategoriesCsvUseCase(mockRepository);
  });

  group('ImportCategoriesCsvUseCase', () {
    const userId = 'user-1';

    test('should import root categories and subcategories from csv', () async {
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Right([]));

      var createdCount = 0;
      when(() => mockRepository.createCategory(any())).thenAnswer((
        invocation,
      ) async {
        final category = invocation.positionalArguments.first as CategoryEntity;
        createdCount++;
        return Right<Failure, CategoryEntity>(
          category.copyWith(id: 'created-$createdCount'),
        );
      });

      const csv = '''
Category,Subcategory,Type
Food,Restaurants,Expense
Food,Groceries,Expense
Salary,,Income
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(
        result,
        const Right<Failure, CategoryImportResult>(
          CategoryImportResult(importedCount: 4, duplicateCount: 0),
        ),
      );
      verify(() => mockRepository.createCategory(any())).called(4);
    });

    test('should return ValidationFailure for invalid csv content', () async {
      const csv = 'Category,Subcategory,Type';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(result, isA<Left<Failure, CategoryImportResult>>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.createCategory(any()));
    });

    test('should return repository failure when create fails', () async {
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockRepository.createCategory(any())).thenAnswer(
        (_) async => const Left(ServerFailure('create failed')),
      );

      const csv = '''
Category,Subcategory,Type
Food,,Expense
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(result, isA<Left<Failure, CategoryImportResult>>());
      result.fold(
        (failure) => expect(failure.message, 'create failed'),
        (_) => fail('Expected failure'),
      );
    });
  });
}
