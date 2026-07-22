import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';
import 'package:financo/features/investing/presentation/cubit/investing_overview_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockPortfolioPricingEngine engine;
  late MockGetAssetTransactionsUseCase getTransactions;
  late MockGetAssetsUseCase getAssets;
  late MockGetSnapshotsUseCase getSnapshots;
  late MockRecordDailySnapshotUseCase recordSnapshot;

  final portfolio = PortfolioValuation.empty();
  final transactions = [AssetTransactionFactory.buy()];
  final assets = [AssetFactory.stockUs()];
  final assetsById = {for (final a in assets) a.id: a};

  setUpAll(() {
    registerFallbackValue(<AssetTransaction>[]);
    registerFallbackValue(<Asset>[]);
    registerFallbackValue(<String>{});
    registerFallbackValue(PortfolioValuation.empty());
    registerFallbackValue(DateTime(2024));
  });

  setUp(() {
    engine = MockPortfolioPricingEngine();
    getTransactions = MockGetAssetTransactionsUseCase();
    getAssets = MockGetAssetsUseCase();
    getSnapshots = MockGetSnapshotsUseCase();
    recordSnapshot = MockRecordDailySnapshotUseCase();
    when(
      () => getSnapshots(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => const Right(<Snapshot>[]));
    when(
      () => recordSnapshot(
        userId: any(named: 'userId'),
        portfolio: any(named: 'portfolio'),
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => const Right(unit));
  });

  InvestingOverviewCubit build() => InvestingOverviewCubit(
    engine: engine,
    getTransactions: getTransactions,
    getAssets: getAssets,
    getSnapshots: getSnapshots,
    recordSnapshot: recordSnapshot,
    userId: 'user-1',
  );

  void stubEngineHappyPath() {
    when(engine.warmStart).thenAnswer((_) async {});
    when(
      () => engine.heldPositions(any(), any()),
    ).thenReturn((assets: assets, ids: {'asset-aapl'}));
    when(() => engine.quotesAreFresh(any())).thenAnswer((_) async => false);
    when(() => engine.refreshNetwork(any(), any())).thenAnswer((_) async {});
    when(() => engine.priceFromCache(any(), any())).thenAnswer(
      (_) async =>
          (portfolio: portfolio, assetsById: assetsById, hasOpenPosition: true),
    );
  }

  blocTest<InvestingOverviewCubit, InvestingOverviewState>(
    'prices from cache, refreshes, then re-prices (isRefreshing true→false)',
    build: () {
      stubEngineHappyPath();
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => Right(transactions));
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => Right(assets));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingOverviewLoading(),
      InvestingOverviewLoaded(
        portfolio: portfolio,
        assetsById: assetsById,
        snapshots: const [],
        isRefreshing: true,
      ),
      InvestingOverviewLoaded(
        portfolio: portfolio,
        assetsById: assetsById,
        snapshots: const [],
        isRefreshing: false,
      ),
    ],
    verify: (_) {
      verify(() => engine.refreshNetwork(any(), any())).called(1);
      verify(
        () => recordSnapshot(
          userId: 'user-1',
          portfolio: any(named: 'portfolio'),
          today: any(named: 'today'),
        ),
      ).called(1);
    },
  );

  blocTest<InvestingOverviewCubit, InvestingOverviewState>(
    'skips the network refresh when cached quotes are still fresh',
    build: () {
      stubEngineHappyPath();
      when(() => engine.quotesAreFresh(any())).thenAnswer((_) async => true);
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => Right(transactions));
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => Right(assets));
      return build();
    },
    act: (cubit) => cubit.load(),
    verify: (_) {
      verifyNever(() => engine.refreshNetwork(any(), any()));
    },
  );

  blocTest<InvestingOverviewCubit, InvestingOverviewState>(
    'emits [Error] when loading transactions fails',
    build: () {
      when(engine.warmStart).thenAnswer((_) async {});
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingOverviewLoading(),
      const InvestingOverviewError(ServerFailure()),
    ],
  );

  blocTest<InvestingOverviewCubit, InvestingOverviewState>(
    'keeps cached prices when the network refresh throws',
    build: () {
      stubEngineHappyPath();
      when(
        () => engine.refreshNetwork(any(), any()),
      ).thenThrow(Exception('network down'));
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => Right(transactions));
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => Right(assets));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingOverviewLoading(),
      InvestingOverviewLoaded(
        portfolio: portfolio,
        assetsById: assetsById,
        snapshots: const [],
        isRefreshing: true,
      ),
      InvestingOverviewLoaded(
        portfolio: portfolio,
        assetsById: assetsById,
        snapshots: const [],
        isRefreshing: false,
      ),
    ],
  );
}
