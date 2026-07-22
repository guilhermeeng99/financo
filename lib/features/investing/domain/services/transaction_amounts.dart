import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';

/// The money rule shared by the transaction form and the CSV importer: a
/// dividend carries only its [amount] (quantity 0, no unit price), while a
/// buy/sell derives `amount = unitPrice * quantity`. Centralized in the domain
/// so the two entry points can't drift. See
/// `docs/specs/investing_transactions.md`.
///
/// Example:
/// ```dart
/// final m = resolveTransactionAmounts(
///   kind: TransactionKind.buy, quantity: 2,
///   unitPrice: Money.fromMajor(100, Currency.usd),
///   amount: const Money.zero(Currency.usd), currency: Currency.usd,
/// ); // m.amount == US$200
/// ```
({double quantity, Money unitPrice, Money amount}) resolveTransactionAmounts({
  required TransactionKind kind,
  required double quantity,
  required Money unitPrice,
  required Money amount,
  required Currency currency,
}) {
  if (kind == TransactionKind.dividend) {
    return (quantity: 0, unitPrice: Money.zero(currency), amount: amount);
  }
  return (
    quantity: quantity,
    unitPrice: unitPrice,
    amount: unitPrice * quantity,
  );
}
