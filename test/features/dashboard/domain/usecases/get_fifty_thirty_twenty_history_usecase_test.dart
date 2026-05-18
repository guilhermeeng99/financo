import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/domain/usecases/get_fifty_thirty_twenty_history_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/account_factory.dart';
import '../../../../harness/factories/category_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockTransactionRepository txRepo;
  late MockAccountRepository accRepo;
  late MockCategoryRepository catRepo;
  late GetFiftyThirtyTwentyHistoryUseCase useCase;

  setUp(() {
    txRepo = MockTransactionRepository();
    accRepo = MockAccountRepository();
    catRepo = MockCategoryRepository();
    useCase = GetFiftyThirtyTwentyHistoryUseCase(
      transactionRepository: txRepo,
      accountRepository: accRepo,
      categoryRepository: catRepo,
    );
  });

  final incomeCat = CategoryFactory.income(id: 'cat-income');
  final needsCat = CategoryFactory.expense(id: 'cat-needs').copyWith(
    bucket: CategoryBucket.needs,
  );
  final checking = AccountFactory.checking(id: 'acc-chk');

  void stubAll(List<TransactionEntity> txs) {
    when(
      () => accRepo.getAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<AccountEntity>>([checking]),
    );
    when(
      () => catRepo.getCategories(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<CategoryEntity>>(
        [incomeCat, needsCat],
      ),
    );
    when(
      () => txRepo.getTransactions(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right<Failure, List<TransactionEntity>>(txs));
  }

  test('returns monthCount entries in chronological order', () async {
    stubAll([]);
    final result = await useCase(
      userId: 'user-1',
      referenceMonth: DateTime(2026, 5, 17),
    );

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('Expected Right'), (entries) {
      expect(entries.length, 3);
      expect(entries[0].month, DateTime(2026, 3));
      expect(entries[1].month, DateTime(2026, 4));
      expect(entries[2].month, DateTime(2026, 5));
    });
  });

  test('buckets transactions into the right month', () async {
    final txs = [
      TransactionFactory.income(
        id: 'tx-mar-inc',
        amount: 4000,
        categoryId: incomeCat.id,
        date: DateTime(2026, 3, 10),
      ),
      TransactionFactory.expense(
        id: 'tx-apr-needs',
        amount: 1000,
        categoryId: needsCat.id,
        date: DateTime(2026, 4, 12),
      ),
      TransactionFactory.income(
        id: 'tx-may-inc',
        amount: 5000,
        categoryId: incomeCat.id,
        date: DateTime(2026, 5, 5),
      ),
    ];
    stubAll(txs);

    final result = await useCase(
      userId: 'user-1',
      referenceMonth: DateTime(2026, 5, 17),
    );
    result.fold((_) => fail('Expected Right'), (entries) {
      expect(entries[0].overview.income, 4000); // March
      expect(entries[1].overview.needsSpent, 1000); // April
      expect(entries[2].overview.income, 5000); // May
    });
  });

  test('uses custom targets in each month overview', () async {
    stubAll([
      TransactionFactory.income(
        id: 'tx-inc',
        amount: 1000,
        categoryId: incomeCat.id,
        date: DateTime(2026, 5, 5),
      ),
    ]);
    const custom = FiftyThirtyTwentyTargets(
      needs: 0.6,
      wants: 0.2,
      savings: 0.2,
    );

    final result = await useCase(
      userId: 'user-1',
      referenceMonth: DateTime(2026, 5, 17),
      targets: custom,
    );
    result.fold((_) => fail('Expected Right'), (entries) {
      // The May entry should derive its needsTarget from the custom split.
      expect(entries.last.overview.targets, custom);
      expect(entries.last.overview.needsTarget, 600);
    });
  });

  test('propagates failure if any read fails', () async {
    when(
      () => accRepo.getAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, List<AccountEntity>>(ServerFailure()),
    );
    when(
      () => catRepo.getCategories(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<CategoryEntity>>([]),
    );
    when(
      () => txRepo.getTransactions(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<TransactionEntity>>([]),
    );

    final result = await useCase(
      userId: 'user-1',
      referenceMonth: DateTime(2026, 5, 17),
    );
    expect(result.isLeft(), isTrue);
  });
}
