import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/investing/presentation/cubit/investing_transactions_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetAssetTransactionsUseCase getTransactions;
  late MockGetAssetsUseCase getAssets;
  late MockGetInstitutionsUseCase getInstitutions;
  late MockImportInvestingTransactionsCsvUseCase importTransactionsCsv;

  setUp(() {
    getTransactions = MockGetAssetTransactionsUseCase();
    getAssets = MockGetAssetsUseCase();
    getInstitutions = MockGetInstitutionsUseCase();
    importTransactionsCsv = MockImportInvestingTransactionsCsvUseCase();
  });

  InvestingTransactionsCubit build() => InvestingTransactionsCubit(
    getTransactions: getTransactions,
    getAssets: getAssets,
    getInstitutions: getInstitutions,
    importTransactionsCsv: importTransactionsCsv,
    userId: 'user-1',
  );

  /// A row whose ticker resolved to an asset — the only kind that imports.
  final importableItem = InvestingTransactionImportPreviewItem(
    ticker: 'AAPL',
    kind: TransactionKind.buy,
    quantity: 10,
    unitPriceMajor: 100,
    amountMajor: 1000,
    feesMajor: 0,
    date: DateTime(2024, 1, 10),
    asset: AssetFactory.stockUs(),
  );

  /// A row the resolver could not match — reported, never written.
  final skippedItem = InvestingTransactionImportPreviewItem(
    ticker: 'GHOST',
    kind: TransactionKind.buy,
    quantity: 1,
    unitPriceMajor: 1,
    amountMajor: 1,
    feesMajor: 0,
    date: DateTime(2024, 1, 10),
    problem: InvestingTransactionImportProblem.assetNotFound,
  );

  void stubLoadOk() {
    when(
      () => getTransactions(userId: 'user-1', forceRefresh: true),
    ).thenAnswer((_) async => Right([AssetTransactionFactory.buy()]));
    when(
      () => getAssets(userId: 'user-1', forceRefresh: true),
    ).thenAnswer((_) async => Right([AssetFactory.stockUs()]));
    when(
      () => getInstitutions(userId: 'user-1', forceRefresh: true),
    ).thenAnswer((_) async => Right([InstitutionFactory.avenue()]));
  }

  blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
    'emits [Loading, Loaded] merging transactions, assets and institutions',
    build: () {
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => Right([AssetTransactionFactory.buy()]));
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => Right([AssetFactory.stockUs()]));
      when(
        () => getInstitutions(userId: 'user-1'),
      ).thenAnswer((_) async => Right([InstitutionFactory.avenue()]));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingTransactionsLoading(),
      InvestingTransactionsLoaded(
        transactions: [AssetTransactionFactory.buy()],
        assets: [AssetFactory.stockUs()],
        institutions: [InstitutionFactory.avenue()],
      ),
    ],
  );

  blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
    'emits [Error] when any dependency load fails',
    build: () {
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingTransactionsLoading(),
      const InvestingTransactionsError(ServerFailure()),
    ],
  );

  group('previewCsv', () {
    // The preview page renders from the returned value — parsing a file the
    // user might still cancel must not disturb the list already on screen.
    late Either<Failure, InvestingTransactionImportPreview> result;

    blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
      'returns the parsed preview without emitting any state',
      setUp: () {
        when(
          () => importTransactionsCsv.preview(
            csvContent: any(named: 'csvContent'),
            userId: 'user-1',
          ),
        ).thenAnswer(
          (_) async => Right(
            InvestingTransactionImportPreview(
              toImport: [importableItem],
              skipped: [skippedItem],
            ),
          ),
        );
      },
      build: build,
      seed: () => InvestingTransactionsLoaded(
        transactions: [AssetTransactionFactory.buy()],
        assets: [AssetFactory.stockUs()],
        institutions: [InstitutionFactory.avenue()],
      ),
      act: (cubit) async => result = await cubit.previewCsv('ticker,qtd\n'),
      expect: () => <InvestingTransactionsState>[],
      verify: (_) {
        expect(
          result.getOrElse(() => throw StateError('expected Right')).skipped,
          [skippedItem],
        );
        verify(
          () => importTransactionsCsv.preview(
            csvContent: 'ticker,qtd\n',
            userId: 'user-1',
          ),
        ).called(1);
      },
    );

    blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
      'forwards a malformed-file failure without emitting any state',
      setUp: () {
        when(
          () => importTransactionsCsv.preview(
            csvContent: any(named: 'csvContent'),
            userId: 'user-1',
          ),
        ).thenAnswer(
          (_) async => const Left(ValidationFailure('missing column: ticker')),
        );
      },
      build: build,
      act: (cubit) async => result = await cubit.previewCsv('bogus'),
      expect: () => <InvestingTransactionsState>[],
      verify: (_) => expect(result.isLeft(), isTrue),
    );
  });

  group('confirmImport', () {
    void stubImport({
      required Either<Failure, InvestingTransactionImportResult> outcome,
      int progressSteps = 1,
    }) {
      when(
        () => importTransactionsCsv.importItems(
          items: any(named: 'items'),
          userId: 'user-1',
          skippedCount: any(named: 'skippedCount'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((invocation) async {
        final onProgress =
            invocation.namedArguments[const Symbol('onProgress')]
                as void Function(int, int)?;
        for (var i = 1; i <= progressSteps; i++) {
          onProgress?.call(i, progressSteps);
        }
        return outcome;
      });
    }

    blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
      'emits Importing progress then reloads the list on success',
      setUp: () {
        stubImport(
          outcome: const Right(
            InvestingTransactionImportResult(
              importedCount: 1,
              skippedCount: 0,
            ),
          ),
        );
        stubLoadOk();
      },
      build: build,
      act: (cubit) async => cubit.confirmImport(items: [importableItem]),
      expect: () => [
        isA<InvestingTransactionsImporting>()
            .having((s) => s.processed, 'processed', 0)
            .having((s) => s.total, 'total', 1),
        isA<InvestingTransactionsImporting>().having(
          (s) => s.processed,
          'processed',
          1,
        ),
        // A forced reload — buy/sell rows move money, so the list has to come
        // back from the source of truth rather than be patched optimistically.
        const InvestingTransactionsLoading(),
        isA<InvestingTransactionsLoaded>(),
      ],
    );

    blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
      'counts only importable items and never sends the skipped ones',
      setUp: () {
        stubImport(
          outcome: const Right(
            InvestingTransactionImportResult(
              importedCount: 1,
              skippedCount: 1,
            ),
          ),
        );
        stubLoadOk();
      },
      build: build,
      act: (cubit) async => cubit.confirmImport(
        items: [importableItem, skippedItem],
        skippedCount: 1,
      ),
      expect: () => [
        // total is 1, not 2 — the unresolved row is filtered out before the
        // progress bar is sized, so the bar cannot stall at 1/2.
        isA<InvestingTransactionsImporting>().having(
          (s) => s.total,
          'total',
          1,
        ),
        isA<InvestingTransactionsImporting>(),
        const InvestingTransactionsLoading(),
        isA<InvestingTransactionsLoaded>(),
      ],
      verify: (_) {
        final captured = verify(
          () => importTransactionsCsv.importItems(
            items: captureAny(named: 'items'),
            userId: 'user-1',
            skippedCount: any(named: 'skippedCount'),
            onProgress: any(named: 'onProgress'),
          ),
        ).captured.single as List<InvestingTransactionImportPreviewItem>;
        expect(captured, [importableItem]);
      },
    );

    test('returns the report so the page can pop with a summary', () async {
      stubImport(
        outcome: const Right(
          InvestingTransactionImportResult(importedCount: 1, skippedCount: 1),
        ),
      );
      stubLoadOk();
      final cubit = build();
      addTearDown(cubit.close);

      final result = await cubit.confirmImport(
        items: [importableItem, skippedItem],
        skippedCount: 1,
      );

      expect(
        result,
        const Right<Failure, InvestingTransactionImportResult>(
          InvestingTransactionImportResult(importedCount: 1, skippedCount: 1),
        ),
      );
    });

    blocTest<InvestingTransactionsCubit, InvestingTransactionsState>(
      'emits Error and skips the reload when a save fails mid-import',
      setUp: () => stubImport(
        // e.g. the oversell guard rejecting a sell with no covering buy.
        outcome: const Left(ValidationFailure('oversell')),
        progressSteps: 0,
      ),
      build: build,
      act: (cubit) async => cubit.confirmImport(items: [importableItem]),
      expect: () => [
        isA<InvestingTransactionsImporting>(),
        const InvestingTransactionsError(ValidationFailure('oversell')),
      ],
      verify: (_) {
        // The partially-written ledger must stay visible as an error, not be
        // papered over by a fresh list.
        verifyNever(
          () => getTransactions(userId: 'user-1', forceRefresh: true),
        );
      },
    );

    test('returns Left carrying the failure', () async {
      stubImport(
        outcome: const Left(ValidationFailure('oversell')),
        progressSteps: 0,
      );
      final cubit = build();
      addTearDown(cubit.close);

      final result = await cubit.confirmImport(items: [importableItem]);

      expect(
        result,
        const Left<Failure, InvestingTransactionImportResult>(
          ValidationFailure('oversell'),
        ),
      );
    });
  });
}
