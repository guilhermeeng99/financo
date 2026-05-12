import 'package:financo/features/budgets/domain/entities/budget_overview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/budget_factory.dart';

void main() {
  group('BudgetOverview', () {
    BudgetOverview build(double spent, {double amount = 1000}) =>
        BudgetOverview(
          budget: BudgetFactory.make(amount: amount),
          categoryName: 'Food',
          categoryIcon: 1,
          categoryColor: 1,
          spent: spent,
        );

    test('safe when spend is below 75%', () {
      expect(build(0).status, BudgetStatus.safe);
      expect(build(749).status, BudgetStatus.safe);
    });

    test('warning at 75% and below 100%', () {
      expect(build(750).status, BudgetStatus.warning);
      expect(build(999.99).status, BudgetStatus.warning);
    });

    test('exceeded at 100% and beyond', () {
      expect(build(1000).status, BudgetStatus.exceeded);
      expect(build(1500).status, BudgetStatus.exceeded);
    });

    test('remaining clamps at zero when overspent', () {
      expect(build(1500).remaining, 0);
    });

    test('overspent reports the delta when above cap', () {
      expect(build(1500).overspent, 500);
    });

    test('overspent is zero when below cap', () {
      expect(build(800).overspent, 0);
    });

    test('percentage is uncapped and reports beyond 100%', () {
      expect(build(1500).percentage, closeTo(1.5, 0.0001));
    });

    test('percentage is zero when amount is zero (defensive)', () {
      expect(build(100, amount: 0).percentage, 0);
    });
  });
}
