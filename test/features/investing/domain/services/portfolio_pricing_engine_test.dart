import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';
import 'package:financo/features/investing/domain/services/holding_calculator.dart';
import 'package:financo/features/investing/domain/services/portfolio_pricing_engine.dart';
import 'package:financo/features/investing/domain/services/valuation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockQuoteRepository quoteRepo;
  late MockFxDataSource fx;
  late MockIndexDataSource index;
  late MockMarketCacheStore cacheStore;

  setUpAll(() {
    registerFallbackValue(Currency.brl);
    registerFallbackValue(<Asset>[]);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    quoteRepo = MockQuoteRepository();
    fx = MockFxDataSource();
    index = MockIndexDataSource();
    cacheStore = MockMarketCacheStore();
  });

  // Real pure services (calculator, valuation, inputs builder) so the tests
  // exercise the engine's orchestration end-to-end; only the I/O ports are
  // mocked.
  PortfolioPricingEngine buildEngine() => PortfolioPricingEngine(
    quoteRepo,
    fx,
    const ValuationService(),
    index,
    cacheStore,
    const HoldingCalculator(),
  );

  Quote quoteFor(String assetId, double major, Currency currency) => Quote(
    assetId: assetId,
    unitPrice: Money.fromMajor(major, currency),
    asOf: DateTime.now(),
    fetchedAt: DateTime.now(),
    source: QuoteSource.brapi,
  );

  group('warmStart', () {
    test('applies a cached FX rate so a foreign holding is valued', () async {
      when(
        () => cacheStore.lastFxRate(any(), any()),
      ).thenAnswer((_) async => 5);
      when(cacheStore.allIndexSeries).thenAnswer((_) async => {});
      when(() => quoteRepo.getCached(any())).thenAnswer(
        (_) async => Right([quoteFor('asset-aapl', 120, Currency.usd)]),
      );
      final engine = buildEngine();

      await engine.warmStart();
      final priced = await engine.priceFromCache(
        [AssetTransactionFactory.buy()],
        [AssetFactory.stockUs()],
      );

      // 120 USD × 10 units × 5 (USD→BRL) = 6000 BRL, holding not fx-flagged.
      expect(
        priced.portfolio.totalValueBase,
        Money.fromMajor(6000, Currency.brl),
      );
      expect(priced.portfolio.holdings.single.fxMissing, isFalse);
    });

    test('excludes a foreign holding when no FX rate is cached', () async {
      when(
        () => cacheStore.lastFxRate(any(), any()),
      ).thenAnswer((_) async => null);
      when(cacheStore.allIndexSeries).thenAnswer((_) async => {});
      when(() => quoteRepo.getCached(any())).thenAnswer(
        (_) async => Right([quoteFor('asset-aapl', 120, Currency.usd)]),
      );
      final engine = buildEngine();

      await engine.warmStart();
      final priced = await engine.priceFromCache(
        [AssetTransactionFactory.buy()],
        [AssetFactory.stockUs()],
      );

      expect(priced.portfolio.totalValueBase.isZero, isTrue);
      expect(priced.portfolio.holdings.single.fxMissing, isTrue);
    });
  });

  group('heldPositions', () {
    test('keeps only assets with an open position', () {
      final engine = buildEngine();

      final held = engine.heldPositions(
        [AssetTransactionFactory.buy()],
        [AssetFactory.stockUs(), AssetFactory.stockBr()],
      );

      expect(held.ids, {'asset-aapl'});
      expect(held.assets, [AssetFactory.stockUs()]);
    });
  });

  group('quotesAreFresh', () {
    test('is true without hitting the repo when nothing is held', () async {
      final engine = buildEngine();

      expect(await engine.quotesAreFresh(<String>{}), isTrue);
      verifyNever(() => quoteRepo.lastFetchedAt(any()));
    });

    test('is fresh when the newest quote is recent', () async {
      when(
        () => quoteRepo.lastFetchedAt(any()),
      ).thenAnswer((_) async => DateTime.now());
      final engine = buildEngine();

      expect(await engine.quotesAreFresh({'asset-aapl'}), isTrue);
    });

    test('is stale when the newest quote is old', () async {
      when(() => quoteRepo.lastFetchedAt(any())).thenAnswer(
        (_) async => DateTime.now().subtract(const Duration(days: 365)),
      );
      final engine = buildEngine();

      expect(await engine.quotesAreFresh({'asset-aapl'}), isFalse);
    });

    test('is stale when nothing is cached', () async {
      when(
        () => quoteRepo.lastFetchedAt(any()),
      ).thenAnswer((_) async => null);
      final engine = buildEngine();

      expect(await engine.quotesAreFresh({'asset-aapl'}), isFalse);
    });
  });

  group('refreshNetwork', () {
    test('persists an FX rate per distinct foreign currency held', () async {
      when(
        () => quoteRepo.refresh(any()),
      ).thenAnswer((_) async => const Right(<Quote>[]));
      when(
        () => fx.rate(Currency.usd, Currency.brl),
      ).thenAnswer((_) async => const Right(5));
      when(
        () => fx.rate(Currency.eur, Currency.brl),
      ).thenAnswer((_) async => const Right(6));
      when(
        () => cacheStore.saveFxRate(any(), any(), any()),
      ).thenAnswer((_) async {});
      final engine = buildEngine();

      await engine.refreshNetwork(
        [
          AssetFactory.stockUs(),
          AssetFactory.stockUs(id: 'asset-eur', currency: Currency.eur),
        ],
        [AssetTransactionFactory.buy()],
      );

      verify(
        () => cacheStore.saveFxRate(Currency.usd, Currency.brl, 5),
      ).called(1);
      verify(
        () => cacheStore.saveFxRate(Currency.eur, Currency.brl, 6),
      ).called(1);
    });

    test('ignores an FX fetch failure and persists nothing', () async {
      when(
        () => quoteRepo.refresh(any()),
      ).thenAnswer((_) async => const Right(<Quote>[]));
      when(
        () => fx.rate(any(), any()),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => cacheStore.saveFxRate(any(), any(), any()),
      ).thenAnswer((_) async {});
      final engine = buildEngine();

      await engine.refreshNetwork(
        [AssetFactory.stockUs()],
        [AssetTransactionFactory.buy()],
      );

      verifyNever(() => cacheStore.saveFxRate(any(), any(), any()));
    });
  });

  group('priceFromCache', () {
    test('values a holding from its cached quote (base currency)', () async {
      when(() => quoteRepo.getCached(any())).thenAnswer(
        (_) async => Right([quoteFor('asset-petr4', 120, Currency.brl)]),
      );
      final engine = buildEngine();

      final priced = await engine.priceFromCache(
        [
          AssetTransactionFactory.buy(
            assetId: 'asset-petr4',
            institutionId: 'inst-nubank',
            currency: Currency.brl,
          ),
        ],
        [AssetFactory.stockBr()],
      );

      // 120 BRL × 10 units = 1200 BRL current value; no FX conversion needed.
      expect(
        priced.portfolio.totalValueBase,
        Money.fromMajor(1200, Currency.brl),
      );
      expect(priced.assetsById['asset-petr4'], AssetFactory.stockBr());
      expect(priced.hasOpenPosition, isTrue);
    });
  });
}
