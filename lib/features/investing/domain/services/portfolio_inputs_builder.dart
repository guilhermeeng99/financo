import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/fixed_income_terms.dart';
import 'package:financo/features/investing/domain/entities/holding.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';
import 'package:financo/features/investing/domain/services/fixed_income_cash_flows.dart';
import 'package:financo/features/investing/domain/services/fixed_income_metadata.dart';
import 'package:financo/features/investing/domain/services/valuation_service.dart';

/// Turns local holdings + cached quotes + FX + fetched index series into the
/// [ValuationInput]s the [ValuationService] consumes. Pure and deterministic,
/// so the cubits only orchestrate (streams, refresh) while this builds. See
/// `docs/specs/valuation.md`.
class PortfolioInputsBuilder {
  /// Creates the builder.
  const PortfolioInputsBuilder();

  /// One [ValuationInput] per holding whose asset is known, priced with its
  /// cached quote, FX (a currency absent from [fxToBaseRates] means its rate is
  /// not loaded, so holdings in it are excluded) and, for fixed income, dated
  /// accrual terms. [fxToBaseRates] maps each foreign currency to its rate into
  /// the base currency; BRL is always 1.0 and need not be present.
  List<ValuationInput> build({
    required List<Holding> holdings,
    required Map<String, Asset> assetsById,
    required List<AssetTransaction> transactions,
    required Map<String, Quote> quotesById,
    required Map<EconomicIndex, List<IndexPoint>> indexSeries,
    required Map<Currency, double> fxToBaseRates,
  }) {
    final cashFlowsByHolding = _cashFlowsByHolding(transactions);
    return [
      for (final holding in holdings)
        if (assetsById[holding.assetId] case final asset?)
          ValuationInput(
            holding: holding,
            asset: asset,
            quote: quotesById[holding.assetId],
            fxToBase: asset.currency == Currency.brl
                ? 1.0
                : fxToBaseRates[asset.currency],
            fixedIncome: _termsFor(
              asset,
              indexSeries,
              cashFlowsByHolding[_holdingKey(
                holding.assetId,
                holding.institutionId,
              )],
            ),
          ),
    ];
  }

  /// Asset ids to fetch market data for: any open market position, plus every
  /// fixed-income asset that has transactions (its CDI/Selic/IPCA series is
  /// needed even when buys and redemptions net its quantity to zero).
  Set<String> heldAssetIds(
    List<Holding> holdings,
    List<Asset> assets,
    List<AssetTransaction> transactions,
  ) {
    final assetsById = {for (final a in assets) a.id: a};
    final ids = <String>{
      for (final h in holdings)
        if (h.quantity > 0) h.assetId,
    };
    for (final tx in transactions) {
      if (assetsById[tx.assetId]?.kind == AssetKind.fixedIncome) {
        ids.add(tx.assetId);
      }
    }
    return ids;
  }

  /// The earliest purchase date per economic index across [heldAssets], so each
  /// index series is fetched once from the oldest position that needs it.
  Map<EconomicIndex, DateTime> earliestIndexDates(
    List<Asset> heldAssets,
    List<AssetTransaction> transactions,
  ) {
    final earliestByIndex = <EconomicIndex, DateTime>{};
    for (final asset in heldAssets) {
      final index = _indexFor(asset);
      final purchase = _earliestBuyForAsset(asset.id, transactions);
      if (index == null || purchase == null) continue;
      final current = earliestByIndex[index];
      if (current == null || purchase.isBefore(current)) {
        earliestByIndex[index] = purchase;
      }
    }
    return earliestByIndex;
  }

  /// The BCB index a fixed-income asset accrues against, or null otherwise.
  EconomicIndex? _indexFor(Asset asset) {
    if (asset.kind != AssetKind.fixedIncome) return null;
    return FixedIncomeMetadata.read(asset)?.$1.economicIndex;
  }

  /// Accrual terms for a fixed-income holding, or null when not applicable.
  FixedIncomeTerms? _termsFor(
    Asset asset,
    Map<EconomicIndex, List<IndexPoint>> indexSeries,
    List<FixedIncomeCashFlow>? cashFlows,
  ) {
    if (asset.kind != AssetKind.fixedIncome) return null;
    final parsed = FixedIncomeMetadata.read(asset);
    if (parsed == null || cashFlows == null || cashFlows.isEmpty) return null;
    final (basis, rate) = parsed;
    final index = basis.economicIndex;
    return FixedIncomeTerms(
      basis: basis,
      ratePercent: rate,
      cashFlows: cashFlows,
      series: index == null ? const [] : (indexSeries[index] ?? const []),
    );
  }

  /// Fixed-income cash flows per holding key (`assetId|institutionId`):
  /// deposits (buys) and redemptions (sells), each dated, so every flow accrues
  /// from its own date and partial redemptions are handled natively.
  Map<String, List<FixedIncomeCashFlow>> _cashFlowsByHolding(
    List<AssetTransaction> txns,
  ) {
    final byKey = <String, List<AssetTransaction>>{};
    for (final tx in txns) {
      byKey
          .putIfAbsent(_holdingKey(tx.assetId, tx.institutionId), () => [])
          .add(tx);
    }
    final result = <String, List<FixedIncomeCashFlow>>{};
    for (final entry in byKey.entries) {
      final flows = buildFixedIncomeCashFlows(entry.value);
      if (flows.isNotEmpty) result[entry.key] = flows;
    }
    return result;
  }

  DateTime? _earliestBuyForAsset(String assetId, List<AssetTransaction> txns) {
    DateTime? earliest;
    for (final tx in txns) {
      if (tx.kind != TransactionKind.buy || tx.assetId != assetId) continue;
      if (earliest == null || tx.date.isBefore(earliest)) earliest = tx.date;
    }
    return earliest;
  }

  String _holdingKey(String assetId, String institutionId) =>
      '$assetId|$institutionId';
}
