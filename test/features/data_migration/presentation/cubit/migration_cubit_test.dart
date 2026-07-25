import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/data_migration/domain/account_migration_executor.dart';
import 'package:financo/features/data_migration/domain/account_migration_planner.dart';
import 'package:financo/features/data_migration/presentation/cubit/migration_cubit.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAccountRepository accounts;
  late MockInstitutionRepository institutions;
  late MockTransactionRepository transactions;
  late MockAssetRepository assets;
  late MockAccountMigrationExecutor executor;

  const userId = 'user-1';

  setUpAll(() {
    registerFallbackValue(
      const AccountMigrationPlan(merges: [], conversions: [], warnings: []),
    );
  });

  setUp(() {
    accounts = MockAccountRepository();
    institutions = MockInstitutionRepository();
    transactions = MockTransactionRepository();
    assets = MockAssetRepository();
    executor = MockAccountMigrationExecutor();

    when(
      () => accounts.getAccounts(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => Right<Failure, List<AccountEntity>>([
        AccountFactory.checking(id: 'acc-chk'),
        AccountFactory.investment(id: 'acc-avenue', name: 'Avenue'),
      ]),
    );
    when(
      () => institutions.getInstitutions(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => Right<Failure, List<Institution>>([
        InstitutionFactory.avenue(),
      ]),
    );
    when(
      () => transactions.getTransactions(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => const Right<Failure, List<TransactionEntity>>([]),
    );
    when(
      () => assets.getAssets(userId: any(named: 'userId')),
    ).thenAnswer((_) async => const Right<Failure, List<Asset>>([]));
  });

  MigrationCubit build() => MigrationCubit(
    accountRepository: accounts,
    institutionRepository: institutions,
    transactionRepository: transactions,
    assetRepository: assets,
    executor: executor,
    userId: userId,
  );

  test('load emits Ready, pre-filling the exact-name mapping', () async {
    final cubit = build();
    await cubit.load();

    final state = cubit.state;
    expect(state, isA<MigrationReady>());
    final ready = state as MigrationReady;
    expect(ready.investmentAccounts.single.id, 'acc-avenue');
    // "Avenue" account exact-matches the "Avenue" institution.
    expect(ready.mapping['acc-avenue'], 'inst-avenue');
    expect(ready.plan.merges.single.institution.id, 'inst-avenue');
    addTearDown(cubit.close);
  });

  test('apply delegates to the executor and emits Done', () async {
    when(() => executor.apply(any())).thenAnswer(
      (_) async => const Right(MigrationResult(accountsRemoved: 1)),
    );

    final cubit = build();
    await cubit.load();
    await cubit.apply();

    expect(cubit.state, isA<MigrationDone>());
    expect((cubit.state as MigrationDone).result.accountsRemoved, 1);
    verify(() => executor.apply(any())).called(1);
    addTearDown(cubit.close);
  });

  test('load emits Error when a repository fails', () async {
    when(
      () => accounts.getAccounts(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) async => const Left<Failure, List<AccountEntity>>(ServerFailure()),
    );

    final cubit = build();
    await cubit.load();

    expect(cubit.state, isA<MigrationError>());
    addTearDown(cubit.close);
  });
}
