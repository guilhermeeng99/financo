import 'dart:math';

import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/fixed_income_terms.dart';
import 'package:financo/features/investing/domain/entities/holding.dart';
import 'package:financo/features/investing/domain/entities/holding_valuation.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';

/// One holding plus the data needed to price it.
class ValuationInput {
  /// Creates an input row.
  const ValuationInput({
    required this.holding,
    required this.asset,
    required this.fxToBase,
    this.quote,
    this.fixedIncome,
  });

  /// The position.
  final Holding holding;

  /// Its asset (for currency/class).
  final Asset asset;

  /// Latest quote, or null when unavailable.
  final Quote? quote;

  /// Accrual terms for fixed income; null for market-priced assets. Used only
  /// when [quote] is null, to value the holding by index/rate accrual instead
  /// of falling back to cost.
  final FixedIncomeTerms? fixedIncome;

  /// Multiplier converting the asset's currency to the base currency (1.0 when
  /// already in base). **Null** means the rate is unavailable for a foreign
  /// holding — it's then excluded from totals and flagged, never valued at a
  /// bogus 1:1. See `docs/specs/valuation.md`.
  final double? fxToBase;
}

/// Pure valuation math. Turns holdings + quotes + FX into money figures
/// consolidated to the base currency. See `docs/specs/valuation.md`.
class ValuationService {
  /// Creates the service.
  const ValuationService();

  /// A quote older than this is considered stale.
  static const Duration defaultStaleThreshold = Duration(hours: 1);

  /// Values a single holding.
  HoldingValuation valuateHolding(
    ValuationInput input, {
    required DateTime now,
    Currency base = Currency.brl,
    Duration staleThreshold = defaultStaleThreshold,
  }) {
    final holding = input.holding;
    final fx = input.fxToBase;

    // A foreign holding with no FX rate can't be consolidated to base — exclude
    // it (zeroed + flagged) instead of valuing at a bogus 1:1. valuatePortfolio
    // skips it from totals; the UI warns. See `docs/specs/valuation.md`.
    if (input.asset.currency != base && fx == null) {
      return _unvaluable(input, base);
    }
    final rate = fx ?? 1.0;

    // Fixed income with no market quote is valued from its cash flows (deposits
    // and redemptions), not the share/average-cost model — partial redemptions
    // make quantity meaningless. See `docs/specs/valuation.md` §2.
    final terms = input.fixedIncome;
    if (input.quote == null && terms != null && terms.cashFlows.isNotEmpty) {
      return _valuateFixedIncome(input, terms, rate, now, base);
    }

    final investedBase = _toBase(holding.investedCost, rate, base);
    final (marketValueBase, marketValueNative, unrealizedPL, stale) = _price(
      input,
      investedBase,
      rate,
      now,
      base,
      staleThreshold,
    );

    final realizedBase = _toBase(holding.realizedPL, rate, base);
    final dividendsBase = _toBase(holding.dividends, rate, base);
    final totalPL = unrealizedPL + realizedBase + dividendsBase;
    final returnPct = investedBase.minorUnits == 0
        ? 0.0
        : unrealizedPL.minorUnits / investedBase.minorUnits;

    final dayChangeBase = _dayChange(input.quote, holding.quantity, rate, base);

    return HoldingValuation(
      assetId: holding.assetId,
      institutionId: holding.institutionId,
      assetKind: input.asset.kind,
      quantity: holding.quantity,
      marketValueBase: marketValueBase,
      marketValueNative: marketValueNative,
      investedBase: investedBase,
      unrealizedPL: unrealizedPL,
      totalPL: totalPL,
      returnPct: returnPct,
      dayChangeBase: dayChangeBase,
      priceStale: stale,
    );
  }

  /// A foreign holding that can't be priced in base (no FX): every base figure
  /// zeroed and `fxMissing` set, so totals exclude it and the UI can warn. The
  /// native value is still known (FX only blocks the BRL conversion), so it is
  /// kept for display.
  HoldingValuation _unvaluable(ValuationInput input, Currency base) {
    final quote = input.quote;
    final marketValueNative = quote != null
        ? Money(
            (quote.unitPrice.minorUnits * input.holding.quantity).round(),
            quote.unitPrice.currency,
          )
        : input.holding.investedCost;
    return HoldingValuation(
      assetId: input.holding.assetId,
      institutionId: input.holding.institutionId,
      assetKind: input.asset.kind,
      quantity: input.holding.quantity,
      marketValueBase: Money.zero(base),
      marketValueNative: marketValueNative,
      investedBase: Money.zero(base),
      unrealizedPL: Money.zero(base),
      totalPL: Money.zero(base),
      returnPct: 0,
      dayChangeBase: Money.zero(base),
      priceStale: true,
      fxMissing: true,
    );
  }

  /// Values the whole portfolio and aggregates allocations.
  PortfolioValuation valuatePortfolio(
    List<ValuationInput> inputs, {
    required DateTime now,
    Currency base = Currency.brl,
    Duration staleThreshold = defaultStaleThreshold,
  }) {
    final valuations = [
      for (final input in inputs)
        valuateHolding(
          input,
          now: now,
          base: base,
          staleThreshold: staleThreshold,
        ),
    ];

    return PortfolioValuation.fromHoldings(valuations, base);
  }

  /// `(marketValueBase, marketValueNative, unrealizedPL, stale)` for a
  /// market-priced holding: from a live quote if present, else cost basis
  /// (flagged stale). Fixed income is valued separately in
  /// [_valuateFixedIncome].
  (Money, Money, Money, bool) _price(
    ValuationInput input,
    Money investedBase,
    double rate,
    DateTime now,
    Currency base,
    Duration staleThreshold,
  ) {
    final holding = input.holding;
    final quote = input.quote;

    if (quote != null) {
      final marketNative = Money(
        (quote.unitPrice.minorUnits * holding.quantity).round(),
        quote.unitPrice.currency,
      );
      final marketValueBase = _toBase(marketNative, rate, base);
      final stale = now.difference(quote.fetchedAt) > staleThreshold;
      return (
        marketValueBase,
        marketNative,
        marketValueBase - investedBase,
        stale,
      );
    }
    // No quote: fall back to cost. For cash the face value *is* the current
    // value, so it's authoritative and never stale (no source prices it, and it
    // shouldn't trigger the "prices outdated" warning); a market asset awaiting
    // a quote shows cost as a stale stand-in. Native cost carries the holding's
    // own currency so the UI can still show the native figure.
    final costIsStale = input.asset.kind != AssetKind.cash;
    return (investedBase, holding.investedCost, Money.zero(base), costIsStale);
  }

  /// Values a fixed-income holding from its dated cash flows. Both market value
  /// and invested basis come from the flows (deposits − redemptions), so the
  /// share/average-cost model and any "realized P/L" from sell transactions are
  /// bypassed. By linearity of daily accrual, the value today is the sum of
  /// each flow grown from its date: `Σ amount × accrualFactor(date → now)`.
  HoldingValuation _valuateFixedIncome(
    ValuationInput input,
    FixedIncomeTerms terms,
    double rate,
    DateTime now,
    Currency base,
  ) {
    final currency = input.asset.currency;
    var marketNative = Money.zero(currency);
    var investedNative = Money.zero(currency);
    for (final flow in terms.cashFlows) {
      marketNative += flow.amount * _accrualFactor(terms, flow.date, now);
      investedNative += flow.amount;
    }

    final marketValueBase = _toBase(marketNative, rate, base);
    final investedBase = _toBase(investedNative, rate, base);
    final unrealizedPL = marketValueBase - investedBase;
    final returnPct = investedBase.minorUnits == 0
        ? 0.0
        : unrealizedPL.minorUnits / investedBase.minorUnits;

    return HoldingValuation(
      assetId: input.holding.assetId,
      institutionId: input.holding.institutionId,
      assetKind: input.asset.kind,
      quantity: input.holding.quantity,
      marketValueBase: marketValueBase,
      marketValueNative: marketNative,
      investedBase: investedBase,
      unrealizedPL: unrealizedPL,
      totalPL: unrealizedPL,
      returnPct: returnPct,
      dayChangeBase: Money.zero(base),
      priceStale: false,
    );
  }

  Money _dayChange(Quote? quote, double quantity, double fx, Currency base) {
    final previousClose = quote?.previousClose;
    if (quote == null || previousClose == null) return Money.zero(base);
    final deltaNative = Money(
      ((quote.unitPrice.minorUnits - previousClose.minorUnits) * quantity)
          .round(),
      quote.unitPrice.currency,
    );
    return _toBase(deltaNative, fx, base);
  }

  Money _toBase(Money amount, double fx, Currency base) {
    if (amount.currency == base) return Money(amount.minorUnits, base);
    return Money((amount.minorUnits * fx).round(), base);
  }

  /// Multiplier applied to one cash flow to reach its current value, accruing
  /// from [since]. See `docs/specs/valuation.md` §2.
  double _accrualFactor(FixedIncomeTerms terms, DateTime since, DateTime now) {
    return switch (terms.basis) {
      FixedIncomeBasis.cdi ||
      FixedIncomeBasis.selic => _indexedFactor(terms, since),
      FixedIncomeBasis.prefixed => _prefixedFactor(
        terms.ratePercent,
        since,
        now,
      ),
      FixedIncomeBasis.ipca => _ipcaFactor(terms, since, now),
    };
  }

  /// CDI/Selic: compound each daily rate (since [since]) scaled by the
  /// contracted percentage. `110% of CDI` → `∏(1 + dailyCdi * 1.10)`.
  double _indexedFactor(FixedIncomeTerms terms, DateTime since) {
    final multiplier = terms.ratePercent / 100;
    var factor = 1.0;
    for (final point in terms.series) {
      if (point.date.isBefore(since)) continue;
      factor *= 1 + (point.rate / 100) * multiplier;
    }
    return factor;
  }

  /// Prefixed: annual rate compounded over business days (252-day convention).
  double _prefixedFactor(double annualRate, DateTime since, DateTime now) {
    final days = _businessDaysBetween(since, now);
    return pow(1 + annualRate / 100, days / 252).toDouble();
  }

  /// IPCA+: accumulated monthly inflation (since [since]) times the spread over
  /// business days.
  double _ipcaFactor(FixedIncomeTerms terms, DateTime since, DateTime now) {
    var inflation = 1.0;
    for (final point in terms.series) {
      if (point.date.isBefore(since)) continue;
      inflation *= 1 + point.rate / 100;
    }
    final days = _businessDaysBetween(since, now);
    final spread = pow(1 + terms.ratePercent / 100, days / 252).toDouble();
    return inflation * spread;
  }

  /// Weekday count in `(from, to]`. Approximation: ignores bank holidays, which
  /// the BCB series already excludes for index-based bonds; only prefixed/IPCA+
  /// spreads are slightly affected.
  int _businessDaysBetween(DateTime from, DateTime to) {
    if (!to.isAfter(from)) return 0;
    var count = 0;
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (cursor.isBefore(end)) {
      cursor = cursor.add(const Duration(days: 1));
      final weekday = cursor.weekday;
      if (weekday != DateTime.saturday && weekday != DateTime.sunday) count++;
    }
    return count;
  }
}
