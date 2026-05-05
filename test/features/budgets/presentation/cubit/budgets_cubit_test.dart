import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/budgets/domain/entities/budget_overview.dart';
import 'package:financo/features/budgets/presentation/cubit/budgets_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/budget_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetBudgetsOverviewUseCase getOverview;
  late MockDeleteBudgetUseCase deleteBudget;
  late MockImportBudgetsCsvUseCase importBudgetsCsv;

  const userId = 'user-1';

  setUp(() {
    getOverview = MockGetBudgetsOverviewUseCase();
    deleteBudget = MockDeleteBudgetUseCase();
    importBudgetsCsv = MockImportBudgetsCsvUseCase();
  });

  BudgetsCubit buildCubit() => BudgetsCubit(
    getOverview: getOverview,
    deleteBudget: deleteBudget,
    importBudgetsCsv: importBudgetsCsv,
    userId: userId,
  );

  BudgetOverview overview() => BudgetOverview(
    budget: BudgetFactory.make(),
    categoryName: 'Alimentação',
    categoryIcon: 1,
    categoryColor: 1,
    spent: 200,
  );

  group('BudgetsCubit', () {
    test('initial state is BudgetsInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<BudgetsInitial>());
      addTearDown(cubit.close);
    });

    blocTest<BudgetsCubit, BudgetsState>(
      'emits [Loading, Loaded] on success',
      setUp: () {
        when(
          () => getOverview(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right([overview()]));
      },
      build: buildCubit,
      act: (c) async => c.loadBudgets(),
      expect: () => [
        isA<BudgetsLoading>(),
        isA<BudgetsLoaded>().having(
          (s) => s.overviews.length,
          'overviews length',
          1,
        ),
      ],
    );

    blocTest<BudgetsCubit, BudgetsState>(
      'emits [Loading, Error] on failure',
      setUp: () {
        when(
          () => getOverview(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: buildCubit,
      act: (c) async => c.loadBudgets(),
      expect: () => [isA<BudgetsLoading>(), isA<BudgetsError>()],
    );

    blocTest<BudgetsCubit, BudgetsState>(
      'no-ops when already loaded for the same month and forceRefresh '
      'is false',
      setUp: () {
        when(
          () => getOverview(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right([overview()]));
      },
      build: buildCubit,
      seed: () =>
          BudgetsLoaded(overviews: [overview()], month: DateTime(2026, 5)),
      // Same month as the seed → cubit must short-circuit without
      // re-fetching.
      act: (c) async => c.loadBudgets(month: DateTime(2026, 5)),
      expect: () => <BudgetsState>[],
      verify: (_) {
        verifyNever(
          () => getOverview(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        );
      },
    );

    blocTest<BudgetsCubit, BudgetsState>(
      'reloads when the requested month differs from the loaded one',
      setUp: () {
        when(
          () => getOverview(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right([overview()]));
      },
      build: buildCubit,
      seed: () =>
          BudgetsLoaded(overviews: [overview()], month: DateTime(2026, 5)),
      act: (c) async => c.loadBudgets(month: DateTime(2026, 4)),
      expect: () => [
        isA<BudgetsLoading>(),
        isA<BudgetsLoaded>().having(
          (s) => s.month.month,
          'month.month',
          4,
        ),
      ],
    );

    blocTest<BudgetsCubit, BudgetsState>(
      'reloads when forceRefresh is true even if already loaded',
      setUp: () {
        when(
          () => getOverview(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right([overview()]));
      },
      build: buildCubit,
      seed: () =>
          BudgetsLoaded(overviews: [overview()], month: DateTime(2026, 5)),
      act: (c) async => c.loadBudgets(forceRefresh: true),
      expect: () => [isA<BudgetsLoading>(), isA<BudgetsLoaded>()],
    );

    blocTest<BudgetsCubit, BudgetsState>(
      'deleteBudget triggers a force-refresh on success',
      setUp: () {
        when(() => deleteBudget(any())).thenAnswer(
          (_) async => const Right<Failure, void>(null),
        );
        when(
          () => getOverview(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => const Right([]));
      },
      build: buildCubit,
      seed: () =>
          BudgetsLoaded(overviews: [overview()], month: DateTime(2026, 5)),
      act: (c) async => c.deleteBudget('b1'),
      expect: () => [
        isA<BudgetsLoading>(),
        isA<BudgetsLoaded>().having(
          (s) => s.overviews,
          'overviews',
          isEmpty,
        ),
      ],
    );

    blocTest<BudgetsCubit, BudgetsState>(
      'deleteBudget restores prior state on failure',
      setUp: () {
        when(() => deleteBudget(any())).thenAnswer(
          (_) async => const Left<Failure, void>(ServerFailure('boom')),
        );
      },
      build: buildCubit,
      seed: () =>
          BudgetsLoaded(overviews: [overview()], month: DateTime(2026, 5)),
      act: (c) async => c.deleteBudget('b1'),
      expect: () => [isA<BudgetsError>(), isA<BudgetsLoaded>()],
    );

    test('totals reflect the loaded overviews', () {
      final state = BudgetsLoaded(
        overviews: [
          BudgetOverview(
            budget: BudgetFactory.make(amount: 1000),
            categoryName: 'Alimentação',
            categoryIcon: 1,
            categoryColor: 1,
            spent: 600,
          ),
          BudgetOverview(
            budget: BudgetFactory.make(id: 'b2', amount: 500),
            categoryName: 'Transporte',
            categoryIcon: 2,
            categoryColor: 2,
            spent: 700,
          ),
        ],
        month: DateTime(2026, 5),
      );

      expect(state.totalCap, 1500);
      expect(state.totalSpent, 1300);
      // overspend on the second budget doesn't drag totalRemaining negative
      expect(state.totalRemaining, 200);
    });
  });
}
