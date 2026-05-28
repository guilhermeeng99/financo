import 'package:financo/features/accounts/domain/period_totals.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/transaction_factory.dart';

void main() {
  test('sums income and expenses by leg type', () {
    final totals = sumPeriodTotals([
      TransactionFactory.income(),
      TransactionFactory.expense(),
      TransactionFactory.expense(amount: 45),
    ]);

    expect(totals.income, 3000);
    expect(totals.expenses, 195);
  });

  test('returns zeros for an empty period', () {
    final totals = sumPeriodTotals(const []);

    expect(totals.income, 0);
    expect(totals.expenses, 0);
  });

  test('counts each transfer leg by its own type', () {
    final pair = TransactionFactory.transfer();

    final totals = sumPeriodTotals([pair.expense, pair.income]);

    expect(totals.income, 500);
    expect(totals.expenses, 500);
  });
}
