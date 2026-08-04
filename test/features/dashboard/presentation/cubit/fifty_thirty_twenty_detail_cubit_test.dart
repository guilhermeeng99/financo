import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_history_entry.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/presentation/cubit/fifty_thirty_twenty_detail_cubit.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetCategoriesUseCase getCategories;
  late MockGetTransactionsUseCase getTransactions;
  late MockGetFiftyThirtyTwentyHistoryUseCase getHistory;
  late MockGetInstitutionsUseCase getInstitutions;

  const userId = 'user-1';
  final month = DateTime(2026, 3);
  const targets = FiftyThirtyTwentyTargets.classic;

  setUpAll(registerDashboardFallbackValues);

  setUp(() {
    getCategories = MockGetCategoriesUseCase();
    getTransactions = MockGetTransactionsUseCase();
    getHistory = MockGetFiftyThirtyTwentyHistoryUseCase();
    getInstitutions = MockGetInstitutionsUseCase();
    when(
      () => getInstitutions(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => const Right([]));
  });

  FiftyThirtyTwentyDetailCubit buildCubit() => FiftyThirtyTwentyDetailCubit(
    getCategories: getCategories,
    getTransactions: getTransactions,
    getHistory: getHistory,
    getInstitutions: getInstitutions,
    userId: userId,
  );

  void stubCategories(Either<Failure, List<CategoryEntity>> result) {
    when(
      () => getCategories(
        userId: userId,
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => result);
  }

  void stubTransactions(Either<Failure, List<TransactionEntity>> result) {
    when(
      () => getTransactions(
        userId: userId,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        dueStartDate: any(named: 'dueStartDate'),
        dueEndDate: any(named: 'dueEndDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
        settlementStatus: any(named: 'settlementStatus'),
        recurrence: any(named: 'recurrence'),
        recurrenceGroupId: any(named: 'recurrenceGroupId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => result);
  }

  void stubHistory(
    Either<Failure, List<FiftyThirtyTwentyHistoryEntry>> result,
  ) {
    when(
      () => getHistory(
        userId: userId,
        referenceMonth: any(named: 'referenceMonth'),
        monthCount: any(named: 'monthCount'),
        targets: any(named: 'targets'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => result);
  }

  final historyEntries = [
    FiftyThirtyTwentyHistoryEntry(
      month: DateTime(2026, 2),
      overview: FiftyThirtyTwentyOverview.empty,
    ),
  ];

  test('initial state is empty and safe to render', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    expect(cubit.state.status, FiftyThirtyTwentyDetailStatus.initial);
    expect(cubit.state.overview, FiftyThirtyTwentyOverview.empty);
    expect(cubit.state.history, isEmpty);
    expect(cubit.state.periodTransactions, isEmpty);
  });

  group('load', () {
    blocTest<FiftyThirtyTwentyDetailCubit, FiftyThirtyTwentyDetailState>(
      'emits loading then ready with the composed overview, keeping only '
      'paid transactions',
      setUp: () {
        stubCategories(
          Right([
            CategoryFactory.income(id: 'cat-salary'),
            CategoryFactory.expense(
              id: 'cat-needs',
              bucket: CategoryBucket.needs,
            ),
          ]),
        );
        stubTransactions(
          Right([
            TransactionFactory.income(
              id: 'tx-income',
              categoryId: 'cat-salary',
              amount: 1000,
              date: DateTime(2026, 3, 5),
            ),
            TransactionFactory.expense(
              id: 'tx-needs',
              categoryId: 'cat-needs',
              amount: 400,
              date: DateTime(2026, 3, 10),
            ),
            // Pending payables haven't hit the cash flow yet: they must
            // be excluded from the period before the overview computes.
            TransactionFactory.expense(
              id: 'tx-pending',
              categoryId: 'cat-needs',
              amount: 999,
              settlementStatus: TransactionSettlementStatus.pending,
              date: DateTime(2026, 3, 12),
            ),
          ]),
        );
        stubHistory(Right(historyEntries));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(month: month, targets: targets),
      expect: () => [
        isA<FiftyThirtyTwentyDetailState>().having(
          (s) => s.status,
          'status',
          FiftyThirtyTwentyDetailStatus.loading,
        ),
        isA<FiftyThirtyTwentyDetailState>()
            .having(
              (s) => s.status,
              'status',
              FiftyThirtyTwentyDetailStatus.ready,
            )
            .having((s) => s.month, 'month', month)
            .having((s) => s.overview.income, 'overview.income', 1000)
            .having((s) => s.overview.needsSpent, 'overview.needsSpent', 400)
            .having((s) => s.history, 'history', historyEntries)
            .having(
              (s) => s.periodTransactions.map((t) => t.id).toList(),
              'paid period transactions',
              ['tx-income', 'tx-needs'],
            ),
      ],
    );

    blocTest<FiftyThirtyTwentyDetailCubit, FiftyThirtyTwentyDetailState>(
      'emits error carrying the failure when the categories read fails',
      setUp: () {
        stubCategories(const Left(ServerFailure('categories down')));
        stubTransactions(const Right([]));
        stubHistory(Right(historyEntries));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(month: month, targets: targets),
      expect: () => [
        isA<FiftyThirtyTwentyDetailState>().having(
          (s) => s.status,
          'status',
          FiftyThirtyTwentyDetailStatus.loading,
        ),
        isA<FiftyThirtyTwentyDetailState>()
            .having(
              (s) => s.status,
              'status',
              FiftyThirtyTwentyDetailStatus.error,
            )
            .having(
              (s) => s.failure?.message,
              'failure message',
              'categories down',
            ),
      ],
    );

    blocTest<FiftyThirtyTwentyDetailCubit, FiftyThirtyTwentyDetailState>(
      'surfaces the first failing read when several succeed before it',
      setUp: () {
        stubCategories(const Right([]));
        stubTransactions(const Left(ServerFailure('tx down')));
        stubHistory(const Left(ServerFailure('history down')));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(month: month, targets: targets),
      expect: () => [
        isA<FiftyThirtyTwentyDetailState>().having(
          (s) => s.status,
          'status',
          FiftyThirtyTwentyDetailStatus.loading,
        ),
        isA<FiftyThirtyTwentyDetailState>()
            .having(
              (s) => s.status,
              'status',
              FiftyThirtyTwentyDetailStatus.error,
            )
            .having((s) => s.failure?.message, 'failure message', 'tx down'),
      ],
    );
  });
}
