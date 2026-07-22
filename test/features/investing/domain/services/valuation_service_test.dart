import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/fixed_income_terms.dart';
import 'package:financo/features/investing/domain/entities/holding.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';
import 'package:financo/features/investing/domain/services/valuation_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  const service = ValuationService();
  const brl = Currency.brl;
  const usd = Currency.usd;
  final now = DateTime(2024, 6);

  Holding holding({
    Currency currency = brl,
    double quantity = 10,
    double avgCostMajor = 100,
    double realizedMajor = 0,
    double dividendsMajor = 0,
  }) {
    return Holding(
      assetId: 'asset-1',
      institutionId: 'inst-1',
      quantity: quantity,
      avgCost: Money.fromMajor(avgCostMajor, currency),
      realizedPL: Money.fromMajor(realizedMajor, currency),
      dividends: Money.fromMajor(dividendsMajor, currency),
    );
  }

  test('market-priced BRL holding: value, invested and unrealized P/L', () {
    final v = service.valuateHolding(
      ValuationInput(
        holding: holding(),
        asset: AssetFactory.stockBr(),
        fxToBase: 1,
        quote: Quote(
          assetId: 'asset-1',
          unitPrice: Money.fromMajor(150, brl),
          asOf: now,
          fetchedAt: now,
          source: QuoteSource.brapi,
        ),
      ),
      now: now,
    );

    expect(v.marketValueBase, Money.fromMajor(1500, brl)); // 150 * 10
    expect(v.investedBase, Money.fromMajor(1000, brl)); // 100 * 10
    expect(v.unrealizedPL, Money.fromMajor(500, brl));
    expect(v.priceStale, isFalse);
    expect(v.fxMissing, isFalse);
  });

  test('USD holding consolidates to BRL via the FX rate', () {
    final v = service.valuateHolding(
      ValuationInput(
        holding: holding(currency: usd),
        asset: AssetFactory.stockUs(),
        fxToBase: 5,
        quote: Quote(
          assetId: 'asset-1',
          unitPrice: Money.fromMajor(200, usd),
          asOf: now,
          fetchedAt: now,
          source: QuoteSource.finnhub,
        ),
      ),
      now: now,
    );

    expect(v.marketValueNative, Money.fromMajor(2000, usd)); // 200 * 10 USD
    expect(v.marketValueBase, Money.fromMajor(10000, brl)); // 2000 * 5
    expect(v.investedBase, Money.fromMajor(5000, brl)); // 1000 USD * 5
  });

  test('foreign holding with no FX is flagged and zeroed in base', () {
    final v = service.valuateHolding(
      ValuationInput(
        holding: holding(currency: usd),
        asset: AssetFactory.stockUs(),
        fxToBase: null,
        quote: Quote(
          assetId: 'asset-1',
          unitPrice: Money.fromMajor(200, usd),
          asOf: now,
          fetchedAt: now,
          source: QuoteSource.finnhub,
        ),
      ),
      now: now,
    );

    expect(v.fxMissing, isTrue);
    expect(v.marketValueBase, const Money.zero(brl));
    expect(v.marketValueNative, Money.fromMajor(2000, usd)); // native kept
  });

  test('no quote (non-cash) falls back to cost and flags stale', () {
    final v = service.valuateHolding(
      ValuationInput(
        holding: holding(),
        asset: AssetFactory.stockBr(),
        fxToBase: 1,
      ),
      now: now,
    );

    expect(v.marketValueBase, Money.fromMajor(1000, brl));
    expect(v.unrealizedPL, const Money.zero(brl));
    expect(v.priceStale, isTrue);
  });

  test('cash is valued at face value and never stale', () {
    final cash = Asset(
      id: 'cash-1',
      userId: 'user-1',
      ticker: 'CASH',
      name: 'Reserva',
      kind: AssetKind.cash,
      market: Market.br,
      currency: brl,
      createdAt: DateTime(2024),
    );
    final v = service.valuateHolding(
      ValuationInput(
        holding: holding(quantity: 1, avgCostMajor: 5000),
        asset: cash,
        fxToBase: 1,
      ),
      now: now,
    );

    expect(v.marketValueBase, Money.fromMajor(5000, brl));
    expect(v.priceStale, isFalse);
  });

  test('an old quote is marked stale', () {
    final v = service.valuateHolding(
      ValuationInput(
        holding: holding(),
        asset: AssetFactory.stockBr(),
        fxToBase: 1,
        quote: Quote(
          assetId: 'asset-1',
          unitPrice: Money.fromMajor(150, brl),
          asOf: DateTime(2024, 5),
          fetchedAt: DateTime(2024, 5, 31, 12),
          source: QuoteSource.brapi,
        ),
      ),
      now: now,
    );

    expect(v.priceStale, isTrue);
  });

  test('fixed income accrues from dated cash flows (CDI)', () {
    final fi = Asset(
      id: 'cdb-1',
      userId: 'user-1',
      ticker: 'CDB',
      name: 'CDB 100% CDI',
      kind: AssetKind.fixedIncome,
      market: Market.br,
      currency: brl,
      createdAt: DateTime(2024),
    );
    final terms = FixedIncomeTerms(
      basis: FixedIncomeBasis.cdi,
      ratePercent: 100,
      cashFlows: [
        FixedIncomeCashFlow(
          date: DateTime(2024),
          amount: Money.fromMajor(1000, brl),
        ),
      ],
      series: [IndexPoint(date: DateTime(2024, 1, 2), rate: 0.04)],
    );

    final v = service.valuateHolding(
      ValuationInput(
        holding: holding(),
        asset: fi,
        fxToBase: 1,
        fixedIncome: terms,
      ),
      now: now,
    );

    // 1000 * (1 + 0.0004 * 1) = 1000.40
    expect(v.marketValueBase, Money.fromMajor(1000.40, brl));
    expect(v.investedBase, Money.fromMajor(1000, brl));
    expect(v.unrealizedPL, Money.fromMajor(0.40, brl));
    expect(v.priceStale, isFalse);
  });

  test('valuatePortfolio aggregates and excludes FX-missing from base', () {
    final portfolio = service.valuatePortfolio(
      [
        ValuationInput(
          holding: holding(),
          asset: AssetFactory.stockBr(),
          fxToBase: 1,
          quote: Quote(
            assetId: 'asset-1',
            unitPrice: Money.fromMajor(150, brl),
            asOf: now,
            fetchedAt: now,
            source: QuoteSource.brapi,
          ),
        ),
        ValuationInput(
          holding: holding(currency: usd),
          asset: AssetFactory.stockUs(),
          fxToBase: null, // excluded from base totals
          quote: Quote(
            assetId: 'asset-2',
            unitPrice: Money.fromMajor(200, usd),
            asOf: now,
            fetchedAt: now,
            source: QuoteSource.finnhub,
          ),
        ),
      ],
      now: now,
    );

    expect(portfolio.totalValueBase, Money.fromMajor(1500, brl));
    expect(portfolio.byCurrency[usd], Money.fromMajor(2000, usd));
    expect(portfolio.holdings, hasLength(2));
  });
}
