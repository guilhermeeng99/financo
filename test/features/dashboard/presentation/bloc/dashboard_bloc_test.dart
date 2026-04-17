import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/dashboard_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetDashboardSummaryUseCase mockGetSummary;
  late MockGetTransactionsUseCase mockGetTransactions;

  const userId = 'user-1';

  setUpAll(() {
    registerDashboardFallbackValues();
    registerTransactionFallbackValues();
  });

  setUp(() {
    mockGetSummary = MockGetDashboardSummaryUseCase();
    mockGetTransactions = MockGetTransactionsUseCase();
  });

  DashboardBloc buildBloc() => DashboardBloc(
    getDashboardSummary: mockGetSummary,
    getTransactions: mockGetTransactions,
    userId: userId,
  );

  void stubSuccess({DashboardSummary? summary}) {
    when(
      () => mockGetSummary(
        userId: any(named: 'userId'),
        month: any(named: 'month'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, DashboardSummary>(
        summary ?? DashboardFactory.summary(),
      ),
    );
    when(
      () => mockGetTransactions(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<TransactionEntity>>(
        TransactionFactory.list(),
      ),
    );
  }

  test('initial state is DashboardInitial', () {
    final bloc = buildBloc();
    expect(bloc.state, const DashboardInitial());
    addTearDown(bloc.close);
  });

  group('DashboardLoadRequested', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Loaded] on success',
      build: buildBloc,
      setUp: stubSuccess,
      act: (bloc) => bloc.add(
        DashboardLoadRequested(year: 2024, month: 6),
      ),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardLoaded>()
            .having(
              (s) => s.selectedYear,
              'selectedYear',
              2024,
            )
            .having(
              (s) => s.selectedMonth,
              'selectedMonth',
              6,
            ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Error] when summary fails',
      build: buildBloc,
      setUp: () {
        when(
          () => mockGetSummary(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => const Left<Failure, DashboardSummary>(
            ServerFailure(),
          ),
        );
        when(
          () => mockGetTransactions(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            accountId: any(named: 'accountId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, List<TransactionEntity>>(
            TransactionFactory.list(),
          ),
        );
      },
      act: (bloc) => bloc.add(
        DashboardLoadRequested(year: 2024, month: 6),
      ),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardError>(),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Error] when transactions fail',
      build: buildBloc,
      setUp: () {
        when(
          () => mockGetSummary(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, DashboardSummary>(
            DashboardFactory.summary(),
          ),
        );
        when(
          () => mockGetTransactions(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            accountId: any(named: 'accountId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => const Left<Failure, List<TransactionEntity>>(
            ServerFailure(),
          ),
        );
      },
      act: (bloc) => bloc.add(
        DashboardLoadRequested(year: 2024, month: 6),
      ),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardError>(),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'no-op when same year/month already loaded',
      build: buildBloc,
      setUp: stubSuccess,
      seed: () => DashboardLoaded(
        summary: DashboardFactory.summary(),
        recentTransactions: const [],
        selectedYear: 2024,
        selectedMonth: 6,
      ),
      act: (bloc) => bloc.add(
        DashboardLoadRequested(year: 2024, month: 6),
      ),
      expect: () => <DashboardState>[],
    );

    blocTest<DashboardBloc, DashboardState>(
      'reloads when forceRefresh even if same month',
      build: buildBloc,
      setUp: stubSuccess,
      seed: () => DashboardLoaded(
        summary: DashboardFactory.summary(),
        recentTransactions: const [],
        selectedYear: 2024,
        selectedMonth: 6,
      ),
      act: (bloc) => bloc.add(
        DashboardLoadRequested(
          year: 2024,
          month: 6,
          forceRefresh: true,
        ),
      ),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardLoaded>(),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'loads when different month',
      build: buildBloc,
      setUp: stubSuccess,
      seed: () => DashboardLoaded(
        summary: DashboardFactory.summary(),
        recentTransactions: const [],
        selectedYear: 2024,
        selectedMonth: 6,
      ),
      act: (bloc) => bloc.add(
        DashboardLoadRequested(year: 2024, month: 7),
      ),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardLoaded>().having(
          (s) => s.selectedMonth,
          'selectedMonth',
          7,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'limits recent transactions to 5',
      build: buildBloc,
      setUp: () {
        when(
          () => mockGetSummary(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, DashboardSummary>(
            DashboardFactory.summary(),
          ),
        );
        // Return 10 transactions
        when(
          () => mockGetTransactions(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            accountId: any(named: 'accountId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, List<TransactionEntity>>(
            List.generate(
              10,
              (i) => TransactionFactory.expense(id: 'tx-$i'),
            ),
          ),
        );
      },
      act: (bloc) => bloc.add(
        DashboardLoadRequested(year: 2024, month: 6),
      ),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardLoaded>().having(
          (s) => s.recentTransactions.length,
          'recentTransactions.length',
          5,
        ),
      ],
    );
  });

  group('DashboardRefreshRequested', () {
    blocTest<DashboardBloc, DashboardState>(
      'uses current year/month when loaded',
      build: buildBloc,
      setUp: stubSuccess,
      seed: () => DashboardLoaded(
        summary: DashboardFactory.summary(),
        recentTransactions: const [],
        selectedYear: 2024,
        selectedMonth: 3,
      ),
      act: (bloc) => bloc.add(const DashboardRefreshRequested()),
      expect: () => [
        isA<DashboardLoaded>().having(
          (s) => s.selectedMonth,
          'selectedMonth',
          3,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits Error when refresh fails',
      build: buildBloc,
      seed: () => DashboardLoaded(
        summary: DashboardFactory.summary(),
        recentTransactions: const [],
        selectedYear: 2024,
        selectedMonth: 6,
      ),
      setUp: () {
        when(
          () => mockGetSummary(
            userId: any(named: 'userId'),
            month: any(named: 'month'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => const Left<Failure, DashboardSummary>(
            ServerFailure(),
          ),
        );
        when(
          () => mockGetTransactions(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            accountId: any(named: 'accountId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => const Right<Failure, List<TransactionEntity>>([]),
        );
      },
      act: (bloc) => bloc.add(const DashboardRefreshRequested()),
      expect: () => [isA<DashboardError>()],
    );
  });
}
