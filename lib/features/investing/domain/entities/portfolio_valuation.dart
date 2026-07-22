import 'package:equatable/equatable.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/holding_valuation.dart';

/// The whole portfolio, consolidated to the base currency.
class PortfolioValuation extends Equatable {
  /// Creates a portfolio valuation.
  const PortfolioValuation({
    required this.totalValueBase,
    required this.totalInvestedBase,
    required this.totalUnrealizedPL,
    required this.totalDayChangeBase,
    required this.totalReturnPct,
    required this.byClass,
    required this.byInstitution,
    required this.byCurrency,
    required this.holdings,
  });

  /// An empty portfolio in [base] currency.
  factory PortfolioValuation.empty([Currency base = Currency.brl]) {
    return PortfolioValuation(
      totalValueBase: Money.zero(base),
      totalInvestedBase: Money.zero(base),
      totalUnrealizedPL: Money.zero(base),
      totalDayChangeBase: Money.zero(base),
      totalReturnPct: 0,
      byClass: const {},
      byInstitution: const {},
      byCurrency: const {},
      holdings: const [],
    );
  }

  /// Aggregates totals and allocations from already-valued [holdings].
  /// FX-missing holdings are excluded from the base-consolidated totals and
  /// allocations (they're still kept in [holdings] so the UI can list them with
  /// a warning), but they DO contribute to [byCurrency], which is a
  /// native-currency subtotal that needs no FX conversion. Single source of the
  /// aggregation math, reused by the valuation service and by [forInstitution].
  factory PortfolioValuation.fromHoldings(
    List<HoldingValuation> holdings,
    Currency base,
  ) {
    var totalValue = Money.zero(base);
    var totalInvested = Money.zero(base);
    var totalUnrealized = Money.zero(base);
    var totalDay = Money.zero(base);
    final byClass = <AssetKind, Money>{};
    final byInstitution = <String, Money>{};
    final byCurrency = <Currency, Money>{};

    for (final v in holdings) {
      // The native-currency subtotal needs no FX conversion, so a foreign
      // holding still belongs in its own-currency bucket even when its rate to
      // base is missing — only the base totals/allocations below must skip it.
      final native = v.marketValueNative;
      byCurrency[native.currency] =
          (byCurrency[native.currency] ?? Money.zero(native.currency)) + native;

      if (v.fxMissing) continue;
      totalValue += v.marketValueBase;
      totalInvested += v.investedBase;
      totalUnrealized += v.unrealizedPL;
      totalDay += v.dayChangeBase;
      byClass[v.assetKind] =
          (byClass[v.assetKind] ?? Money.zero(base)) + v.marketValueBase;
      byInstitution[v.institutionId] =
          (byInstitution[v.institutionId] ?? Money.zero(base)) +
          v.marketValueBase;
    }

    final totalReturnPct = totalInvested.minorUnits == 0
        ? 0.0
        : totalUnrealized.minorUnits / totalInvested.minorUnits;

    return PortfolioValuation(
      totalValueBase: totalValue,
      totalInvestedBase: totalInvested,
      totalUnrealizedPL: totalUnrealized,
      totalDayChangeBase: totalDay,
      totalReturnPct: totalReturnPct,
      byClass: byClass,
      byInstitution: byInstitution,
      byCurrency: byCurrency,
      holdings: holdings,
    );
  }

  /// Total current value.
  final Money totalValueBase;

  /// Total cost basis.
  final Money totalInvestedBase;

  /// Total unrealized P/L.
  final Money totalUnrealizedPL;

  /// Total day change.
  final Money totalDayChangeBase;

  /// Overall unrealized return ratio.
  final double totalReturnPct;

  /// Value allocation by asset class.
  final Map<AssetKind, Money> byClass;

  /// Value allocation by institution id.
  final Map<String, Money> byInstitution;

  /// Market value grouped by the holding's **native** currency
  /// (e.g. `{usd: …}`), each summed in that currency. Lets the overview show
  /// the dollar subtotal of dollar-denominated holdings, not only the
  /// consolidated BRL figure.
  final Map<Currency, Money> byCurrency;

  /// Per-holding valuations.
  final List<HoldingValuation> holdings;

  /// This portfolio narrowed to one institution, re-aggregating totals and
  /// allocations from the matching holdings. `null` returns this unchanged.
  PortfolioValuation forInstitution(String? institutionId) {
    if (institutionId == null) return this;
    final base = totalValueBase.currency;
    final subset = [
      for (final h in holdings)
        if (h.institutionId == institutionId) h,
    ];
    return PortfolioValuation.fromHoldings(subset, base);
  }

  @override
  List<Object?> get props => [
    totalValueBase,
    totalInvestedBase,
    totalUnrealizedPL,
    totalDayChangeBase,
    totalReturnPct,
    byClass,
    byInstitution,
    byCurrency,
    holdings,
  ];
}
