import 'package:financo/features/accounts/domain/account_balance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/account_factory.dart';
import '../../../harness/factories/transaction_factory.dart';

void main() {
  group('applyTransactionsToAccounts', () {
    test('returns input untouched when accounts list is empty', () {
      final result = applyTransactionsToAccounts(const [], [
        TransactionFactory.expense(),
      ]);
      expect(result, isEmpty);
    });

    test('checking: income raises balance, expense lowers it', () {
      final checking = AccountFactory.checking(
        id: 'a1',
        initialBalance: 1500,
      );
      final result = applyTransactionsToAccounts(
        [checking],
        [
          TransactionFactory.income(accountId: 'a1', amount: 200),
          TransactionFactory.expense(accountId: 'a1', amount: 80),
        ],
      );
      // 1500 + 200 - 80 = 1620
      expect(result.single.currentBalance, 1620);
    });

    test('credit card: expense raises bill, income lowers it', () {
      final card = AccountFactory.creditCard(
        id: 'card-x',
        initialBalance: 0,
        creditLimit: 1200,
      );
      final result = applyTransactionsToAccounts(
        [card],
        [
          TransactionFactory.expense(accountId: 'card-x', amount: 250),
          TransactionFactory.expense(
            id: 'tx-exp-2',
            accountId: 'card-x',
            amount: 100,
          ),
          // Payment received on the card (transfer in from checking).
          TransactionFactory.income(accountId: 'card-x', amount: 50),
        ],
      );
      // bill = 0 + 250 + 100 - 50 = 300
      expect(result.single.currentBalance, 300);
      expect(result.single.usedCredit, 300);
      expect(result.single.availableCredit, 900);
    });

    test('ignores transactions that target unknown accounts', () {
      final checking = AccountFactory.checking(
        id: 'a1',
        initialBalance: 200,
      );
      final result = applyTransactionsToAccounts(
        [checking],
        [TransactionFactory.expense(accountId: 'a-other', amount: 9999)],
      );
      expect(result.single.currentBalance, 200);
    });

    test('only applies the deltas for each account independently', () {
      final checking = AccountFactory.checking(
        id: 'check',
        initialBalance: 500,
      );
      final card = AccountFactory.creditCard(
        id: 'card',
        initialBalance: 0,
        creditLimit: 2000,
      );
      final result = applyTransactionsToAccounts(
        [checking, card],
        [
          TransactionFactory.expense(accountId: 'check', amount: 50),
          TransactionFactory.expense(
            id: 'tx-card-1',
            accountId: 'card',
            amount: 200,
          ),
        ],
      );
      expect(result[0].currentBalance, 450); // checking
      expect(result[1].currentBalance, 200); // card
    });
  });
}
