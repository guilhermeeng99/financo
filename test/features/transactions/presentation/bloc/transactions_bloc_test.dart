import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetTransactionsUseCase mockGetTransactions;
  late MockDeleteTransactionUseCase mockDeleteTransaction;
  late MockImportTransactionsCsvUseCase mockImportTransactionsCsv;

  const userId = 'user-1';

  setUp(() {
    mockGetTransactions = MockGetTransactionsUseCase();
    mockDeleteTransaction = MockDeleteTransactionUseCase();
    mockImportTransactionsCsv = MockImportTransactionsCsvUseCase();
  });

  TransactionsBloc buildBloc() => TransactionsBloc(
    getTransactions: mockGetTransactions,
    deleteTransaction: mockDeleteTransaction,
    importTransactionsCsv: mockImportTransactionsCsv,
    userId: userId,
  );

  group('TransactionsBloc', () {
    test('initial state is TransactionsInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<TransactionsInitial>());
      addTearDown(bloc.close);
    });

    group('TransactionsLoadRequested', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'emits [Loading, Loaded] when load succeeds',
        setUp: () {
          when(
            () => mockGetTransactions(
              userId: userId,
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer((_) async => Right(TransactionFactory.list()));
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(TransactionsLoadRequested(year: 2024, month: 3)),
        expect: () => [
          isA<TransactionsLoading>(),
          isA<TransactionsLoaded>().having(
            (s) => s.transactions.length,
            'count',
            3,
          ),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'emits [Loading, Error] when load fails',
        setUp: () {
          when(
            () => mockGetTransactions(
              userId: userId,
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer((_) async => const Left(ServerFailure()));
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(TransactionsLoadRequested(year: 2024, month: 3)),
        expect: () => [
          isA<TransactionsLoading>(),
          isA<TransactionsError>(),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'preserves selectedYear and selectedMonth in Loaded state',
        setUp: () {
          when(
            () => mockGetTransactions(
              userId: userId,
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer((_) async => const Right([]));
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(TransactionsLoadRequested(year: 2024, month: 6)),
        expect: () => [
          isA<TransactionsLoading>(),
          isA<TransactionsLoaded>()
              .having((s) => s.selectedYear, 'year', 2024)
              .having((s) => s.selectedMonth, 'month', 6),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'does not reload when same month already loaded and not forceRefresh',
        build: buildBloc,
        seed: () => const TransactionsLoaded(
          [],
          selectedYear: 2024,
          selectedMonth: 3,
        ),
        act: (bloc) =>
            bloc.add(TransactionsLoadRequested(year: 2024, month: 3)),
        expect: () => <TransactionsState>[],
        verify: (_) {
          verifyNever(
            () => mockGetTransactions(
              userId: any(named: 'userId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          );
        },
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'reloads when same month and forceRefresh is true',
        setUp: () {
          when(
            () => mockGetTransactions(
              userId: userId,
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              forceRefresh: true,
            ),
          ).thenAnswer((_) async => Right(TransactionFactory.list()));
        },
        build: buildBloc,
        seed: () => const TransactionsLoaded(
          [],
          selectedYear: 2024,
          selectedMonth: 3,
        ),
        act: (bloc) => bloc.add(
          TransactionsLoadRequested(
            year: 2024,
            month: 3,
            forceRefresh: true,
          ),
        ),
        expect: () => [
          isA<TransactionsLoading>(),
          isA<TransactionsLoaded>(),
        ],
      );
    });

    group('TransactionDeleteRequested', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'emits Error when delete fails',
        setUp: () {
          when(
            () => mockDeleteTransaction(any()),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Delete failed')),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TransactionDeleteRequested('tx-1')),
        expect: () => [isA<TransactionsError>()],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        're-dispatches LoadRequested on successful delete',
        setUp: () {
          when(
            () => mockDeleteTransaction(any()),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockGetTransactions(
              userId: userId,
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              forceRefresh: true,
            ),
          ).thenAnswer((_) async => const Right([]));
        },
        build: buildBloc,
        seed: () => TransactionsLoaded(
          TransactionFactory.list(),
          selectedYear: 2024,
          selectedMonth: 3,
        ),
        act: (bloc) => bloc.add(const TransactionDeleteRequested('tx-1')),
        expect: () => [
          isA<TransactionsLoading>(),
          isA<TransactionsLoaded>(),
        ],
        verify: (_) {
          verify(() => mockDeleteTransaction('tx-1')).called(1);
        },
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'uses current date when deleting from Initial state',
        setUp: () {
          when(
            () => mockDeleteTransaction(any()),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockGetTransactions(
              userId: userId,
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              forceRefresh: true,
            ),
          ).thenAnswer((_) async => const Right([]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TransactionDeleteRequested('tx-1')),
        expect: () => [
          isA<TransactionsLoading>(),
          isA<TransactionsLoaded>().having(
            (s) => s.selectedYear,
            'selectedYear',
            DateTime.now().year,
          ),
        ],
      );
    });

    group('TransactionsImportCsvRequested', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'emits [Loading, Imported] on successful import',
        setUp: () {
          when(
            () => mockImportTransactionsCsv(
              csvContent: any(named: 'csvContent'),
              userId: any(named: 'userId'),
            ),
          ).thenAnswer(
            (_) async => const Right(
              TransactionImportResult(importedCount: 5, skippedCount: 1),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const TransactionsImportCsvRequested('csv-data')),
        expect: () => [
          isA<TransactionsLoading>(),
          isA<TransactionsImported>()
              .having((s) => s.importedCount, 'importedCount', 5)
              .having((s) => s.skippedCount, 'skippedCount', 1),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'emits [Loading, Error] on import failure',
        setUp: () {
          when(
            () => mockImportTransactionsCsv(
              csvContent: any(named: 'csvContent'),
              userId: any(named: 'userId'),
            ),
          ).thenAnswer(
            (_) async => const Left(ValidationFailure('Missing categories')),
          );
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const TransactionsImportCsvRequested('csv-data')),
        expect: () => [
          isA<TransactionsLoading>(),
          isA<TransactionsError>().having(
            (s) => s.failure.message,
            'message',
            'Missing categories',
          ),
        ],
      );

      test('previewCsv delegates to use case', () async {
        const preview = TransactionImportPreview(
          rows: [],
          missingCategories: [],
          missingAccounts: [],
          skippedRows: 0,
        );
        when(
          () => mockImportTransactionsCsv.preview(
            csvContent: any(named: 'csvContent'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => const Right(preview));

        final bloc = buildBloc();
        final result = await bloc.previewCsv('csv-data');
        addTearDown(bloc.close);

        expect(result, const Right<Failure, TransactionImportPreview>(preview));
        verify(
          () => mockImportTransactionsCsv.preview(
            csvContent: 'csv-data',
            userId: userId,
          ),
        ).called(1);
      });
    });
  });
}
