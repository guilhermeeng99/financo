import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/usecases/import_assets_csv_usecase.dart';
import 'package:financo/features/investing/presentation/cubit/assets_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetAssetsUseCase getAssets;
  late MockImportAssetsCsvUseCase importAssetsCsv;

  setUp(() {
    getAssets = MockGetAssetsUseCase();
    importAssetsCsv = MockImportAssetsCsvUseCase();
  });

  AssetsCubit build() => AssetsCubit(
    getAssets: getAssets,
    importAssetsCsv: importAssetsCsv,
    userId: 'user-1',
  );

  const previewItem = AssetImportPreviewItem(
    ticker: 'VOO',
    name: 'Vanguard S&P 500',
    kind: AssetKind.etfUs,
    market: Market.us,
    currency: Currency.usd,
    institutionName: 'Avenue',
  );

  blocTest<AssetsCubit, AssetsState>(
    'emits [Loading, Loaded] when the load succeeds',
    build: () {
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => Right([AssetFactory.stockUs()]));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const AssetsLoading(),
      AssetsLoaded([AssetFactory.stockUs()]),
    ],
  );

  blocTest<AssetsCubit, AssetsState>(
    'emits [Loading, Error] when the load fails',
    build: () {
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const AssetsLoading(),
      const AssetsError(ServerFailure()),
    ],
  );

  group('previewCsv', () {
    // The preview page renders from the *returned* value, not from cubit
    // state — parsing a file the user might still cancel must not disturb the
    // list already on screen.
    late Either<Failure, AssetImportPreview> result;

    blocTest<AssetsCubit, AssetsState>(
      'returns the parsed preview without emitting any state',
      setUp: () {
        when(
          () => importAssetsCsv.preview(
            csvContent: any(named: 'csvContent'),
            userId: 'user-1',
          ),
        ).thenAnswer(
          (_) async => const Right(
            AssetImportPreview(toCreate: [previewItem], duplicates: []),
          ),
        );
      },
      build: build,
      seed: () => AssetsLoaded([AssetFactory.stockUs()]),
      act: (cubit) async => result = await cubit.previewCsv('ticker,kind\n'),
      expect: () => <AssetsState>[],
      verify: (_) {
        expect(
          result,
          const Right<Failure, AssetImportPreview>(
            AssetImportPreview(toCreate: [previewItem], duplicates: []),
          ),
        );
        verify(
          () => importAssetsCsv.preview(
            csvContent: 'ticker,kind\n',
            userId: 'user-1',
          ),
        ).called(1);
      },
    );

    blocTest<AssetsCubit, AssetsState>(
      'forwards a malformed-file failure without emitting any state',
      setUp: () {
        when(
          () => importAssetsCsv.preview(
            csvContent: any(named: 'csvContent'),
            userId: 'user-1',
          ),
        ).thenAnswer(
          (_) async => const Left(ValidationFailure('missing column: ticker')),
        );
      },
      build: build,
      act: (cubit) async => result = await cubit.previewCsv('bogus'),
      expect: () => <AssetsState>[],
      verify: (_) => expect(result.isLeft(), isTrue),
    );
  });

  group('confirmImport', () {
    void stubImport({
      required Either<Failure, AssetImportResult> outcome,
      int progressSteps = 1,
    }) {
      when(
        () => importAssetsCsv.importItems(
          items: any(named: 'items'),
          userId: 'user-1',
          duplicateCount: any(named: 'duplicateCount'),
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

    blocTest<AssetsCubit, AssetsState>(
      'emits Importing progress then reloads the list on success',
      setUp: () {
        stubImport(
          outcome: const Right(
            AssetImportResult(
              importedCount: 1,
              duplicateCount: 0,
              institutionsCreated: 1,
            ),
          ),
        );
        when(
          () => getAssets(userId: 'user-1', forceRefresh: true),
        ).thenAnswer((_) async => Right([AssetFactory.stockUs()]));
      },
      build: build,
      act: (cubit) async => cubit.confirmImport(items: const [previewItem]),
      expect: () => [
        // Seeded at 0 before the first write so the progress bar starts empty.
        isA<AssetsImporting>()
            .having((s) => s.processed, 'processed', 0)
            .having((s) => s.total, 'total', 1),
        isA<AssetsImporting>().having((s) => s.processed, 'processed', 1),
        // A forced reload — the imported rows must come from the source of
        // truth, not be appended optimistically.
        const AssetsLoading(),
        AssetsLoaded([AssetFactory.stockUs()]),
      ],
    );

    test('returns the report so the page can pop with a summary', () async {
      stubImport(
        outcome: const Right(
          AssetImportResult(
            importedCount: 2,
            duplicateCount: 3,
            institutionsCreated: 1,
          ),
        ),
        progressSteps: 2,
      );
      when(
        () => getAssets(userId: 'user-1', forceRefresh: true),
      ).thenAnswer((_) async => Right([AssetFactory.stockUs()]));
      final cubit = build();
      addTearDown(cubit.close);

      final result = await cubit.confirmImport(
        items: const [previewItem, previewItem],
        duplicateCount: 3,
      );

      expect(
        result,
        const Right<Failure, AssetImportResult>(
          AssetImportResult(
            importedCount: 2,
            duplicateCount: 3,
            institutionsCreated: 1,
          ),
        ),
      );
    });

    blocTest<AssetsCubit, AssetsState>(
      'emits Error and skips the reload when the import fails',
      setUp: () => stubImport(
        outcome: const Left(ServerFailure()),
        progressSteps: 0,
      ),
      build: build,
      act: (cubit) async => cubit.confirmImport(items: const [previewItem]),
      expect: () => [
        isA<AssetsImporting>(),
        const AssetsError(ServerFailure()),
      ],
      verify: (_) {
        // A half-written import must not be masked by a fresh list.
        verifyNever(() => getAssets(userId: 'user-1', forceRefresh: true));
      },
    );

    test('returns Left carrying the failure', () async {
      stubImport(outcome: const Left(ServerFailure()), progressSteps: 0);
      final cubit = build();
      addTearDown(cubit.close);

      final result = await cubit.confirmImport(items: const [previewItem]);

      expect(result, const Left<Failure, AssetImportResult>(ServerFailure()));
    });

    blocTest<AssetsCubit, AssetsState>(
      'reports a complete bar for an empty item list',
      setUp: () {
        stubImport(
          outcome: const Right(
            AssetImportResult(
              importedCount: 0,
              duplicateCount: 4,
              institutionsCreated: 0,
            ),
          ),
          progressSteps: 0,
        );
        when(
          () => getAssets(userId: 'user-1', forceRefresh: true),
        ).thenAnswer((_) async => const Right(<Asset>[]));
      },
      build: build,
      act: (cubit) async =>
          cubit.confirmImport(items: const [], duplicateCount: 4),
      expect: () => [
        // total == 0 would divide by zero; progress is defined as 1 instead.
        isA<AssetsImporting>().having((s) => s.progress, 'progress', 1),
        const AssetsLoading(),
        const AssetsLoaded([]),
      ],
    );
  });
}
