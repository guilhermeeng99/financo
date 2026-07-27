import 'package:financo/core/money/currency.dart';
import 'package:financo/features/data_migration/domain/account_migration_planner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/account_factory.dart';
import '../../../harness/factories/investing_factories.dart';
import '../../../harness/factories/transaction_factory.dart';

void main() {
  const planner = AccountMigrationPlanner();

  group('investment account merge (F8.5)', () {
    test('converts aporte transfers and deletes the account-side legs', () {
      final avenueAccount = AccountFactory.investment(
        id: 'acc-avenue',
        name: 'Avenue',
      );
      final avenueInstitution = InstitutionFactory.avenue();
      final transfer = TransactionFactory.transfer(
        sourceAccountId: 'acc-chk',
        destinationAccountId: 'acc-avenue',
        amount: 1000,
      );

      final plan = planner.plan(
        accounts: [AccountFactory.checking(id: 'acc-chk'), avenueAccount],
        institutions: [avenueInstitution],
        transactions: [transfer.expense, transfer.income],
        accountToInstitutionId: const {'acc-avenue': 'inst-avenue'},
        institutionIdsToConvert: const {},
      );

      expect(plan.merges.length, 1);
      final merge = plan.merges.first;
      expect(merge.account.id, 'acc-avenue');
      expect(merge.institution.id, 'inst-avenue');
      // The income leg sits on the retired account → deleted; the checking
      // expense leg becomes the institution aporte.
      expect(merge.deletedLegIds, [transfer.income.id]);
      expect(merge.aportes.length, 1);
      expect(merge.aportes.first.transactionId, transfer.expense.id);
      expect(merge.aportes.first.institutionId, 'inst-avenue');
      expect(merge.orphanTransactionCount, 0);
      expect(plan.warnings, isEmpty);
    });

    test('warns about non-transfer transactions on the account', () {
      final account = AccountFactory.investment(id: 'acc-inv', name: 'Nu');
      final institution = InstitutionFactory.nubank(id: 'inst-nu');
      final direct = TransactionFactory.income(
        id: 'tx-direct',
        accountId: 'acc-inv',
        amount: 200,
      );

      final plan = planner.plan(
        accounts: [account],
        institutions: [institution],
        transactions: [direct],
        accountToInstitutionId: const {'acc-inv': 'inst-nu'},
        institutionIdsToConvert: const {},
      );

      expect(plan.merges.single.orphanTransactionCount, 1);
      expect(plan.warnings, isNotEmpty);
    });

    test('warns when an investment account has no chosen institution', () {
      final account = AccountFactory.investment(id: 'acc-x', name: 'Mystery');

      final plan = planner.plan(
        accounts: [account],
        institutions: const [],
        transactions: const [],
        accountToInstitutionId: const {},
        institutionIdsToConvert: const {},
      );

      expect(plan.merges, isEmpty);
      expect(plan.warnings, isNotEmpty);
    });

    test('warns and skips when the chosen institution no longer exists', () {
      final account = AccountFactory.investment(id: 'acc-gone', name: 'Ghost');

      // The account maps to an institution id that is not in the set.
      final plan = planner.plan(
        accounts: [account],
        institutions: const [],
        transactions: const [],
        accountToInstitutionId: const {'acc-gone': 'inst-missing'},
        institutionIdsToConvert: const {},
      );

      expect(plan.merges, isEmpty);
      expect(plan.warnings.single, contains('no longer exists'));
    });

    test('deletes a half-paired transfer leg with no counterpart', () {
      final account = AccountFactory.investment(id: 'acc-inv', name: 'Orphan');
      final institution = InstitutionFactory.avenue();
      // Only the account-side (income) leg is in the set; its checking
      // counterpart is missing, so there is nothing to re-tag as an aporte.
      final transfer = TransactionFactory.transfer(
        sourceAccountId: 'acc-chk',
        destinationAccountId: 'acc-inv',
      );

      final plan = planner.plan(
        accounts: [account],
        institutions: [institution],
        transactions: [transfer.income],
        accountToInstitutionId: const {'acc-inv': 'inst-avenue'},
        institutionIdsToConvert: const {},
      );

      final merge = plan.merges.single;
      expect(merge.deletedLegIds, [transfer.income.id]);
      expect(merge.aportes, isEmpty);
    });
  });

  group('Wise institution conversion (F9.6)', () {
    test('converts a holding-free institution to a foreign account', () {
      final wise = InstitutionFactory.avenue(
        id: 'inst-wise',
        name: 'Wise Gui',
      );

      final plan = planner.plan(
        accounts: const [],
        institutions: [wise],
        transactions: const [],
        accountToInstitutionId: const {},
        institutionIdsToConvert: const {'inst-wise'},
      );

      expect(plan.conversions.length, 1);
      expect(plan.conversions.first.institution.id, 'inst-wise');
      expect(plan.conversions.first.currency, Currency.eur);
    });

    test('refuses to convert an institution that still holds assets', () {
      final wise = InstitutionFactory.avenue(
        id: 'inst-wise',
        name: 'Wise Gui',
      );

      final plan = planner.plan(
        accounts: const [],
        institutions: [wise],
        transactions: const [],
        accountToInstitutionId: const {},
        institutionIdsToConvert: const {'inst-wise'},
        institutionAssetCounts: const {'inst-wise': 3},
      );

      expect(plan.conversions, isEmpty);
      expect(plan.warnings, isNotEmpty);
    });
  });

  test('empty plan when nothing needs migrating', () {
    final plan = planner.plan(
      accounts: [AccountFactory.checking()],
      institutions: const [],
      transactions: const [],
      accountToInstitutionId: const {},
      institutionIdsToConvert: const {},
    );

    expect(plan.isEmpty, isTrue);
  });
}
