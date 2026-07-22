import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/holding.dart';

/// Derives [Holding]s from transactions using the weighted-average method.
/// Pure and deterministic. See `docs/specs/holdings.md`.
class HoldingCalculator {
  /// Creates the calculator.
  const HoldingCalculator();

  /// Groups transactions by (asset, institution) and derives one holding each.
  List<Holding> derive(List<AssetTransaction> transactions) {
    final groups = <String, List<AssetTransaction>>{};
    for (final tx in transactions) {
      groups.putIfAbsent('${tx.assetId}|${tx.institutionId}', () => []).add(tx);
    }
    return groups.values.map(_deriveOne).toList();
  }

  Holding _deriveOne(List<AssetTransaction> transactions) {
    final sorted = [...transactions]..sort(compareTransactionsOldestFirst);
    final currency = sorted.first.unitPrice.currency;

    var quantity = 0.0;
    var avgCostMinor = 0; // per-unit minor units
    var realizedMinor = 0;
    var dividendsMinor = 0;

    for (final tx in sorted) {
      switch (tx.kind) {
        case TransactionKind.buy:
          final oldTotal = avgCostMinor * quantity;
          final addedTotal =
              tx.unitPrice.minorUnits * tx.quantity + tx.fees.minorUnits;
          final newQuantity = quantity + tx.quantity;
          avgCostMinor = newQuantity == 0
              ? 0
              : ((oldTotal + addedTotal) / newQuantity).round();
          quantity = newQuantity;
        case TransactionKind.sell:
          realizedMinor +=
              ((tx.unitPrice.minorUnits - avgCostMinor) * tx.quantity).round() -
              tx.fees.minorUnits;
          quantity -= tx.quantity;
          if (quantity < 0) quantity = 0;
        case TransactionKind.dividend:
          dividendsMinor += tx.amount.minorUnits;
      }
    }

    return Holding(
      assetId: sorted.first.assetId,
      institutionId: sorted.first.institutionId,
      quantity: quantity,
      avgCost: Money(avgCostMinor, currency),
      realizedPL: Money(realizedMinor, currency),
      dividends: Money(dividendsMinor, currency),
    );
  }
}
