import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/data_migration/domain/account_migration_executor.dart';
import 'package:financo/features/data_migration/domain/account_migration_planner.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../harness/factories/account_factory.dart';
import '../../../harness/factories/investing_factories.dart';
import '../../../harness/factories/transaction_factory.dart';
import '../../../harness/mocks.dart';

void main() {
  late MockAccountRepository accounts;
  late MockInstitutionRepository institutions;
  late MockTransactionRepository transactions;
  late AccountMigrationExecutor executor;

  setUpAll(() {
    registerFallbackValue(TransactionFactory.expense());
    registerFallbackValue(AccountFactory.checking());
    registerFallbackValue(InstitutionFactory.avenue());
  });

  setUp(() {
    accounts = MockAccountRepository();
    institutions = MockInstitutionRepository();
    transactions = MockTransactionRepository();
    executor = AccountMigrationExecutor(
      accountRepository: accounts,
      institutionRepository: institutions,
      transactionRepository: transactions,
    );
  });

  test('applies a merge + a Wise conversion end to end', () async {
    final expenseLeg = TransactionFactory.transfer(
      sourceAccountId: 'acc-chk',
      destinationAccountId: 'acc-avenue',
    ).expense; // id 'tx-transfer-exp', linked to the income leg

    final plan = AccountMigrationPlan(
      merges: [
        InvestmentAccountMerge(
          account: AccountFactory.investment(id: 'acc-avenue', name: 'Avenue'),
          institution: InstitutionFactory.avenue(),
          aportes: [
            ConvertedCashFlow(
              transactionId: expenseLeg.id,
              institutionId: 'inst-avenue',
            ),
          ],
          deletedLegIds: const ['tx-transfer-inc'],
          orphanTransactionCount: 0,
        ),
      ],
      conversions: [
        WiseInstitutionConversion(
          institution: InstitutionFactory.avenue(
            id: 'inst-wise',
            name: 'Wise Gui',
          ),
          currency: Currency.eur,
        ),
      ],
      warnings: const [],
    );

    // The test only inspects the captured arguments, so the stubs return any
    // valid Right.
    when(
      () => transactions.getTransaction(expenseLeg.id),
    ).thenAnswer((_) async => Right(expenseLeg));
    when(
      () => transactions.updateTransaction(any()),
    ).thenAnswer((_) async => Right(TransactionFactory.expense()));
    when(
      () => transactions.deleteTransaction(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => institutions.updateInstitution(any()),
    ).thenAnswer((_) async => Right(InstitutionFactory.avenue()));
    when(
      () => accounts.deleteAccount(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => accounts.createAccount(any()),
    ).thenAnswer((_) async => Right(AccountFactory.checking()));
    when(
      () => institutions.deleteInstitution(any()),
    ).thenAnswer((_) async => const Right(null));

    final result = await executor.apply(plan);

    expect(result.isRight(), isTrue);
    final counts = result.getOrElse(() => throw StateError('expected Right'));
    expect(counts.aportesRetagged, 1);
    expect(counts.legsDeleted, 1);
    expect(counts.accountsRemoved, 1);
    expect(counts.accountsCreated, 1);
    expect(counts.institutionsRemoved, 1);

    // The re-tagged leg carries the institution and drops its transfer link.
    final retagged = verify(
      () => transactions.updateTransaction(captureAny()),
    ).captured.single as TransactionEntity;
    expect(retagged.institutionId, 'inst-avenue');
    expect(retagged.linkedTransactionId, isNull);
    expect(retagged.isInvestmentCashFlow, isTrue);

    verify(() => transactions.deleteTransaction('tx-transfer-inc')).called(1);
    verify(() => accounts.deleteAccount('acc-avenue')).called(1);

    // The Wise institution becomes a EUR checking account.
    final created = verify(
      () => accounts.createAccount(captureAny()),
    ).captured.single as AccountEntity;
    expect(created.type, AccountType.checking);
    expect(created.currency, Currency.eur);
    expect(created.name, 'Wise Gui');
    verify(() => institutions.deleteInstitution('inst-wise')).called(1);
  });

  test('stops and returns the failure when a write fails', () async {
    final plan = AccountMigrationPlan(
      merges: [
        InvestmentAccountMerge(
          account: AccountFactory.investment(id: 'acc-avenue'),
          institution: InstitutionFactory.avenue(),
          aportes: const [],
          deletedLegIds: const ['tx-leg'],
          orphanTransactionCount: 0,
        ),
      ],
      conversions: const [],
      warnings: const [],
    );

    when(
      () => transactions.deleteTransaction(any()),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await executor.apply(plan);

    expect(result, isA<Left<dynamic, dynamic>>());
    // The account is never deleted once a prior step failed.
    verifyNever(() => accounts.deleteAccount(any()));
  });

  // A single-merge plan carrying one aporte flow and nothing else, so each
  // failure test can point at exactly one step. Legs are empty so the aporte
  // is always the first write attempted.
  AccountMigrationPlan singleAporteMerge(String flowTxId) =>
      AccountMigrationPlan(
    merges: [
      InvestmentAccountMerge(
        account: AccountFactory.investment(id: 'acc-avenue'),
        institution: InstitutionFactory.avenue(),
        aportes: [
          ConvertedCashFlow(
            transactionId: flowTxId,
            institutionId: 'inst-avenue',
          ),
        ],
        deletedLegIds: const [],
        orphanTransactionCount: 0,
      ),
    ],
    conversions: const [],
    warnings: const [],
  );

  // A single-merge plan with no aportes and no legs — the first write is the
  // institution update, so it isolates the later merge steps.
  final bareMergePlan = AccountMigrationPlan(
    merges: [
      InvestmentAccountMerge(
        account: AccountFactory.investment(id: 'acc-avenue'),
        institution: InstitutionFactory.avenue(),
        aportes: const [],
        deletedLegIds: const [],
        orphanTransactionCount: 0,
      ),
    ],
    conversions: const [],
    warnings: const [],
  );

  AccountMigrationPlan singleConversionPlan() => AccountMigrationPlan(
    merges: const [],
    conversions: [
      WiseInstitutionConversion(
        institution: InstitutionFactory.avenue(id: 'inst-wise', name: 'Wise'),
        currency: Currency.eur,
      ),
    ],
    warnings: const [],
  );

  test(
    'skips an aporte whose transaction is already gone and still succeeds',
    () async {
      final plan = singleAporteMerge('tx-missing');

      // getTransaction cannot find it → the fold maps to null → the leg is
      // skipped as non-fatal (executor.dart:76-87), not re-tagged.
      when(
        () => transactions.getTransaction('tx-missing'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => institutions.updateInstitution(any()),
      ).thenAnswer((_) async => Right(InstitutionFactory.avenue()));
      when(
        () => accounts.deleteAccount(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await executor.apply(plan);

      final counts = result.getOrElse(() => throw StateError('expected Right'));
      // The missing leg is skipped (continue), not counted.
      expect(counts.aportesRetagged, 0);
      expect(counts.accountsRemoved, 1);
      verifyNever(() => transactions.updateTransaction(any()));
    },
  );

  test('returns the failure when re-tagging an aporte fails', () async {
    final leg = TransactionFactory.transfer().expense;
    final plan = singleAporteMerge(leg.id);

    when(
      () => transactions.getTransaction(leg.id),
    ).thenAnswer((_) async => Right(leg));
    when(
      () => transactions.updateTransaction(any()),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await executor.apply(plan);

    expect(result, isA<Left<dynamic, dynamic>>());
    // Stops before folding the account into the institution.
    verifyNever(() => institutions.updateInstitution(any()));
    verifyNever(() => accounts.deleteAccount(any()));
  });

  test('returns the failure when updating the institution fails', () async {
    when(
      () => institutions.updateInstitution(any()),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await executor.apply(bareMergePlan);

    expect(result, isA<Left<dynamic, dynamic>>());
    // The account is never retired once its institution update failed.
    verifyNever(() => accounts.deleteAccount(any()));
  });

  test('returns the failure when deleting the merged account fails', () async {
    when(
      () => institutions.updateInstitution(any()),
    ).thenAnswer((_) async => Right(InstitutionFactory.avenue()));
    when(
      () => accounts.deleteAccount(any()),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await executor.apply(bareMergePlan);

    expect(result, isA<Left<dynamic, dynamic>>());
    // No conversions follow a failed merge.
    verifyNever(() => accounts.createAccount(any()));
  });

  test('returns the failure when creating the converted account fails',
      () async {
    when(
      () => accounts.createAccount(any()),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await executor.apply(singleConversionPlan());

    expect(result, isA<Left<dynamic, dynamic>>());
    // The institution is never removed once the account create failed.
    verifyNever(() => institutions.deleteInstitution(any()));
  });

  test(
    'returns the failure when deleting the converted institution fails',
    () async {
      when(
        () => accounts.createAccount(any()),
      ).thenAnswer((_) async => Right(AccountFactory.checking()));
      when(
        () => institutions.deleteInstitution(any()),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await executor.apply(singleConversionPlan());

      expect(result, isA<Left<dynamic, dynamic>>());
    },
  );
}
