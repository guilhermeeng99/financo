import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetCategoriesUseCase mockGetCategories;
  late MockImportCategoriesCsvUseCase mockImportCategoriesCsv;

  setUp(() {
    mockGetCategories = MockGetCategoriesUseCase();
    mockImportCategoriesCsv = MockImportCategoriesCsvUseCase();
  });

  const userId = 'user-1';

  CategoriesCubit buildCubit() => CategoriesCubit(
    getCategories: mockGetCategories,
    importCategoriesCsv: mockImportCategoriesCsv,
    userId: userId,
  );

  group('CategoriesCubit', () {
    test('initial state is CategoriesInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<CategoriesInitial>());
      addTearDown(cubit.close);
    });

    blocTest<CategoriesCubit, CategoriesState>(
      'emits [Loading, Loaded] when loadCategories succeeds',
      setUp: () {
        when(
          () => mockGetCategories(userId: userId),
        ).thenAnswer((_) async => Right(CategoryFactory.list()));
      },
      build: buildCubit,
      act: (cubit) async => cubit.loadCategories(),
      expect: () => [
        isA<CategoriesLoading>(),
        isA<CategoriesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetCategories(userId: userId)).called(1);
      },
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'emits [Loading, Error] when loadCategories fails',
      setUp: () {
        when(
          () => mockGetCategories(userId: userId),
        ).thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: buildCubit,
      act: (cubit) async => cubit.loadCategories(),
      expect: () => [
        isA<CategoriesLoading>(),
        isA<CategoriesError>(),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'silently re-reads cache when already loaded and forceRefresh is false',
      setUp: () {
        when(
          () => mockGetCategories(userId: userId),
        ).thenAnswer((_) async => Right(CategoryFactory.list()));
      },
      build: buildCubit,
      seed: () => CategoriesLoaded(CategoryFactory.list()),
      act: (cubit) async => cubit.loadCategories(),
      expect: () => <CategoriesState>[],
      verify: (_) {
        verify(() => mockGetCategories(userId: userId)).called(1);
      },
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'reloads when already loaded and forceRefresh is true',
      setUp: () {
        when(
          () => mockGetCategories(userId: userId, forceRefresh: true),
        ).thenAnswer((_) async => Right(CategoryFactory.list()));
      },
      build: buildCubit,
      seed: () => CategoriesLoaded(CategoryFactory.list()),
      act: (cubit) async => cubit.loadCategories(forceRefresh: true),
      expect: () => [
        isA<CategoriesLoading>(),
        isA<CategoriesLoaded>(),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'emits Loaded with empty list when no categories exist',
      setUp: () {
        when(
          () => mockGetCategories(userId: userId),
        ).thenAnswer((_) async => const Right([]));
      },
      build: buildCubit,
      act: (cubit) async => cubit.loadCategories(),
      expect: () => [
        isA<CategoriesLoading>(),
        isA<CategoriesLoaded>().having(
          (s) => s.categories,
          'categories',
          isEmpty,
        ),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'emits [Loading, CategoriesImported] when importCsv succeeds',
      setUp: () {
        when(
          () => mockImportCategoriesCsv(
            csvContent: any(named: 'csvContent'),
            userId: userId,
          ),
        ).thenAnswer(
          (_) async => const Right(
            CategoryImportResult(importedCount: 3, duplicateCount: 0),
          ),
        );
        when(
          () => mockGetCategories(userId: userId, forceRefresh: true),
        ).thenAnswer((_) async => Right(CategoryFactory.list()));
      },
      build: buildCubit,
      act: (cubit) async => cubit.importCsv('Category,Subcategory,Type'),
      expect: () => [
        isA<CategoriesLoading>(),
        isA<CategoriesImported>()
            .having((s) => s.importedCount, 'importedCount', 3)
            .having((s) => s.categories.length, 'categories length', 4),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'emits [Loading, Error] when importCsv fails',
      setUp: () {
        when(
          () => mockImportCategoriesCsv(
            csvContent: any(named: 'csvContent'),
            userId: userId,
          ),
        ).thenAnswer(
          (_) async => const Left(ValidationFailure('Invalid CSV')),
        );
      },
      build: buildCubit,
      act: (cubit) async => cubit.importCsv('invalid'),
      expect: () => [
        isA<CategoriesLoading>(),
        isA<CategoriesError>().having(
          (s) => s.failure.message,
          'message',
          'Invalid CSV',
        ),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'emits Importing progress + Imported when confirmImport succeeds',
      setUp: () {
        when(
          () => mockImportCategoriesCsv.importItems(
            items: any(named: 'items'),
            userId: userId,
            duplicateCount: any(named: 'duplicateCount'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((invocation) async {
          final onProgress =
              invocation.namedArguments[const Symbol('onProgress')]
                  as void Function(int, int)?;
          onProgress?.call(1, 1);
          return const Right(
            CategoryImportResult(importedCount: 2, duplicateCount: 1),
          );
        });
        when(
          () => mockGetCategories(userId: userId, forceRefresh: true),
        ).thenAnswer((_) async => Right(CategoryFactory.list()));
      },
      build: buildCubit,
      act: (cubit) async => cubit.confirmImport(
        items: const [
          CategoryImportPreviewItem(
            name: 'Food',
            type: CategoryType.expense,
            icon: 1,
            color: 1,
          ),
        ],
        duplicateCount: 1,
      ),
      expect: () => [
        isA<CategoriesImporting>()
            .having((s) => s.processed, 'processed', 0)
            .having((s) => s.total, 'total', 1),
        isA<CategoriesImporting>()
            .having((s) => s.processed, 'processed', 1)
            .having((s) => s.total, 'total', 1),
        isA<CategoriesImported>()
            .having((s) => s.importedCount, 'importedCount', 2)
            .having((s) => s.duplicateCount, 'duplicateCount', 1),
      ],
    );
  });
}
