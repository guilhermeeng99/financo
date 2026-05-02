import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/project_virtual_monthly_bills_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/bill_factory.dart';

void main() {
  const useCase = ProjectVirtualMonthlyBillsUseCase();

  group('happy path', () {
    test('projects virtuals up to target month for a single chain', () {
      final anchor = BillFactory.monthly(
        id: 'bill-may',
        dueDate: DateTime(2026, 5),
      );

      final result = useCase(
        bills: [anchor],
        targetYear: 2026,
        targetMonth: 8,
      );

      // Expects jun, jul, ago — anchor itself stays as-is (real bill).
      expect(result, hasLength(3));
      expect(result.map((b) => b.dueDate.month), [6, 7, 8]);
      expect(result.every((b) => b.isVirtual), isTrue);
      expect(
        result.every((b) => b.recurrence == BillRecurrence.monthly),
        isTrue,
      );
    });

    test('virtuals copy non-temporal fields from the anchor', () {
      final anchor = BillFactory.monthly(
        id: 'bill-1',
        description: 'Aluguel',
        amount: 2000,
        dueDate: DateTime(2026, 5),
      );

      final result = useCase(
        bills: [anchor],
        targetYear: 2026,
        targetMonth: 6,
      );

      expect(result.single.description, 'Aluguel');
      expect(result.single.amount, 2000);
      expect(result.single.categoryId, anchor.categoryId);
      expect(result.single.type, anchor.type);
    });

    test('clamps day-of-month — Jan 31 → Feb 28 (non-leap)', () {
      final anchor = BillFactory.monthly(
        id: 'bill-jan-31',
        dueDate: DateTime(2026, 1, 31),
      );

      final result = useCase(
        bills: [anchor],
        targetYear: 2026,
        targetMonth: 2,
      );

      expect(result.single.dueDate, DateTime(2026, 2, 28));
    });
  });

  group('chain anchoring', () {
    test('only projects from the tail of the chain', () {
      // mai (parent) → jun (child of mai). The tail is jun.
      final mai = BillFactory.monthly(
        id: 'bill-mai',
        dueDate: DateTime(2026, 5),
      );
      final jun = BillFactory.monthly(
        id: 'bill-jun',
        dueDate: DateTime(2026, 6),
      ).copyWith(parentBillId: 'bill-mai');

      final result = useCase(
        bills: [mai, jun],
        targetYear: 2026,
        targetMonth: 8,
      );

      // Only jul and ago are virtual; jun is real (already in list).
      expect(result.map((b) => b.dueDate.month), [7, 8]);
    });

    test('two independent chains both produce virtuals', () {
      final aluguel = BillFactory.monthly(
        id: 'bill-aluguel',
        description: 'Aluguel',
        amount: 2000,
        dueDate: DateTime(2026, 5),
      );
      final netflix = BillFactory.monthly(
        id: 'bill-netflix',
        description: 'Netflix',
        amount: 50,
        dueDate: DateTime(2026, 5, 15),
      );

      final result = useCase(
        bills: [aluguel, netflix],
        targetYear: 2026,
        targetMonth: 6,
      );

      expect(result.map((b) => b.description).toSet(),
          {'Aluguel', 'Netflix'});
      // One projection per chain for the next month.
      expect(result, hasLength(2));
    });
  });

  group('skip rules', () {
    test('one-shot bills never produce virtuals', () {
      final oneShot = BillFactory.pending(
        dueDate: DateTime(2026, 5),
      );

      final result = useCase(
        bills: [oneShot],
        targetYear: 2026,
        targetMonth: 12,
      );

      expect(result, isEmpty);
    });

    test('returns empty when target month is at or before the anchor', () {
      final anchor = BillFactory.monthly(
        id: 'bill-mai',
        dueDate: DateTime(2026, 5),
      );

      // Target = anchor month → no projection needed.
      expect(
        useCase(bills: [anchor], targetYear: 2026, targetMonth: 5),
        isEmpty,
      );
      // Target = before anchor month → also no projection.
      expect(
        useCase(bills: [anchor], targetYear: 2026, targetMonth: 4),
        isEmpty,
      );
    });

    test('caps projection at 24 months ahead of the anchor', () {
      final anchor = BillFactory.monthly(
        id: 'bill-1',
        dueDate: DateTime(2026, 5),
      );

      // Asking for 5 years ahead → still capped at 24.
      final result = useCase(
        bills: [anchor],
        targetYear: 2031,
        targetMonth: 5,
      );

      expect(result, hasLength(24));
    });

    test('empty input returns empty', () {
      expect(
        useCase(bills: const [], targetYear: 2026, targetMonth: 5),
        isEmpty,
      );
    });
  });
}
