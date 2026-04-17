import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetCategoriesUseCase mockGetCategories;

  setUp(() {
    mockGetCategories = MockGetCategoriesUseCase();
  });

  const userId = 'user-1';

  CategoriesCubit buildCubit() => CategoriesCubit(
        getCategories: mockGetCategories,
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
      'does not reload when already loaded and forceRefresh is false',
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
        verifyNever(() => mockGetCategories(userId: any(named: 'userId')));
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
  });
}
