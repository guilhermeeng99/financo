import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/services/recurring_transaction_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/transaction_factory.dart';

void main() {
  group('buildRecurringTransactions', () {
    test('splits installment total and appends installment markers', () {
      final template = TransactionFactory.expense(
        amount: 100,
        description: 'Notebook',
        recurrence: TransactionRecurrence.installment,
      );

      final transactions = buildRecurringTransactions(
        template: template,
        now: DateTime(2026, 6, 10),
        installmentCount: 3,
      );

      expect(transactions, hasLength(3));
      expect(transactions.map((tx) => tx.amount), [33.34, 33.33, 33.33]);
      expect(
        transactions.map((tx) => tx.description),
        ['Notebook 1/3', 'Notebook 2/3', 'Notebook 3/3'],
      );
      expect(
        transactions.skip(1).every((tx) => tx.isPending),
        isTrue,
      );
    });

    test('fixed recurrence materializes only the next 12 months', () {
      final template = TransactionFactory.expense(
        recurrence: TransactionRecurrence.fixed,
        recurrenceIntervalMonths: 3,
        date: DateTime(2026, 1, 31),
      );

      final transactions = buildRecurringTransactions(
        template: template,
        now: DateTime(2026),
        installmentCount: 2,
      );

      expect(transactions, hasLength(5));
      expect(
        transactions.map((tx) => tx.dueDate),
        [
          DateTime(2026, 1, 31),
          DateTime(2026, 4, 30),
          DateTime(2026, 7, 31),
          DateTime(2026, 10, 31),
          DateTime(2027, 1, 31),
        ],
      );
    });
  });
}
