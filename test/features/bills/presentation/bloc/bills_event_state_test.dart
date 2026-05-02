import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/bill_factory.dart';

void main() {
  group('BillsLoaded.actionablePendingCount', () {
    // We anchor every test on a freshly-computed "today" so the test stays
    // deterministic regardless of when it runs — `BillEntity.isOverdue`
    // and `isDueToday` use `DateTime.now()` internally, so the dueDate
    // inputs must be relative to it.
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    test('is 0 when there are no bills', () {
      const state = BillsLoaded([]);
      expect(state.actionablePendingCount, 0);
    });

    test('counts a pending overdue bill', () {
      final state = BillsLoaded([BillFactory.pending(dueDate: yesterday)]);
      expect(state.actionablePendingCount, 1);
    });

    test('counts a pending bill due today', () {
      final state = BillsLoaded([BillFactory.pending(dueDate: today)]);
      expect(state.actionablePendingCount, 1);
    });

    test('does not count a pending upcoming bill', () {
      final state = BillsLoaded([BillFactory.pending(dueDate: tomorrow)]);
      expect(state.actionablePendingCount, 0);
    });

    test('does not count a paid bill even if dueDate is in the past', () {
      final state = BillsLoaded([BillFactory.paid(dueDate: yesterday)]);
      expect(state.actionablePendingCount, 0);
    });

    test('counts receivable bills the same way as payable', () {
      final state = BillsLoaded([
        BillFactory.pending(
          id: 'r-overdue',
          type: BillType.receivable,
          dueDate: yesterday,
        ),
        BillFactory.pending(
          id: 'r-today',
          type: BillType.receivable,
          dueDate: today,
        ),
      ]);
      expect(state.actionablePendingCount, 2);
    });

    test('mixed list — sums overdue + today, ignores upcoming + paid', () {
      final state = BillsLoaded([
        BillFactory.pending(id: 'o1', dueDate: yesterday),
        BillFactory.pending(id: 'o2', dueDate: today.subtract(
          const Duration(days: 10),
        )),
        BillFactory.pending(id: 't1', dueDate: today),
        BillFactory.pending(id: 'u1', dueDate: tomorrow),
        BillFactory.pending(id: 'u2', dueDate: nextWeek),
        BillFactory.paid(id: 'p1', dueDate: yesterday),
      ]);
      expect(state.actionablePendingCount, 3);
    });
  });
}
