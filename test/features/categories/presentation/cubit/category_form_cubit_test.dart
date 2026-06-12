import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateCategoryUseCase mockCreate;
  late MockUpdateCategoryUseCase mockUpdate;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockGetBudgetsUseCase mockGetBudgets;

  const userId = 'user-1';

  setUpAll(registerCategoryFallbackValues);

  setUp(() {
    mockCreate = MockCreateCategoryUseCase();
    mockUpdate = MockUpdateCategoryUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockGetBudgets = MockGetBudgetsUseCase();
  });

  CategoryFormCubit buildCubit({CategoryEntity? existing}) => CategoryFormCubit(
    createCategory: mockCreate,
    updateCategory: mockUpdate,
    getCategories: mockGetCategories,
    getBudgets: mockGetBudgets,
    userId: userId,
    existingCategory: existing,
  );

  group('CategoryFormCubit', () {
    group('initial state', () {
      test('creates with default values for new category', () {
        final cubit = buildCubit();
        final state = cubit.state;

        expect(state.userId, userId);
        expect(state.name, '');
        expect(state.type, CategoryType.expense);
        expect(state.status, FormStatus.initial);
        expect(state.isEditing, isFalse);
        expect(state.isValid, isFalse);

        addTearDown(cubit.close);
      });

      test('populates from existing category in edit mode', () {
        final existing = CategoryFactory.subcategory(
          id: 'existing-1',
          parentId: 'parent-1',
        );
        final cubit = buildCubit(existing: existing);
        final state = cubit.state;

        expect(state.name, 'Restaurants');
        expect(state.type, CategoryType.expense);
        expect(state.existingId, 'existing-1');
        expect(state.parentId, 'parent-1');
        expect(state.isEditing, isTrue);
        expect(state.isValid, isTrue);

        addTearDown(cubit.close);
      });
    });

    group('field updates', () {
      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateName emits state with new name',
        build: buildCubit,
        act: (cubit) => cubit.updateName('Groceries'),
        expect: () => [
          isA<CategoryFormState>()
              .having((s) => s.name, 'name', 'Groceries')
              .having((s) => s.isValid, 'isValid', isTrue),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateType emits state with new type',
        build: buildCubit,
        act: (cubit) => cubit.updateType(CategoryType.income),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.type,
            'type',
            CategoryType.income,
          ),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateIcon emits state with new icon',
        build: buildCubit,
        act: (cubit) => cubit.updateIcon(58715),
        expect: () => [
          isA<CategoryFormState>().having((s) => s.icon, 'icon', 58715),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateColor emits state with new color',
        build: buildCubit,
        act: (cubit) => cubit.updateColor(4294940672),
        expect: () => [
          isA<CategoryFormState>().having((s) => s.color, 'color', 4294940672),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateParentId emits state with selected parent',
        build: buildCubit,
        act: (cubit) => cubit.updateParentId('parent-1'),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.parentId,
            'parentId',
            'parent-1',
          ),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateType resets parentId when type changes',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          parentId: 'parent-1',
        ),
        act: (cubit) => cubit.updateType(CategoryType.income),
        expect: () => [
          isA<CategoryFormState>()
              .having((s) => s.type, 'type', CategoryType.income)
              .having((s) => s.parentId, 'parentId', isNull),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateBucket sets needs/wants when type is expense',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId),
        act: (cubit) => cubit.updateBucket(CategoryBucket.needs),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.bucket,
            'bucket',
            CategoryBucket.needs,
          ),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateBucket(null) clears the bucket',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          bucket: CategoryBucket.wants,
        ),
        act: (cubit) => cubit.updateBucket(null),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.bucket,
            'bucket',
            isNull,
          ),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateBucket is a no-op on income categories',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          type: CategoryType.income,
        ),
        act: (cubit) => cubit.updateBucket(CategoryBucket.needs),
        expect: () => <CategoryFormState>[],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateBucket is a no-op on subcategories (parent inherits)',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          parentId: 'parent-1',
        ),
        act: (cubit) => cubit.updateBucket(CategoryBucket.needs),
        expect: () => <CategoryFormState>[],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateParentId(non-null) clears a previously chosen bucket',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          bucket: CategoryBucket.wants,
        ),
        act: (cubit) => cubit.updateParentId('parent-1'),
        expect: () => [
          isA<CategoryFormState>()
              .having((s) => s.parentId, 'parentId', 'parent-1')
              .having((s) => s.bucket, 'bucket', isNull),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateType to income clears a previously set bucket',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          bucket: CategoryBucket.wants,
        ),
        act: (cubit) => cubit.updateType(CategoryType.income),
        expect: () => [
          isA<CategoryFormState>()
              .having((s) => s.type, 'type', CategoryType.income)
              .having((s) => s.bucket, 'bucket', isNull),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateCountsIn50_30_20 toggles flag on income categories',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          type: CategoryType.income,
        ),
        act: (cubit) => cubit.updateCountsIn50_30_20(value: false),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.countsIn50_30_20,
            'countsIn50_30_20',
            isFalse,
          ),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateCountsIn50_30_20 is a no-op on expense categories',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId),
        act: (cubit) => cubit.updateCountsIn50_30_20(value: false),
        expect: () => <CategoryFormState>[],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateCountsIn50_30_20 is a no-op on sub-income (inherits parent)',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          type: CategoryType.income,
          parentId: 'parent-1',
        ),
        act: (cubit) => cubit.updateCountsIn50_30_20(value: false),
        expect: () => <CategoryFormState>[],
      );

      test('isDemoting true when root edits parent to non-null', () {
        final existing = CategoryFactory.expense(id: 'root-cat');
        final cubit = buildCubit(existing: existing)
          ..updateParentId('some-parent');
        expect(cubit.state.isDemoting, isTrue);
        expect(cubit.state.isPromoting, isFalse);
        addTearDown(cubit.close);
      });

      test('isPromoting true when sub edits parent to null', () {
        final existing = CategoryFactory.subcategory(
          id: 'sub-cat',
          parentId: 'parent',
        );
        final cubit = buildCubit(existing: existing)..updateParentId(null);
        expect(cubit.state.isPromoting, isTrue);
        expect(cubit.state.isDemoting, isFalse);
        addTearDown(cubit.close);
      });
    });

    group('demote guardrails', () {
      blocTest<CategoryFormCubit, CategoryFormState>(
        'demote blocked when hasChildren is true',
        build: () => buildCubit(existing: CategoryFactory.expense()),
        seed: () => CategoryFormState.initial(
          userId: userId,
          existing: CategoryFactory.expense(),
        ).copyWith(parentId: 'new-parent', hasChildren: true),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having(
                (s) => s.failure,
                'failure',
                isA<ValidationFailure>(),
              ),
        ],
        verify: (_) {
          verifyNever(() => mockUpdate(any()));
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'demote blocked when hasBudget is true',
        build: () => buildCubit(existing: CategoryFactory.expense()),
        seed: () => CategoryFormState.initial(
          userId: userId,
          existing: CategoryFactory.expense(),
        ).copyWith(parentId: 'new-parent', hasBudget: true),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having(
                (s) => s.failure,
                'failure',
                isA<ValidationFailure>(),
              ),
        ],
        verify: (_) {
          verifyNever(() => mockUpdate(any()));
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'demote proceeds when no children and no budget',
        setUp: () {
          when(() => mockUpdate(any())).thenAnswer(
            (_) async => Right(CategoryFactory.expense()),
          );
        },
        build: () => buildCubit(existing: CategoryFactory.expense()),
        seed: () => CategoryFormState.initial(
          userId: userId,
          existing: CategoryFactory.expense(),
        ).copyWith(parentId: 'new-parent'),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdate(any())).called(1);
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'promote (sub → root) is not gated by demote guardrails',
        setUp: () {
          when(() => mockUpdate(any())).thenAnswer(
            (_) async => Right(CategoryFactory.expense()),
          );
        },
        build: () => buildCubit(
          existing: CategoryFactory.subcategory(parentId: 'parent'),
        ),
        seed: () => CategoryFormState.initial(
          userId: userId,
          existing: CategoryFactory.subcategory(parentId: 'parent'),
        ).copyWith(clearParentId: true),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdate(any())).called(1);
        },
      );

    });

    group('loadFormData', () {
      blocTest<CategoryFormCubit, CategoryFormState>(
        'create mode: exposes categories and seeds color from count',
        setUp: () {
          when(() => mockGetCategories(userId: userId)).thenAnswer(
            (_) async => Right(CategoryFactory.list()),
          );
        },
        build: buildCubit,
        act: (cubit) async => cubit.loadFormData(),
        expect: () => [
          isA<CategoryFormState>()
              .having((s) => s.isLoadingCategories, 'loading', isFalse)
              .having((s) => s.allCategories.length, 'allCategories', 4)
              .having(
                (s) => s.color,
                'color',
                CategoryColors.forIndex(4),
              ),
        ],
        verify: (_) {
          // Budgets are edit-mode-only metadata.
          verifyNever(() => mockGetBudgets(userId: any(named: 'userId')));
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'edit mode: keeps the existing color and sets demote guardrails',
        setUp: () {
          when(() => mockGetCategories(userId: userId)).thenAnswer(
            (_) async => Right([
              CategoryFactory.expense(),
              CategoryFactory.subcategory(),
            ]),
          );
          when(() => mockGetBudgets(userId: userId)).thenAnswer(
            (_) async => Right([BudgetFactory.make(categoryId: 'other-cat')]),
          );
        },
        // 'cat-expense-1' owns subcategory 'cat-sub-1' → hasChildren.
        build: () => buildCubit(existing: CategoryFactory.expense()),
        act: (cubit) async => cubit.loadFormData(),
        expect: () => [
          isA<CategoryFormState>()
              .having((s) => s.isLoadingCategories, 'loading', isFalse)
              .having((s) => s.color, 'color', 4294198070),
          isA<CategoryFormState>()
              .having((s) => s.hasChildren, 'hasChildren', isTrue)
              .having((s) => s.hasBudget, 'hasBudget', isFalse),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'edit mode: hasBudget true when a budget binds the category',
        setUp: () {
          when(() => mockGetCategories(userId: userId)).thenAnswer(
            (_) async => Right([CategoryFactory.expense()]),
          );
          when(() => mockGetBudgets(userId: userId)).thenAnswer(
            (_) async =>
                Right([BudgetFactory.make(categoryId: 'cat-expense-1')]),
          );
        },
        build: () => buildCubit(existing: CategoryFactory.expense()),
        act: (cubit) async => cubit.loadFormData(),
        verify: (cubit) {
          expect(cubit.state.hasBudget, isTrue);
          expect(cubit.state.hasChildren, isFalse);
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        're-applies parent icon/color when editing a subcategory',
        setUp: () {
          when(() => mockGetCategories(userId: userId)).thenAnswer(
            (_) async => Right([
              CategoryFactory.expense(icon: 11111, color: 22222),
              CategoryFactory.subcategory(),
            ]),
          );
          when(() => mockGetBudgets(userId: userId)).thenAnswer(
            (_) async => const Right([]),
          );
        },
        build: () => buildCubit(existing: CategoryFactory.subcategory()),
        act: (cubit) async => cubit.loadFormData(),
        verify: (cubit) {
          expect(cubit.state.icon, 11111);
          expect(cubit.state.color, 22222);
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'degrades to an empty list when the fetch fails',
        setUp: () {
          when(() => mockGetCategories(userId: userId)).thenAnswer(
            (_) async => const Left(ServerFailure('boom')),
          );
        },
        build: buildCubit,
        act: (cubit) async => cubit.loadFormData(),
        verify: (cubit) {
          expect(cubit.state.isLoadingCategories, isFalse);
          expect(cubit.state.allCategories, isEmpty);
        },
      );
    });

    group('submit', () {
      blocTest<CategoryFormCubit, CategoryFormState>(
        'does nothing when name is empty (invalid)',
        build: buildCubit,
        act: (cubit) async => cubit.submit(),
        expect: () => <CategoryFormState>[],
        verify: (_) {
          verifyNever(() => mockCreate(any()));
          verifyNever(() => mockUpdate(any()));
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'creates category when valid and not editing',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => Right(CategoryFactory.expense()));
        },
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          name: 'Food',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => mockCreate(
              any(
                that: isA<CategoryEntity>()
                    .having((c) => c.name, 'name', 'Food')
                    .having((c) => c.parentId, 'parentId', isNull),
              ),
            ),
          ).called(1);
          verifyNever(() => mockUpdate(any()));
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'updates category when valid and editing',
        setUp: () {
          when(
            () => mockUpdate(any()),
          ).thenAnswer((_) async => Right(CategoryFactory.expense()));
        },
        build: () => buildCubit(
          existing: CategoryFactory.subcategory(
            id: 'existing-1',
            parentId: 'parent-1',
          ),
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => mockUpdate(
              any(
                that: isA<CategoryEntity>()
                    .having((c) => c.id, 'id', 'existing-1')
                    .having((c) => c.parentId, 'parentId', 'parent-1'),
              ),
            ),
          ).called(1);
          verifyNever(() => mockCreate(any()));
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'emits failure status when create fails',
        setUp: () {
          when(() => mockCreate(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Create failed')),
          );
        },
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          name: 'Food',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<CategoryFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
      );
    });

    group('validation', () {
      test('isValid is false when name is empty', () {
        final cubit = buildCubit();
        expect(cubit.state.isValid, isFalse);
        addTearDown(cubit.close);
      });

      test('isValid is true when name is non-empty', () {
        final cubit = buildCubit()..updateName('Test');
        expect(cubit.state.isValid, isTrue);
        addTearDown(cubit.close);
      });
    });

    group('defaults', () {
      test('default icon value is 58332', () {
        final cubit = buildCubit();
        expect(cubit.state.icon, 58332);
        addTearDown(cubit.close);
      });

      test('default color is first palette color', () {
        final cubit = buildCubit();
        expect(cubit.state.color, CategoryColors.palette.first);
        addTearDown(cubit.close);
      });

      test('default type is expense', () {
        final cubit = buildCubit();
        expect(cubit.state.type, CategoryType.expense);
        addTearDown(cubit.close);
      });

      test('parentId is null by default', () {
        final cubit = buildCubit();
        expect(cubit.state.parentId, isNull);
        addTearDown(cubit.close);
      });
    });

    group('parentId management', () {
      blocTest<CategoryFormCubit, CategoryFormState>(
        'updateParentId with null clears parentId',
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          parentId: 'parent-1',
        ),
        act: (cubit) => cubit.updateParentId(null),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.parentId,
            'parentId',
            isNull,
          ),
        ],
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'submit includes parentId for subcategory',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => Right(CategoryFactory.subcategory()));
        },
        build: buildCubit,
        seed: () => CategoryFormState.initial(userId: userId).copyWith(
          name: 'Restaurants',
          parentId: 'parent-1',
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.success,
          ),
        ],
        verify: (_) {
          final captured = verify(() => mockCreate(captureAny())).captured;
          final category = captured.first as CategoryEntity;
          expect(category.parentId, 'parent-1');
        },
      );

      blocTest<CategoryFormCubit, CategoryFormState>(
        'emits failure status when update fails',
        setUp: () {
          when(() => mockUpdate(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Update failed')),
          );
        },
        build: () => buildCubit(
          existing: CategoryFactory.expense(id: 'existing-1'),
        ),
        act: (cubit) async => cubit.submit(),
        expect: () => [
          isA<CategoryFormState>().having(
            (s) => s.status,
            'status',
            FormStatus.submitting,
          ),
          isA<CategoryFormState>()
              .having((s) => s.status, 'status', FormStatus.failure)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
      );
    });
  });
}
