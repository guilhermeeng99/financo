import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';
import 'package:financo/features/dashboard/domain/services/compute_fifty_thirty_twenty.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';

/// Tests for the pure `compute50_30_20Overview` function. Coverage tracks
/// specs/fifty_thirty_twenty.md §2 (business rules) and §8 (edge cases).
void main() {
  // Canonical categories used across the happy-path tests. Mix of needs,
  // wants, unclassified and income.
  final needsCat = CategoryFactory.expense(
    id: 'cat-needs',
    name: 'Aluguel',
  ).copyWith(bucket: CategoryBucket.needs);
  final wantsCat = CategoryFactory.expense(
    id: 'cat-wants',
    name: 'Lazer',
  ).copyWith(bucket: CategoryBucket.wants);
  final unclassifiedCat = CategoryFactory.expense(
    id: 'cat-unset',
    name: 'Outros',
  );
  final incomeCat = CategoryFactory.income(
    id: 'cat-salary',
    name: 'Salário',
  );

  final checking = AccountFactory.checking(id: 'acc-chk-1');
  final investment = AccountEntity(
    id: 'acc-invest-1',
    userId: 'user-1',
    name: 'XP CDB',
    type: AccountType.investment,
    bank: BankType.xp,
    initialBalance: 0,
    createdAt: DateTime(2024),
  );
  final creditCard = AccountFactory.creditCard();
  final secondChecking = AccountFactory.checking(
    id: 'acc-chk-2',
    name: 'Itaú',
    bank: BankType.itau,
  );
  final secondInvestment = AccountEntity(
    id: 'acc-invest-2',
    userId: 'user-1',
    name: 'BTG',
    type: AccountType.investment,
    bank: BankType.btg,
    initialBalance: 0,
    createdAt: DateTime(2024),
  );

  group('income (rule 1)', () {
    test('sums income-type, non-transfer transactions', () {
      final txs = [
        TransactionFactory.income(amount: 4000, categoryId: incomeCat.id),
        TransactionFactory.income(
          id: 'tx-income-bonus',
          amount: 1000,
          categoryId: incomeCat.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat],
        accounts: [checking],
      );
      expect(out.income, 5000);
    });

    test('excludes transfers from income (transfer income leg ignored)', () {
      final transfer = TransactionFactory.transfer(
        sourceAccountId: checking.id,
        destinationAccountId: investment.id,
        amount: 800,
      );
      final txs = [
        TransactionFactory.income(amount: 4000, categoryId: incomeCat.id),
        transfer.income,
        transfer.expense,
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat],
        accounts: [checking, investment],
      );
      expect(out.income, 4000);
    });

    test(
      'excludes income on categories with countsIn50_30_20 = false',
      () {
        final salary = CategoryFactory.income(id: 'cat-salary');
        final refund = CategoryFactory.income(
          id: 'cat-refund',
          name: 'Reembolso',
          countsIn50_30_20: false,
        );
        final txs = [
          TransactionFactory.income(
            id: 'tx-salary',
            amount: 4000,
            categoryId: salary.id,
          ),
          TransactionFactory.income(
            id: 'tx-refund',
            amount: 800,
            categoryId: refund.id,
          ),
        ];
        final out = compute50_30_20Overview(
          periodTransactions: txs,
          categories: [salary, refund],
          accounts: [checking],
        );
        // Only the salary transaction counts toward the base; the
        // reimbursement is excluded by the flag.
        expect(out.income, 4000);
      },
    );

    test(
      'sub-income inherits countsIn50_30_20 from its parent',
      () {
        // Parent excluded → sub transactions also excluded.
        final excludedParent = CategoryFactory.income(
          id: 'parent-excluded',
          name: 'Reembolsos',
          countsIn50_30_20: false,
        );
        final subOfExcluded = CategoryFactory.subcategory(
          id: 'sub-of-excluded',
          name: 'Convênio',
          parentId: excludedParent.id,
          type: CategoryType.income,
          // The persisted value on a sub is always neutral; only the
          // parent's flag matters.
        );
        final txs = [
          TransactionFactory.income(
            id: 'tx-sub-receipt',
            amount: 300,
            categoryId: subOfExcluded.id,
          ),
        ];
        final out = compute50_30_20Overview(
          periodTransactions: txs,
          categories: [excludedParent, subOfExcluded],
          accounts: [checking],
        );
        expect(out.income, 0);
      },
    );

    test(
      'sub-income with included parent contributes to the base',
      () {
        final includedParent = CategoryFactory.income(
          id: 'parent-included',
          name: 'Investimentos',
        );
        final subOfIncluded = CategoryFactory.subcategory(
          id: 'sub-included',
          name: 'Dividendos',
          parentId: includedParent.id,
          type: CategoryType.income,
        );
        final txs = [
          TransactionFactory.income(
            id: 'tx-sub-div',
            amount: 250,
            categoryId: subOfIncluded.id,
          ),
        ];
        final out = compute50_30_20Overview(
          periodTransactions: txs,
          categories: [includedParent, subOfIncluded],
          accounts: [checking],
        );
        expect(out.income, 250);
      },
    );

    test('income == 0 yields noData status with zero percentages', () {
      final out = compute50_30_20Overview(
        periodTransactions: const [],
        categories: [needsCat, wantsCat],
        accounts: [checking],
      );
      expect(out.income, 0);
      expect(out.status, FiftyThirtyTwentyStatus.noData);
      expect(out.needsPercent, 0);
      expect(out.wantsPercent, 0);
      expect(out.savingsPercent, 0);
      expect(out.hasData, isFalse);
    });
  });

  group('expense bucket allocation (rules 2 & 3)', () {
    test('routes expenses by category.bucket; transfers excluded', () {
      final transferExpenseLeg = TransactionFactory.transfer(
        sourceAccountId: checking.id,
        destinationAccountId: investment.id,
      ).expense;
      final txs = [
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-needs',
          amount: 2400,
          categoryId: needsCat.id,
        ),
        TransactionFactory.expense(
          id: 'tx-wants',
          amount: 1500,
          categoryId: wantsCat.id,
        ),
        // Transfer leg must not count as a "needs" expense even if the
        // accountIds line up.
        transferExpenseLeg,
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, needsCat, wantsCat],
        accounts: [checking, investment],
      );
      expect(out.needsSpent, 2400);
      expect(out.wantsSpent, 1500);
      expect(out.unclassifiedSpent, 0);
    });

    test('subcategory inherits parent bucket (rule 20)', () {
      final parentNeeds = CategoryFactory.expense(
        id: 'parent-needs',
        name: 'Mercado',
      ).copyWith(bucket: CategoryBucket.needs);
      // Subcategory has no bucket of its own — by design (rule 20),
      // bucket on a subcategory is always null and the overview walks
      // up to the parent.
      final childOfNeeds = CategoryFactory.subcategory(
        id: 'child-of-needs',
        name: 'Delivery',
        parentId: parentNeeds.id,
      );
      final txs = [
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-on-child',
          amount: 300,
          categoryId: childOfNeeds.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, parentNeeds, childOfNeeds],
        accounts: [checking],
      );
      expect(out.needsSpent, 300);
      expect(out.wantsSpent, 0);
      expect(out.unclassifiedSpent, 0);
    });

    test('subcategory of an unclassified parent counts as unclassified', () {
      final parentUnset = CategoryFactory.expense(
        id: 'parent-unset',
        name: 'Outros',
      );
      final child = CategoryFactory.subcategory(
        id: 'child-of-unset',
        name: 'Misc',
        parentId: parentUnset.id,
      );
      final txs = [
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-on-unset-child',
          amount: 100,
          categoryId: child.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, parentUnset, child],
        accounts: [checking],
      );
      expect(out.unclassifiedSpent, 100);
      // Counted under the resolved root, so child + sibling on the same
      // parent only bumps the count once.
      expect(out.unclassifiedCount, 1);
    });

    test('subcategory whose parent was deleted charges spent but not count',
        () {
      // The orphan-parent subcategory inflates unclassifiedSpent (the
      // user still sees the spend), but there's nothing to classify
      // (the parent is gone, the child can't carry a bucket), so the
      // count stays at the root-backlog only — here, zero.
      final orphanChild = CategoryFactory.subcategory(
        id: 'child-orphan',
        name: 'Forgotten',
        parentId: 'parent-deleted',
      );
      final txs = [
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-on-orphan-child',
          amount: 70,
          categoryId: orphanChild.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, orphanChild],
        accounts: [checking],
      );
      expect(out.unclassifiedSpent, 70);
      expect(out.unclassifiedCount, 0);
    });

    test('orphan-category expense charges unclassifiedSpent but not count',
        () {
      // Orphan transactions hit a category the user can't classify
      // (it's been deleted), so they inflate the spend bar but not the
      // backlog count. The user has no unclassified roots in their
      // categories list either, so the count is 0.
      final txs = [
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-orphan',
          amount: 80,
          categoryId: 'cat-deleted',
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat],
        accounts: [checking],
      );
      expect(out.unclassifiedSpent, 80);
      expect(out.unclassifiedCount, 0);
    });

    test(
      'unclassifiedSpent dedupes across transactions on the same category',
      () {
        // Two transactions on the same unclassified root → both add to
        // spend; the count is driven by the categories list (which has
        // 1 unclassified root), not by how many transactions hit it.
        final txs = [
          TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
          TransactionFactory.expense(
            id: 'tx-a',
            amount: 30,
            categoryId: unclassifiedCat.id,
          ),
          TransactionFactory.expense(
            id: 'tx-b',
            amount: 50,
            categoryId: unclassifiedCat.id,
          ),
        ];
        final out = compute50_30_20Overview(
          periodTransactions: txs,
          categories: [incomeCat, unclassifiedCat],
          accounts: [checking],
        );
        expect(out.unclassifiedSpent, 80);
        expect(out.unclassifiedCount, 1);
      },
    );

    test(
      'unclassifiedCount reflects the full root backlog, not period spend',
      () {
        // Three unclassified roots in the categories list. Only one of
        // them has any transactions in the period. The count should
        // still be 3 — the user wants to see the full backlog of
        // classification work, not just the categories that happened to
        // spend this month.
        final root1 = CategoryFactory.expense(id: 'root-1', name: 'A');
        final root2 = CategoryFactory.expense(id: 'root-2', name: 'B');
        final root3 = CategoryFactory.expense(id: 'root-3', name: 'C');
        final classified = CategoryFactory.expense(
          id: 'root-4',
          name: 'D',
        ).copyWith(bucket: CategoryBucket.needs);
        final txs = [
          TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
          TransactionFactory.expense(
            id: 'tx-only-on-root1',
            amount: 100,
            categoryId: root1.id,
          ),
        ];
        final out = compute50_30_20Overview(
          periodTransactions: txs,
          categories: [incomeCat, root1, root2, root3, classified],
          accounts: [checking],
        );
        expect(out.unclassifiedCount, 3);
        expect(out.unclassifiedSpent, 100);
      },
    );

    test(
      'unclassifiedCount ignores subcategories (they inherit from parent)',
      () {
        final root = CategoryFactory.expense(id: 'root');
        final sub1 = CategoryFactory.subcategory(
          id: 'sub-1',
          parentId: 'root',
        );
        final sub2 = CategoryFactory.subcategory(
          id: 'sub-2',
          parentId: 'root',
        );
        final out = compute50_30_20Overview(
          periodTransactions: const [],
          categories: [root, sub1, sub2],
          accounts: const [],
        );
        // Only the one unclassified root counts, regardless of how many
        // subcategories hang off it.
        expect(out.unclassifiedCount, 1);
      },
    );

    test('unclassifiedCount ignores income categories', () {
      final out = compute50_30_20Overview(
        periodTransactions: const [],
        categories: [incomeCat, needsCat, wantsCat],
        accounts: const [],
      );
      // All three are classified or income — none belongs in the
      // expense classification backlog.
      expect(out.unclassifiedCount, 0);
    });
  });

  group('savings flow (rule 4)', () {
    test('checking → investment counts as positive savings', () {
      final transfer = TransactionFactory.transfer(
        sourceAccountId: checking.id,
        destinationAccountId: investment.id,
        amount: 1000,
      );
      final out = compute50_30_20Overview(
        periodTransactions: [transfer.expense, transfer.income],
        categories: const [],
        accounts: [checking, investment],
      );
      expect(out.savingsAmount, 1000);
    });

    test('half-pair (linked leg outside the window) is ignored', () {
      // Only the checking → investment expense leg falls in the period; its
      // linked income leg is outside the window, so the pair can't be
      // resolved and must NOT be counted as savings (mate == null branch).
      final transfer = TransactionFactory.transfer(
        sourceAccountId: checking.id,
        destinationAccountId: investment.id,
        amount: 1000,
      );
      final out = compute50_30_20Overview(
        periodTransactions: [transfer.expense],
        categories: const [],
        accounts: [checking, investment],
      );
      expect(out.savingsAmount, 0);
    });

    test('resgate (investment → checking) subtracts', () {
      final deposit = TransactionFactory.transfer(
        expenseId: 'tx-dep-exp',
        incomeId: 'tx-dep-inc',
        sourceAccountId: checking.id,
        destinationAccountId: investment.id,
        amount: 1000,
      );
      final resgate = TransactionFactory.transfer(
        expenseId: 'tx-res-exp',
        incomeId: 'tx-res-inc',
        sourceAccountId: investment.id,
        destinationAccountId: checking.id,
        amount: 200,
      );
      final out = compute50_30_20Overview(
        periodTransactions: [
          deposit.expense,
          deposit.income,
          resgate.expense,
          resgate.income,
        ],
        categories: const [],
        accounts: [checking, investment],
      );
      expect(out.savingsAmount, 800);
    });

    test('net resgate without deposits clamps at 0', () {
      final resgate = TransactionFactory.transfer(
        sourceAccountId: investment.id,
        destinationAccountId: checking.id,
        amount: 600,
      );
      final out = compute50_30_20Overview(
        periodTransactions: [resgate.expense, resgate.income],
        categories: const [],
        accounts: [checking, investment],
      );
      expect(out.savingsAmount, 0);
    });

    test('checking → checking is ignored', () {
      final transfer = TransactionFactory.transfer(
        sourceAccountId: checking.id,
        destinationAccountId: secondChecking.id,
        amount: 750,
      );
      final out = compute50_30_20Overview(
        periodTransactions: [transfer.expense, transfer.income],
        categories: const [],
        accounts: [checking, secondChecking],
      );
      expect(out.savingsAmount, 0);
    });

    test('investment → investment (rebalance) is ignored', () {
      final transfer = TransactionFactory.transfer(
        sourceAccountId: investment.id,
        destinationAccountId: secondInvestment.id,
        amount: 400,
      );
      final out = compute50_30_20Overview(
        periodTransactions: [transfer.expense, transfer.income],
        categories: const [],
        accounts: [investment, secondInvestment],
      );
      expect(out.savingsAmount, 0);
    });

    test('checking → credit card (card payment) is ignored', () {
      final transfer = TransactionFactory.transfer(
        sourceAccountId: checking.id,
        destinationAccountId: creditCard.id,
        amount: 2200,
      );
      final out = compute50_30_20Overview(
        periodTransactions: [transfer.expense, transfer.income],
        categories: const [],
        accounts: [checking, creditCard],
      );
      expect(out.savingsAmount, 0);
    });

    test('hasInvestmentAccount surfaces presence regardless of transfers',
        () {
      final withInvest = compute50_30_20Overview(
        periodTransactions: const [],
        categories: const [],
        accounts: [checking, investment],
      );
      expect(withInvest.hasInvestmentAccount, isTrue);

      final withoutInvest = compute50_30_20Overview(
        periodTransactions: const [],
        categories: const [],
        accounts: [checking],
      );
      expect(withoutInvest.hasInvestmentAccount, isFalse);
    });
  });

  group('status aggregation', () {
    test('all on target → onTrack', () {
      final deposit = TransactionFactory.transfer(
        sourceAccountId: checking.id,
        destinationAccountId: investment.id,
        amount: 1000,
      );
      final txs = <TransactionEntity>[
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-needs',
          amount: 2500,
          categoryId: needsCat.id,
        ),
        TransactionFactory.expense(
          id: 'tx-wants',
          amount: 1500,
          categoryId: wantsCat.id,
        ),
        deposit.expense,
        deposit.income,
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, needsCat, wantsCat],
        accounts: [checking, investment],
      );
      expect(out.needsPercent, 0.5);
      expect(out.wantsPercent, 0.3);
      expect(out.savingsPercent, 0.2);
      expect(out.status, FiftyThirtyTwentyStatus.onTrack);
    });

    test('savings short → needsAttention (per-bucket status fired)', () {
      final txs = <TransactionEntity>[
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-needs',
          amount: 2400,
          categoryId: needsCat.id,
        ),
        TransactionFactory.expense(
          id: 'tx-wants',
          amount: 1500,
          categoryId: wantsCat.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, needsCat, wantsCat],
        accounts: [checking, investment],
      );
      expect(out.savingsStatus, BucketStatus.under);
      expect(out.status, FiftyThirtyTwentyStatus.needsAttention);
    });

    test('unclassified dominant takes priority over needsAttention', () {
      final txs = <TransactionEntity>[
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-needs',
          amount: 500,
          categoryId: needsCat.id,
        ),
        TransactionFactory.expense(
          id: 'tx-unset',
          amount: 3000,
          categoryId: unclassifiedCat.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, needsCat, unclassifiedCat],
        accounts: [checking],
      );
      expect(
        out.status,
        FiftyThirtyTwentyStatus.unclassifiedDominant,
      );
    });

    test('needs at exactly 50% boundary is onTrack (≤ not <)', () {
      final txs = <TransactionEntity>[
        TransactionFactory.income(amount: 1000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-needs',
          amount: 500,
          categoryId: needsCat.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, needsCat],
        accounts: [checking],
      );
      expect(out.needsStatus, BucketStatus.onTrack);
    });

    test('needs 1 cent over 50% flips to over', () {
      final txs = <TransactionEntity>[
        TransactionFactory.income(amount: 1000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-needs',
          amount: 500.01,
          categoryId: needsCat.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, needsCat],
        accounts: [checking],
      );
      expect(out.needsStatus, BucketStatus.over);
    });
  });

  group('derived getters', () {
    test('targets and overflows compute against income', () {
      final txs = <TransactionEntity>[
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        TransactionFactory.expense(
          id: 'tx-needs',
          amount: 3000,
          categoryId: needsCat.id,
        ),
        TransactionFactory.expense(
          id: 'tx-wants',
          amount: 1800,
          categoryId: wantsCat.id,
        ),
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat, needsCat, wantsCat],
        accounts: [checking, investment],
      );
      expect(out.needsTarget, 2500);
      expect(out.wantsTarget, 1500);
      expect(out.savingsTarget, 1000);
      expect(out.needsOverflow, 500);
      expect(out.wantsOverflow, 300);
      expect(out.savingsShortfall, 1000);
    });

    test('savingsShortfall is 0 when over target', () {
      final deposit = TransactionFactory.transfer(
        sourceAccountId: checking.id,
        destinationAccountId: investment.id,
        amount: 1500,
      );
      final txs = <TransactionEntity>[
        TransactionFactory.income(amount: 5000, categoryId: incomeCat.id),
        deposit.expense,
        deposit.income,
      ];
      final out = compute50_30_20Overview(
        periodTransactions: txs,
        categories: [incomeCat],
        accounts: [checking, investment],
      );
      expect(out.savingsShortfall, 0);
    });
  });
}
