import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/allocation_class.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/services/allocation_service.dart';
import 'package:financo/features/investing/presentation/cubit/investing_allocation_cubit.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockPortfolioPricingEngine engine;
  late MockGetAssetTransactionsUseCase getTransactions;
  late MockGetAssetsUseCase getAssets;
  late MockGetAssetClassesUseCase getClasses;
  const service = AllocationService();

  final transactions = [AssetTransactionFactory.buy()];
  final assets = [AssetFactory.stockUs()];
  final assetsById = {for (final a in assets) a.id: a};
  final portfolio = PortfolioValuation.empty();
  final classEntity = AssetClassEntity(
    id: 'c-stocks',
    userId: 'user-1',
    name: 'Stocks',
    icon: 0xe1db,
    color: 0xFF2196F3,
    targetPercent: 100,
    createdAt: DateTime(2024),
  );
  final expectedOverview = service.compute(
    classes: [
      const AllocationClass(
        id: 'c-stocks',
        name: 'Stocks',
        icon: 0xe1db,
        color: 0xFF2196F3,
        targetPercent: 100,
      ),
    ],
    assets: assets,
    holdings: portfolio.holdings,
    base: Currency.brl,
  );

  setUpAll(() {
    registerFallbackValue(<AssetTransaction>[]);
    registerFallbackValue(<Asset>[]);
    registerFallbackValue(<String>{});
  });

  setUp(() {
    engine = MockPortfolioPricingEngine();
    getTransactions = MockGetAssetTransactionsUseCase();
    getAssets = MockGetAssetsUseCase();
    getClasses = MockGetAssetClassesUseCase();
  });

  InvestingAllocationCubit build() => InvestingAllocationCubit(
    engine: engine,
    getTransactions: getTransactions,
    getAssets: getAssets,
    getClasses: getClasses,
    service: service,
    userId: 'user-1',
  );

  void stubHappyPath() {
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
    when(
      () => getTransactions(userId: 'user-1'),
    ).thenAnswer((_) async => Right(transactions));
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => Right(assets));
    when(
      () => getClasses(userId: 'user-1'),
    ).thenAnswer((_) async => Right([classEntity]));
  }

  blocTest<InvestingAllocationCubit, InvestingAllocationState>(
    'computes allocation cache-first, refreshes, then recomputes',
    build: () {
      stubHappyPath();
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingAllocationLoading(),
      InvestingAllocationLoaded(overview: expectedOverview, isRefreshing: true),
      InvestingAllocationLoaded(
        overview: expectedOverview,
        isRefreshing: false,
      ),
    ],
    verify: (_) {
      verify(() => engine.refreshNetwork(any(), any())).called(1);
    },
  );

  blocTest<InvestingAllocationCubit, InvestingAllocationState>(
    'emits [Error] when loading asset classes fails',
    build: () {
      when(engine.warmStart).thenAnswer((_) async {});
      when(
        () => getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => Right(transactions));
      when(
        () => getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => Right(assets));
      when(
        () => getClasses(userId: 'user-1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const InvestingAllocationLoading(),
      const InvestingAllocationError(ServerFailure()),
    ],
  );
}
