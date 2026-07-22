import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/entities/fixed_income_terms.dart';

/// Maps a fixed-income holding's transactions to dated cash flows: a buy is a
/// deposit (aplicação, positive), a sell is a redemption (resgate, negative).
/// Dividends are ignored — fixed income accrues by index, not payouts.
///
/// The valuation accrues each flow from its own date, so deposits and **partial
/// redemptions** are both handled natively (no FIFO, no average-cost). Returns
/// flows ordered oldest-first; empty when there is nothing to accrue.
List<FixedIncomeCashFlow> buildFixedIncomeCashFlows(
  List<AssetTransaction> transactions,
) {
  final flows = <FixedIncomeCashFlow>[];
  for (final tx in transactions) {
    final amount = switch (tx.kind) {
      TransactionKind.buy => tx.amount,
      TransactionKind.sell => Money(-tx.amount.minorUnits, tx.amount.currency),
      TransactionKind.dividend => null,
    };
    if (amount == null) continue;
    flows.add(FixedIncomeCashFlow(date: tx.date, amount: amount));
  }
  flows.sort((a, b) => a.date.compareTo(b.date));
  return flows;
}
