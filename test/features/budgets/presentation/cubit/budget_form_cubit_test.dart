import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/presentation/cubit/budget_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateBudgetUseCase createBudget;
  late MockUpdateBudgetUseCase updateBudget;

  const userId = 'user-1';

  setUpAll(registerBudgetFallbackValues);

  setUp(() {
    createBudget = MockCreateBudgetUseCase();
    updateBudget = MockUpdateBudgetUseCase();
  });

  BudgetFormCubit buildCubit({
    bool editMode = false,
  }) => BudgetFormCubit(
    createBudget: createBudget,
    updateBudget: updateBudget,
    userId: userId,
    existingBudget: editMode ? BudgetFactory.make() : null,
  );

  group('BudgetFormCubit', () {
    test('initial create state is invalid', () {
      final cubit = buildCubit();
      expect(cubit.state.isValid, isFalse);
      expect(cubit.state.isEditing, isFalse);
      addTearDown(cubit.close);
    });

    test('initial edit state hydrates from existing budget', () {
      final cubit = buildCubit(editMode: true);
      expect(cubit.state.isEditing, isTrue);
      expect(cubit.state.amount, 1500);
      expect(cubit.state.isValid, isTrue);
      addTearDown(cubit.close);
    });

    test('updateCategoryId is ignored in edit mode', () {
      final cubit = buildCubit(editMode: true);
      final originalCategory = cubit.state.categoryId;
      cubit.updateCategoryId('something-else');
      expect(cubit.state.categoryId, originalCategory);
      addTearDown(cubit.close);
    });

    test('isValid requires non-null category and positive amount', () {
      final cubit = buildCubit()
        ..updateCategoryId('cat-1')
        ..updateAmount('500');
      expect(cubit.state.isValid, isTrue);
      addTearDown(cubit.close);
    });

    test('updateAmount accepts BR-style decimals', () {
      final cubit = buildCubit()..updateAmount('1.500,00');
      expect(cubit.state.amount, 1500);
      addTearDown(cubit.close);
    });

    blocTest<BudgetFormCubit, BudgetFormState>(
      'submit is a no-op when invalid',
      build: buildCubit,
      act: (c) async => c.submit(),
      expect: () => <BudgetFormState>[],
    );

    blocTest<BudgetFormCubit, BudgetFormState>(
      'submit creates a new budget when not editing',
      setUp: () {
        when(() => createBudget(any())).thenAnswer(
          (_) async => Right(BudgetFactory.make()),
        );
      },
      build: buildCubit,
      act: (cubit) async {
        cubit
          ..updateCategoryId('cat-1')
          ..updateAmount('500');
        await cubit.submit();
      },
      skip: 2, // skip the two field-update emissions
      expect: () => [
        isA<BudgetFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<BudgetFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => createBudget(any())).called(1);
        verifyNever(() => updateBudget(any()));
      },
    );

    blocTest<BudgetFormCubit, BudgetFormState>(
      'submit updates when editing',
      setUp: () {
        when(() => updateBudget(any())).thenAnswer(
          (_) async => Right(BudgetFactory.make(amount: 999)),
        );
      },
      build: () => buildCubit(editMode: true),
      act: (cubit) async {
        cubit.updateAmount('999');
        await cubit.submit();
      },
      skip: 1,
      expect: () => [
        isA<BudgetFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<BudgetFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => updateBudget(any())).called(1);
        verifyNever(() => createBudget(any()));
      },
    );

    blocTest<BudgetFormCubit, BudgetFormState>(
      'submit emits failure with the failure object on error',
      setUp: () {
        when(() => createBudget(any())).thenAnswer(
          (_) async =>
              const Left(ValidationFailure('Já existe um orçamento')),
        );
      },
      build: buildCubit,
      act: (cubit) async {
        cubit
          ..updateCategoryId('cat-1')
          ..updateAmount('500');
        await cubit.submit();
      },
      skip: 2,
      expect: () => [
        isA<BudgetFormState>().having(
          (s) => s.status,
          'status',
          FormStatus.submitting,
        ),
        isA<BudgetFormState>()
            .having((s) => s.status, 'status', FormStatus.failure)
            .having(
              (s) => s.failure,
              'failure',
              isA<ValidationFailure>(),
            ),
      ],
    );
  });
}
