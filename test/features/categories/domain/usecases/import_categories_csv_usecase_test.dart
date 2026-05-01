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

    test('should import categories from a Portuguese csv', () async {
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Right([]));

      final created = <CategoryEntity>[];
      when(() => mockRepository.createCategory(any())).thenAnswer((
        invocation,
      ) async {
        final category = invocation.positionalArguments.first as CategoryEntity;
        created.add(category);
        return Right<Failure, CategoryEntity>(
          category.copyWith(id: 'created-${created.length}'),
        );
      });

      const csv = '''
Categoria,Subcategoria,Tipo
Alimentação,Mercado,DESPESA
Alimentação,Restaurante,DESPESA
Salário,,RECEITA
Investimentos,CDB,RECEITA
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(
        result,
        const Right<Failure, CategoryImportResult>(
          CategoryImportResult(importedCount: 6, duplicateCount: 0),
        ),
      );

      final byName = {for (final c in created) c.name: c};
      expect(byName['Alimentação']?.type, CategoryType.expense);
      expect(byName['Mercado']?.type, CategoryType.expense);
      expect(byName['Salário']?.type, CategoryType.income);
      expect(byName['Investimentos']?.type, CategoryType.income);
      expect(byName['CDB']?.type, CategoryType.income);
    });

    test('rejects unknown type values with row + value detail', () async {
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Right([]));

      const csv = '''
Categoria,Subcategoria,Tipo
Alimentação,,DESPESA
Salário,,RENDA
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(result, isA<Left<Failure, CategoryImportResult>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Row 3'));
          expect(failure.message, contains('RENDA'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.createCategory(any()));
    });

    test('rejects rows where the type column is empty', () async {
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Right([]));

      const csv = '''
Categoria,Subcategoria,Tipo
Alimentação,Mercado,
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(result, isA<Left<Failure, CategoryImportResult>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Row 2'));
          expect(failure.message, contains('empty'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockRepository.createCategory(any()));
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

  group('ImportCategoriesCsvUseCase.importItems', () {
    const userId = 'user-1';

    test("uses each item's icon and color when creating", () async {
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Right([]));

      final created = <CategoryEntity>[];
      when(() => mockRepository.createCategory(any())).thenAnswer((
        invocation,
      ) async {
        final category = invocation.positionalArguments.first as CategoryEntity;
        created.add(category);
        return Right<Failure, CategoryEntity>(
          category.copyWith(id: 'created-${created.length}'),
        );
      });

      final items = [
        const CategoryImportPreviewItem(
          name: 'Food',
          type: CategoryType.expense,
          icon: 9000,
          color: 0xFFAA0000,
        ),
        const CategoryImportPreviewItem(
          name: 'Restaurants',
          type: CategoryType.expense,
          parentName: 'Food',
          icon: 9001,
          color: 0xFFAA0001,
        ),
      ];

      final result = await useCase.importItems(
        items: items,
        userId: userId,
        duplicateCount: 2,
      );

      expect(
        result,
        const Right<Failure, CategoryImportResult>(
          CategoryImportResult(importedCount: 2, duplicateCount: 2),
        ),
      );
      expect(created[0].icon, 9000);
      expect(created[0].color, 0xFFAA0000);
      expect(created[1].icon, 9001);
      expect(created[1].color, 0xFFAA0001);
      expect(created[1].parentId, 'created-1');
    });

    test('reports progress for each processed item via onProgress', () async {
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

      final items = [
        const CategoryImportPreviewItem(
          name: 'Food',
          type: CategoryType.expense,
          icon: 1,
          color: 1,
        ),
        const CategoryImportPreviewItem(
          name: 'Restaurants',
          type: CategoryType.expense,
          parentName: 'Food',
          icon: 2,
          color: 2,
        ),
        const CategoryImportPreviewItem(
          name: 'Salary',
          type: CategoryType.income,
          icon: 3,
          color: 3,
        ),
      ];

      final progressEvents = <List<int>>[];
      await useCase.importItems(
        items: items,
        userId: userId,
        onProgress: (processed, total) =>
            progressEvents.add([processed, total]),
      );

      expect(progressEvents, [
        [1, 3],
        [2, 3],
        [3, 3],
      ]);
    });

    test('still ticks progress for skipped (orphan) children', () async {
      when(
        () => mockRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Right([]));
      when(() => mockRepository.createCategory(any())).thenAnswer(
        (_) async => const Right(
          CategoryEntity(
            id: 'created-1',
            name: 'Food',
            icon: 1,
            color: 1,
            type: CategoryType.expense,
          ),
        ),
      );

      final items = [
        const CategoryImportPreviewItem(
          name: 'Food',
          type: CategoryType.expense,
          icon: 1,
          color: 1,
        ),
        const CategoryImportPreviewItem(
          name: 'Tacos',
          type: CategoryType.expense,
          parentName: 'Missing',
          icon: 2,
          color: 2,
        ),
      ];

      final progressEvents = <List<int>>[];
      await useCase.importItems(
        items: items,
        userId: userId,
        onProgress: (processed, total) =>
            progressEvents.add([processed, total]),
      );

      expect(progressEvents, [
        [1, 2],
        [2, 2],
      ]);
    });

    test('skips children whose parent was removed from the items list',
        () async {
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

      final items = [
        const CategoryImportPreviewItem(
          name: 'Restaurants',
          type: CategoryType.expense,
          parentName: 'Food',
          icon: 100,
          color: 0xFF000000,
        ),
      ];

      final result = await useCase.importItems(
        items: items,
        userId: userId,
      );

      expect(
        result,
        const Right<Failure, CategoryImportResult>(
          CategoryImportResult(importedCount: 0, duplicateCount: 0),
        ),
      );
      verifyNever(() => mockRepository.createCategory(any()));
    });
  });
}
