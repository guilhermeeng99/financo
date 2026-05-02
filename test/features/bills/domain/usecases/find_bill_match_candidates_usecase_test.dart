import 'package:financo/features/bills/domain/usecases/find_bill_match_candidates_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/bill_factory.dart';

void main() {
  const useCase = FindBillMatchCandidatesUseCase();

  // Anchor every test on a single date so day-equality is unambiguous.
  final dueDate = DateTime(2026, 5, 5);

  TransactionEntity matchingTx({
    String id = 'tx-match',
    double amount = 200,
    String categoryId = 'cat-1',
    DateTime? date,
    TransactionType type = TransactionType.expense,
    String? linkedTransactionId,
  }) {
    return TransactionEntity(
      id: id,
      userId: 'user-1',
      accountId: 'acc-1',
      categoryId: categoryId,
      type: type,
      amount: amount,
      description: 'Aluguel',
      date: date ?? dueDate,
      linkedTransactionId: linkedTransactionId,
      createdAt: date ?? dueDate,
      updatedAt: date ?? dueDate,
    );
  }

  group('happy path', () {
    test('payable bill + matching expense → 1 candidate', () {
      final bill = BillFactory.pending(
        amount: 200,
        dueDate: dueDate,
      );
      final tx = matchingTx();

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, hasLength(1));
      expect(result.single.bill, bill);
      expect(result.single.candidates, [tx]);
    });

    test('receivable bill + matching income → 1 candidate', () {
      final bill = BillFactory.receivable(
        categoryId: 'cat-1',
        dueDate: dueDate,
      );
      final tx = matchingTx(
        amount: 5000,
        type: TransactionType.income,
      );

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result.single.candidates, [tx]);
    });

    test('one bill matching two transactions returns both candidates', () {
      final bill = BillFactory.pending(amount: 200, dueDate: dueDate);
      final tx1 = matchingTx();
      final tx2 = matchingTx(id: 'tx-match-2');

      final result = useCase(bills: [bill], transactions: [tx1, tx2]);

      expect(result.single.candidates, [tx1, tx2]);
    });
  });

  group('rejection rules', () {
    test('paid bill is skipped', () {
      final bill = BillFactory.paid(dueDate: dueDate);
      final tx = matchingTx(amount: bill.amount);

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('bill without categoryId never matches', () {
      final bill = BillFactory.pending(
        amount: 200,
        dueDate: dueDate,
        categoryId: null,
      );
      final tx = matchingTx();

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('different category does not match', () {
      final bill = BillFactory.pending(
        amount: 200,
        dueDate: dueDate,
      );
      final tx = matchingTx(categoryId: 'cat-2');

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('different amount (above tolerance) does not match', () {
      final bill = BillFactory.pending(amount: 200, dueDate: dueDate);
      final tx = matchingTx(amount: 200.50);

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('amount within tolerance still matches (cent-level diff)', () {
      // Double precision noise: 0.005 < 0.01 tolerance.
      final bill = BillFactory.pending(amount: 200, dueDate: dueDate);
      final tx = matchingTx(amount: 200.005);

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result.single.candidates, [tx]);
    });

    test('different day does not match', () {
      final bill = BillFactory.pending(amount: 200, dueDate: dueDate);
      final tx = matchingTx(date: dueDate.add(const Duration(days: 1)));

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('payable bill rejects an income transaction', () {
      final bill = BillFactory.pending(amount: 200, dueDate: dueDate);
      final tx = matchingTx(type: TransactionType.income);

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('receivable bill rejects an expense transaction', () {
      final bill = BillFactory.receivable(
        categoryId: 'cat-1',
        amount: 200,
        dueDate: dueDate,
      );
      final tx = matchingTx();

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('transfer transactions never match (linkedTransactionId set)', () {
      final bill = BillFactory.pending(amount: 200, dueDate: dueDate);
      final tx = matchingTx(linkedTransactionId: 'tx-other');

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('rejected transaction id is filtered out', () {
      final bill = BillFactory.pending(
        amount: 200,
        dueDate: dueDate,
      ).copyWith(rejectedTransactionIds: const ['tx-match']);
      final tx = matchingTx();

      final result = useCase(bills: [bill], transactions: [tx]);

      expect(result, isEmpty);
    });

    test('transaction already claimed by another paid bill is skipped', () {
      // bill-paid claims tx-match as its paidTransactionId; bill-pending
      // can't suggest it even though it would otherwise match.
      final paidBill =
          BillFactory.paid().copyWith(paidTransactionId: 'tx-match');
      final pendingBill = BillFactory.pending(
        id: 'bill-pending',
        amount: 200,
        dueDate: dueDate,
      );
      final tx = matchingTx();

      final result = useCase(
        bills: [paidBill, pendingBill],
        transactions: [tx],
      );

      expect(result, isEmpty);
    });
  });

  group('input handling', () {
    test('empty bills returns empty', () {
      final result = useCase(
        bills: const [],
        transactions: [matchingTx()],
      );
      expect(result, isEmpty);
    });

    test('empty transactions returns empty', () {
      final result = useCase(
        bills: [BillFactory.pending(dueDate: dueDate)],
        transactions: const [],
      );
      expect(result, isEmpty);
    });
  });
}
