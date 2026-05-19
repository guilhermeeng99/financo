import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/features/investments/domain/services/compute_investment_overview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/asset_class_factory.dart';
import '../../../../harness/factories/asset_holding_factory.dart';

void main() {
  group('computeInvestmentOverview', () {
    test('zero accounts produces a fully empty snapshot', () {
      final overview = computeInvestmentOverview(
        accounts: const [],
        classes: const [],
        holdings: const [],
      );

      expect(overview.totalInvested, 0);
      expect(overview.totalAllocated, 0);
      expect(overview.totalPending, 0);
      expect(overview.hasInvestments, isFalse);
      expect(overview.hasPending, isFalse);
      expect(overview.accountBreakdown, isEmpty);
      expect(overview.classBreakdown, isEmpty);
      expect(overview.rebalanceActions, isEmpty);
    });

    test(
      'totalInvested sums only investment accounts (checking ignored)',
      () {
        final accounts = [
          AccountFactory.checking(initialBalance: 5000),
          AccountFactory.investment(currentBalance: 10000),
          AccountFactory.investment(
            id: 'acc-inv-2',
            initialBalance: 20000,
            currentBalance: 20000,
          ),
        ];

        final overview = computeInvestmentOverview(
          accounts: accounts,
          classes: const [],
          holdings: const [],
        );

        expect(overview.totalInvested, 30000);
        expect(overview.accountBreakdown, hasLength(2));
      },
    );

    test(
      'pending equals balance minus holdings when nothing is allocated',
      () {
        final accounts = [
          AccountFactory.investment(
            initialBalance: 60000,
            currentBalance: 60000,
          ),
        ];
        final overview = computeInvestmentOverview(
          accounts: accounts,
          classes: AssetClassFactory.arcaList(),
          holdings: const [],
        );

        expect(overview.totalAllocated, 0);
        expect(overview.totalPending, 60000);
        expect(overview.hasPending, isTrue);
        expect(overview.accountBreakdown.single.pending, 60000);
      },
    );

    test('matches ARCA target allocation when fully balanced', () {
      final accounts = [
        AccountFactory.investment(
          initialBalance: 40000,
          currentBalance: 40000,
        ),
      ];
      final classes = AssetClassFactory.arcaList();
      final holdings = [
        AssetHoldingFactory.holding(
          id: 'h-stocks',
          amount: 10000,
        ),
        AssetHoldingFactory.holding(
          id: 'h-re',
          assetClassId: 'class-re',
          amount: 10000,
        ),
        AssetHoldingFactory.holding(
          id: 'h-crypto',
          assetClassId: 'class-crypto',
          amount: 10000,
        ),
        AssetHoldingFactory.holding(
          id: 'h-fi',
          assetClassId: 'class-fi',
          amount: 10000,
        ),
      ];

      final overview = computeInvestmentOverview(
        accounts: accounts,
        classes: classes,
        holdings: holdings,
      );

      expect(overview.totalAllocated, 40000);
      expect(overview.totalPending, 0);
      expect(
        overview.classBreakdown.every((s) => s.deltaAmount.abs() < 0.01),
        isTrue,
      );
      // Each class is exactly on target — no rebalance action expected.
      expect(overview.rebalanceActions, isEmpty);
    });

    test('rebalance actions surface biggest deltas first', () {
      final accounts = [
        AccountFactory.investment(
          initialBalance: 100000,
          currentBalance: 100000,
        ),
      ];
      final classes = AssetClassFactory.arcaList();
      final holdings = [
        // Real estate: 50k allocated where target is 25k → SELL 25k.
        AssetHoldingFactory.holding(
          id: 'h-re',
          assetClassId: 'class-re',
          amount: 50000,
        ),
        // Bitcoin: 5k allocated where target is 25k → BUY 20k.
        AssetHoldingFactory.holding(
          id: 'h-crypto',
          assetClassId: 'class-crypto',
          amount: 5000,
        ),
        // Stocks: 13k where target is 25k → BUY 12k.
        AssetHoldingFactory.holding(
          id: 'h-stocks',
          amount: 13000,
        ),
        // Fixed income: 32k where target is 25k → SELL 7k.
        AssetHoldingFactory.holding(
          id: 'h-fi',
          assetClassId: 'class-fi',
          amount: 32000,
        ),
      ];

      final overview = computeInvestmentOverview(
        accounts: accounts,
        classes: classes,
        holdings: holdings,
      );

      expect(overview.totalAllocated, 100000);
      expect(overview.totalPending, 0);

      final actions = overview.rebalanceActions;
      expect(actions, hasLength(4));
      // Sorted by absolute amount, biggest first.
      expect(actions[0].classId, 'class-re');
      expect(actions[0].direction, RebalanceDirection.sell);
      expect(actions[0].amount, 25000);
      expect(actions[1].classId, 'class-crypto');
      expect(actions[1].direction, RebalanceDirection.buy);
      expect(actions[1].amount, 20000);
    });

    test('holdings with a missing accountId are reported as orphans', () {
      final accounts = [
        AccountFactory.investment(currentBalance: 10000),
      ];
      final classes = [AssetClassFactory.stocks()];
      final holdings = [
        AssetHoldingFactory.holding(
          id: 'orphan-1',
          accountId: 'deleted-account',
          amount: 5000,
        ),
        AssetHoldingFactory.holding(
          id: 'live-1',
          amount: 4000,
        ),
      ];

      final overview = computeInvestmentOverview(
        accounts: accounts,
        classes: classes,
        holdings: holdings,
      );

      expect(overview.orphanHoldingIds, ['orphan-1']);
      // Orphan is excluded from allocation totals.
      expect(overview.totalAllocated, 4000);
      expect(overview.totalPending, 6000);
    });

    test(
      'overflow account flags allocations greater than balance',
      () {
        final accounts = [
          AccountFactory.investment(
            initialBalance: 1000,
            currentBalance: 1000,
          ),
        ];
        final classes = [AssetClassFactory.stocks()];
        final holdings = [
          // Holding amount > balance (e.g. a withdrawal post-dated the
          // declared allocation).
          AssetHoldingFactory.holding(amount: 1500),
        ];

        final overview = computeInvestmentOverview(
          accounts: accounts,
          classes: classes,
          holdings: holdings,
        );

        expect(overview.accountBreakdown.single.hasOverflow, isTrue);
        // Total pending is clamped to zero, never negative.
        expect(overview.totalPending, 0);
      },
    );

    test('targetSumPercent reflects user-defined class totals', () {
      final overview = computeInvestmentOverview(
        accounts: const <AccountEntity>[],
        classes: [
          AssetClassFactory.stocks(targetPercent: 40),
          AssetClassFactory.realEstate(targetPercent: 35),
          AssetClassFactory.crypto(targetPercent: 15),
        ],
        holdings: const [],
      );

      expect(overview.targetSumPercent, 90);
      expect(overview.targetsBalanced, isFalse);
    });

    test(
      'subclass holdings roll up to the parent class total',
      () {
        final stocks = AssetClassFactory.stocks(targetPercent: 50);
        final apple = AssetClassFactory.subclass(
          id: 'sub-apple',
          name: 'Apple',
          parent: stocks,
        );
        final tesla = AssetClassFactory.subclass(
          id: 'sub-tesla',
          name: 'Tesla',
          parent: stocks,
        );
        final accounts = [
          AccountFactory.investment(currentBalance: 10000),
        ];
        final holdings = [
          AssetHoldingFactory.holding(
            id: 'h-apple',
            assetClassId: apple.id,
            amount: 3000,
          ),
          AssetHoldingFactory.holding(
            id: 'h-tesla',
            assetClassId: tesla.id,
            amount: 2000,
          ),
        ];

        final overview = computeInvestmentOverview(
          accounts: accounts,
          classes: [stocks, apple, tesla],
          holdings: holdings,
        );

        // Only the root appears in the top-level breakdown — Apple
        // and Tesla nest under it.
        expect(overview.classBreakdown, hasLength(1));
        final root = overview.classBreakdown.single;
        expect(root.classId, stocks.id);
        expect(root.currentAmount, 5000); // 3k + 2k
        expect(root.subclasses, hasLength(2));

        final subAmounts = {
          for (final s in root.subclasses) s.subclassId: s.currentAmount,
        };
        expect(subAmounts[apple.id], 3000);
        expect(subAmounts[tesla.id], 2000);

        // Apple = 60% of stocks; Tesla = 40% of stocks.
        final applePct = root.subclasses
            .firstWhere((s) => s.subclassId == apple.id)
            .percentOfClass;
        final teslaPct = root.subclasses
            .firstWhere((s) => s.subclassId == tesla.id)
            .percentOfClass;
        expect(applePct, closeTo(0.6, 0.001));
        expect(teslaPct, closeTo(0.4, 0.001));
      },
    );

    test(
      'orphan subclass holdings count as unclassified',
      () {
        final orphanSubclass = AssetClassEntity(
          id: 'sub-orphan',
          userId: 'user-1',
          name: 'Ghost',
          icon: 0,
          color: 0,
          targetPercent: 0,
          parentId: 'missing-parent',
          createdAt: DateTime(2024),
        );
        final accounts = [
          AccountFactory.investment(currentBalance: 10000),
        ];
        final holdings = [
          AssetHoldingFactory.holding(
            id: 'h-orphan',
            assetClassId: orphanSubclass.id,
            amount: 4000,
          ),
        ];

        final overview = computeInvestmentOverview(
          accounts: accounts,
          classes: [orphanSubclass],
          holdings: holdings,
        );

        // Orphan subclass = no root in breakdown, holding listed in
        // orphans.
        expect(overview.classBreakdown, isEmpty);
        expect(overview.orphanHoldingIds, ['h-orphan']);
        expect(overview.totalAllocated, 0);
      },
    );

    test(
      'computeAvailableForAccount excludes the holding being edited',
      () {
        final account = AccountFactory.investment(currentBalance: 10000);
        final holdings = [
          AssetHoldingFactory.holding(
            id: 'h-existing',
            amount: 4000,
          ),
          AssetHoldingFactory.holding(
            id: 'h-other',
            amount: 3000,
          ),
        ];

        final availableForEdit = computeAvailableForAccount(
          account: account,
          holdings: holdings,
          excludeHoldingId: 'h-existing',
        );
        // Editing h-existing should see its slot freed: 10k - 3k = 7k.
        expect(availableForEdit, 7000);

        final availableForCreate = computeAvailableForAccount(
          account: account,
          holdings: holdings,
        );
        // Creating a new holding accounts for both existing rows.
        expect(availableForCreate, 3000);
      },
    );
  });
}
