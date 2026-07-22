import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/services/transaction_amounts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usd = Currency.usd;

  test('buy derives amount = unitPrice * quantity', () {
    final r = resolveTransactionAmounts(
      kind: TransactionKind.buy,
      quantity: 2,
      unitPrice: Money.fromMajor(100, usd),
      amount: const Money.zero(usd),
      currency: usd,
    );
    expect(r.quantity, 2);
    expect(r.unitPrice, Money.fromMajor(100, usd));
    expect(r.amount, Money.fromMajor(200, usd));
  });

  test('sell derives amount = unitPrice * quantity', () {
    final r = resolveTransactionAmounts(
      kind: TransactionKind.sell,
      quantity: 3,
      unitPrice: Money.fromMajor(50, usd),
      amount: const Money.zero(usd),
      currency: usd,
    );
    expect(r.amount, Money.fromMajor(150, usd));
  });

  test('dividend keeps its amount, zeroes quantity and unit price', () {
    final r = resolveTransactionAmounts(
      kind: TransactionKind.dividend,
      quantity: 5,
      unitPrice: Money.fromMajor(999, usd),
      amount: Money.fromMajor(42, usd),
      currency: usd,
    );
    expect(r.quantity, 0);
    expect(r.unitPrice, const Money.zero(usd));
    expect(r.amount, Money.fromMajor(42, usd));
  });
}
