import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateCategoryUseCase mockCreate;
  late MockUpdateCategoryUseCase mockUpdate;

  const userId = 'user-1';

  setUpAll(registerCategoryFallbackValues);

  setUp(() {
    mockCreate = MockCreateCategoryUseCase();
    mockUpdate = MockUpdateCategoryUseCase();
  });

  CategoryFormCubit buildCubit({CategoryEntity? existing}) => CategoryFormCubit(
    createCategory: mockCreate,
    updateCategory: mockUpdate,
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
  });
}
