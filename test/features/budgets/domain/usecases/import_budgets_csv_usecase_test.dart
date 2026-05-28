import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/budgets/domain/usecases/import_budgets_csv_usecase.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late ImportBudgetsCsvUseCase useCase;
  late MockBudgetRepository mockBudgetRepository;
  late MockCategoryRepository mockCategoryRepository;

  setUpAll(() {
    registerBudgetFallbackValues();
    registerCategoryFallbackValues();
  });

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    mockCategoryRepository = MockCategoryRepository();
    useCase = ImportBudgetsCsvUseCase(
      mockBudgetRepository,
      mockCategoryRepository,
    );
  });

  const userId = 'user-1';

  // Two expense roots (budgetable), one income root and one subcategory
  // (both NON-budgetable) so the expense-root filter is exercised.
  final categories = [
    CategoryFactory.expense(id: 'cat-food'),
    CategoryFactory.expense(id: 'cat-transport', name: 'Transport'),
    CategoryFactory.income(id: 'cat-salary'),
    CategoryFactory.subcategory(id: 'cat-rest', parentId: 'cat-food'),
  ];

  void stubCategories() {
    when(
      () => mockCategoryRepository.getCategories(userId: userId),
    ).thenAnswer((_) async => Right<Failure, List<CategoryEntity>>(categories));
  }

  void stubExistingBudgets(List<BudgetEntity> existing) {
    when(
      () => mockBudgetRepository.getBudgets(userId: userId),
    ).thenAnswer((_) async => Right<Failure, List<BudgetEntity>>(existing));
  }

  List<BudgetEntity> stubCreateBudgetCapturing() {
    final created = <BudgetEntity>[];
    when(() => mockBudgetRepository.createBudget(any())).thenAnswer((
      invocation,
    ) async {
      final budget = invocation.positionalArguments.first as BudgetEntity;
      created.add(budget);
      return Right<Failure, BudgetEntity>(budget);
    });
    return created;
  }

  group('ImportBudgetsCsvUseCase', () {
    test('imports budgets for expense-root categories', () async {
      stubCategories();
      stubExistingBudgets([]);
      final created = stubCreateBudgetCapturing();

      const csv = '''
Category,Amount
Food,800
Transport,300
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(
        result,
        const Right<Failure, BudgetImportResult>(
          BudgetImportResult(importedCount: 2, skippedCount: 0),
        ),
      );
      final byCat = {for (final b in created) b.categoryId: b};
      expect(byCat['cat-food']?.amount, 800);
      expect(byCat['cat-transport']?.amount, 300);
    });

    test('skips unknown categories, counting them', () async {
      stubCategories();
      stubExistingBudgets([]);
      stubCreateBudgetCapturing();

      const csv = '''
Category,Amount
Food,800
Nonexistent,500
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(
        result,
        const Right<Failure, BudgetImportResult>(
          BudgetImportResult(importedCount: 1, skippedCount: 1),
        ),
      );
      verify(() => mockBudgetRepository.createBudget(any())).called(1);
    });

    test('skips non-expense-root categories (income root + subcategory)',
        () async {
      stubCategories();
      stubExistingBudgets([]);
      stubCreateBudgetCapturing();

      const csv = '''
Category,Amount
Salary,800
Restaurants,300
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(
        result,
        const Right<Failure, BudgetImportResult>(
          BudgetImportResult(importedCount: 0, skippedCount: 2),
        ),
      );
      verifyNever(() => mockBudgetRepository.createBudget(any()));
    });

    test('skips categories that already have a budget', () async {
      stubCategories();
      stubExistingBudgets([BudgetFactory.make(categoryId: 'cat-food')]);
      stubCreateBudgetCapturing();

      const csv = '''
Category,Amount
Food,800
Transport,300
''';

      final result = await useCase(csvContent: csv, userId: userId);

      expect(
        result,
        const Right<Failure, BudgetImportResult>(
          BudgetImportResult(importedCount: 1, skippedCount: 1),
        ),
      );
      verify(() => mockBudgetRepository.createBudget(any())).called(1);
    });

    test('dedupes the same category within the file before importing',
        () async {
      stubCategories();
      stubExistingBudgets([]);
      final created = stubCreateBudgetCapturing();

      const csv = '''
Category,Amount
Food,800
Food,900
''';

      final result = await useCase(csvContent: csv, userId: userId);

      // The second "Food" row is dropped at parse time (not counted as a
      // skip), so the first value wins and only one budget is created.
      expect(
        result,
        const Right<Failure, BudgetImportResult>(
          BudgetImportResult(importedCount: 1, skippedCount: 0),
        ),
      );
      expect(created.single.amount, 800);
    });

    test('rejects a zero / negative amount with row detail', () async {
      stubCategories();
      stubExistingBudgets([]);

      const csv = '''
Category,Amount
Food,0
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Row 2'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
      verifyNever(() => mockBudgetRepository.createBudget(any()));
    });

    test('rejects a CSV missing a required column', () async {
      const csv = '''
Category
Food
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('amount'));
        },
        (_) => fail('Expected ValidationFailure'),
      );
    });

    test('propagates a category-fetch failure', () async {
      when(
        () => mockCategoryRepository.getCategories(userId: userId),
      ).thenAnswer((_) async => const Left(ServerFailure('cats boom')));

      const csv = '''
Category,Amount
Food,800
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) => expect(failure.message, 'cats boom'),
        (_) => fail('Expected failure'),
      );
    });

    test('propagates an existing-budgets fetch failure', () async {
      stubCategories();
      when(
        () => mockBudgetRepository.getBudgets(userId: userId),
      ).thenAnswer((_) async => const Left(ServerFailure('budgets boom')));

      const csv = '''
Category,Amount
Food,800
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) => expect(failure.message, 'budgets boom'),
        (_) => fail('Expected failure'),
      );
    });

    test('returns the repository failure when a create fails', () async {
      stubCategories();
      stubExistingBudgets([]);
      when(() => mockBudgetRepository.createBudget(any())).thenAnswer(
        (_) async => const Left(ServerFailure('create failed')),
      );

      const csv = '''
Category,Amount
Food,800
''';

      final result = await useCase(csvContent: csv, userId: userId);

      result.fold(
        (failure) => expect(failure.message, 'create failed'),
        (_) => fail('Expected failure'),
      );
    });
  });
}
