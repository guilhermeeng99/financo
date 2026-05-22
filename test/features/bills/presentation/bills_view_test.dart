import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/entities/bill_match_candidate.dart';
import 'package:financo/features/bills/presentation/bills_view.dart';
import 'package:financo/features/bills/presentation/widgets/bills_type_pills.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/bill_factory.dart';

void main() {
  group('filterBillsForMonth', () {
    test('keeps bills due in the selected month', () {
      final inApril = BillFactory.pending(
        id: 'a',
        dueDate: DateTime(2026, 4, 15),
      );
      final result = filterBillsForMonth([inApril], year: 2026, month: 4);
      expect(result, [inApril]);
    });

    test('carries over real pending bills due before the month', () {
      final overdueMarch = BillFactory.pending(
        id: 'm',
        dueDate: DateTime(2026, 3, 10),
      );
      final result = filterBillsForMonth([overdueMarch], year: 2026, month: 4);
      expect(result, [overdueMarch]);
    });

    test('does not carry over virtual bills', () {
      final virtualMarch = BillFactory.pending(
        id: '',
        dueDate: DateTime(2026, 3, 10),
      );
      final result = filterBillsForMonth([virtualMarch], year: 2026, month: 4);
      expect(result, isEmpty);
    });

    test('does not carry over paid bills from earlier months', () {
      final paidMarch = BillFactory.paid(dueDate: DateTime(2026, 3));
      final result = filterBillsForMonth([paidMarch], year: 2026, month: 4);
      expect(result, isEmpty);
    });
  });

  group('filterBillsByType', () {
    final payable = BillFactory.pending(id: 'p');
    final receivable = BillFactory.receivable(id: 'r');
    final all = [payable, receivable];

    test('all → unchanged', () {
      expect(filterBillsByType(all, BillsTypeFilter.all), all);
    });
    test('payable only', () {
      expect(filterBillsByType(all, BillsTypeFilter.payable), [payable]);
    });
    test('receivable only', () {
      expect(filterBillsByType(all, BillsTypeFilter.receivable), [receivable]);
    });
  });

  group('isBillPayable', () {
    final now = DateTime(2026, 4, 15);

    test('false for virtual bills', () {
      final virtual = BillFactory.pending(id: '', dueDate: DateTime(2026, 4));
      expect(isBillPayable(virtual, now: now), isFalse);
    });

    test('false for paid bills', () {
      expect(isBillPayable(BillFactory.paid(), now: now), isFalse);
    });

    test('false for bills due in a future month', () {
      final future = BillFactory.pending(dueDate: DateTime(2026, 6));
      expect(isBillPayable(future, now: now), isFalse);
    });

    test('true for a real pending bill due this month or earlier', () {
      final due = BillFactory.pending(dueDate: DateTime(2026, 4, 10));
      expect(isBillPayable(due, now: now), isTrue);
    });
  });

  group('BillGroups.fromBills', () {
    test('splits by status and sorts paid most-recent first', () {
      final overdue = BillFactory.overdue(id: 'o');
      final upcoming = BillFactory.pending(
        id: 'u',
        dueDate: DateTime.now().add(const Duration(days: 20)),
      );
      final paidOld = BillFactory.paid(id: 'p-old')
          .copyWith(paidAt: DateTime(2026, 4));
      final paidNew = BillFactory.paid(id: 'p-new')
          .copyWith(paidAt: DateTime(2026, 4, 20));

      final groups = BillGroups.fromBills([
        upcoming,
        paidOld,
        overdue,
        paidNew,
      ]);

      expect(groups.overdue, [overdue]);
      expect(groups.upcoming, [upcoming]);
      expect(groups.paid.map((b) => b.id), ['p-new', 'p-old']);
      expect(groups.isFullyEmpty, isFalse);
    });

    test('isFullyEmpty when there are no bills', () {
      expect(BillGroups.fromBills(const []).isFullyEmpty, isTrue);
    });
  });

  group('filterMatchCandidates', () {
    BillMatchCandidate candidateFor(BillEntity bill) =>
        BillMatchCandidate(bill: bill, candidates: const []);

    final payable = candidateFor(BillFactory.pending(id: 'p'));
    final receivable = candidateFor(BillFactory.receivable(id: 'r'));

    test('drops candidates whose bill is not in the visible set', () {
      final result = filterMatchCandidates(
        [payable, receivable],
        BillsTypeFilter.all,
        {'p'},
      );
      expect(result, [payable]);
    });

    test('mirrors the type filter', () {
      final result = filterMatchCandidates(
        [payable, receivable],
        BillsTypeFilter.receivable,
        {'p', 'r'},
      );
      expect(result, [receivable]);
    });
  });
}
