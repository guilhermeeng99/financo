import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/holding_valuation.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/services/institution_valuation_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAssetTransactionRepository txRepo;
  late MockAssetRepository assetRepo;
  late MockPortfolioPricingEngine engine;
  late InstitutionValuationReader reader;

  const userId = 'user-1';

  setUpAll(() {
    registerFallbackValue(<AssetTransaction>[]);
    registerFallbackValue(<Asset>[]);
  });

  setUp(() {
    txRepo = MockAssetTransactionRepository();
    assetRepo = MockAssetRepository();
    engine = MockPortfolioPricingEngine();
    reader = InstitutionValuationReader(
      transactionRepository: txRepo,
      assetRepository: assetRepo,
      pricingEngine: engine,
    );
  });

  PortfolioValuation portfolioWith(List<HoldingValuation> holdings) =>
      PortfolioValuation.fromHoldings(holdings, Currency.brl);

  Money brl(double v) => Money.fromMajor(v, Currency.brl);

  void stubLoad({
    required List<AssetTransaction> transactions,
    required List<Asset> assets,
    required PortfolioValuation portfolio,
  }) {
    when(
      () => txRepo.getTransactions(userId: any(named: 'userId')),
    ).thenAnswer((_) async => Right(transactions));
    when(
      () => assetRepo.getAssets(userId: any(named: 'userId')),
    ).thenAnswer((_) async => Right(assets));
    when(engine.warmStart).thenAnswer((_) async {});
    when(() => engine.priceFromCache(any(), any())).thenAnswer(
      (_) async => (
        portfolio: portfolio,
        assetsById: <String, Asset>{},
        hasOpenPosition: true,
      ),
    );
  }

  group('InstitutionValuationReader', () {
    test('groups market value and cost basis by institution id', () async {
      final avenue = HoldingValuationFactory.base(
        marketValueBase: brl(1000),
        investedBase: brl(700),
      );
      final nubank = HoldingValuationFactory.base(
        assetId: 'asset-petr4',
        institutionId: 'inst-nubank',
        marketValueBase: brl(400),
        investedBase: brl(500),
      );
      stubLoad(
        transactions: [AssetTransactionFactory.buy()],
        assets: [AssetFactory.stockUs()],
        portfolio: portfolioWith([avenue, nubank]),
      );

      final result = await reader.read(userId);

      expect(result.keys.toSet(), {'inst-avenue', 'inst-nubank'});
      expect(result['inst-avenue']!.marketValue, brl(1000));
      expect(result['inst-avenue']!.invested, brl(700));
      expect(result['inst-avenue']!.unrealizedPL, brl(300));
      expect(result['inst-nubank']!.marketValue, brl(400));
      expect(result['inst-nubank']!.unrealizedPL, brl(-100));
    });

    test('sums multiple holdings within the same institution', () async {
      final first = HoldingValuationFactory.base(
        assetId: 'a1',
        marketValueBase: brl(1000),
        investedBase: brl(800),
      );
      final second = HoldingValuationFactory.base(
        assetId: 'a2',
        marketValueBase: brl(500),
        investedBase: brl(400),
      );
      stubLoad(
        transactions: [AssetTransactionFactory.buy()],
        assets: [AssetFactory.stockUs()],
        portfolio: portfolioWith([first, second]),
      );

      final result = await reader.read(userId);

      expect(result['inst-avenue']!.marketValue, brl(1500));
      expect(result['inst-avenue']!.invested, brl(1200));
    });

    test('exposes the native-currency value for a foreign institution',
        () async {
      final avenue = HoldingValuationFactory.base(
        marketValueBase: brl(1000),
        marketValueNative: Money.fromMajor(200, Currency.usd),
      );
      stubLoad(
        transactions: [AssetTransactionFactory.buy()],
        assets: [AssetFactory.stockUs()],
        portfolio: portfolioWith([avenue]),
      );

      final result = await reader.read(userId);

      expect(result['inst-avenue']!.marketValue, brl(1000));
      expect(
        result['inst-avenue']!.marketValueNative,
        Money.fromMajor(200, Currency.usd),
      );
    });

    test('flags a stale price on the affected institution', () async {
      final stale = HoldingValuationFactory.base(
        priceStale: true,
      );
      stubLoad(
        transactions: [AssetTransactionFactory.buy()],
        assets: [AssetFactory.stockUs()],
        portfolio: portfolioWith([stale]),
      );

      final result = await reader.read(userId);

      expect(result['inst-avenue']!.priceStale, isTrue);
    });

    test('returns an empty map (no pricing) when there are no transactions',
        () async {
      when(
        () => txRepo.getTransactions(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(<AssetTransaction>[]));
      when(
        () => assetRepo.getAssets(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(<Asset>[]));

      final result = await reader.read(userId);

      expect(result, isEmpty);
      verifyNever(() => engine.priceFromCache(any(), any()));
    });

    test('degrades to an empty map when the transaction load fails', () async {
      when(
        () => txRepo.getTransactions(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => assetRepo.getAssets(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(<Asset>[]));

      final result = await reader.read(userId);

      expect(result, isEmpty);
    });
  });
}
