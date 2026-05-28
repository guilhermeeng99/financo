import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_with_dependents_usecase.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockTransactionRepository txRepo;
  late MockAccountRepository accountRepo;
  late MockAssetHoldingRepository holdingRepo;
  late DeleteAccountWithDependentsUseCase useCase;

  const userId = 'user-1';
  const accountId = 'acc-1';

  setUp(() {
    txRepo = MockTransactionRepository();
    accountRepo = MockAccountRepository();
    holdingRepo = MockAssetHoldingRepository();
    useCase = DeleteAccountWithDependentsUseCase(
      transactionRepository: txRepo,
      accountRepository: accountRepo,
      assetHoldingRepository: holdingRepo,
    );
  });

  List<TransactionEntity> twoTransactions() => [
        TransactionFactory.expense(id: 'tx-1'),
        TransactionFactory.expense(id: 'tx-2'),
      ];

  void stubGetTransactions(Either<Failure, List<TransactionEntity>> result) {
    when(
      () => txRepo.getTransactions(
        userId: any(named: 'userId'),
        accountId: any(named: 'accountId'),
      ),
    ).thenAnswer((_) async => result);
  }

  test('deletes every transaction, then the account, then holdings', () async {
    stubGetTransactions(Right(twoTransactions()));
    when(() => txRepo.deleteTransaction(any()))
        .thenAnswer((_) async => const Right<Failure, void>(null));
    when(() => accountRepo.deleteAccount(any()))
        .thenAnswer((_) async => const Right<Failure, void>(null));
    when(() => holdingRepo.deleteHoldingsForAccount(any()))
        .thenAnswer((_) async => const Right<Failure, void>(null));

    final result = await useCase(userId: userId, accountId: accountId);

    expect(result, const Right<Failure, void>(null));
    verify(() => txRepo.deleteTransaction('tx-1')).called(1);
    verify(() => txRepo.deleteTransaction('tx-2')).called(1);
    verify(() => accountRepo.deleteAccount(accountId)).called(1);
    verify(() => holdingRepo.deleteHoldingsForAccount(accountId)).called(1);
  });

  test('returns Left and never deletes the account if loading tx fails',
      () async {
    stubGetTransactions(const Left(ServerFailure()));

    final result = await useCase(userId: userId, accountId: accountId);

    expect(result, isA<Left<Failure, void>>());
    verifyNever(() => txRepo.deleteTransaction(any()));
    verifyNever(() => accountRepo.deleteAccount(any()));
  });

  test('short-circuits to Left when a transaction fails to delete', () async {
    stubGetTransactions(Right(twoTransactions()));
    when(() => txRepo.deleteTransaction('tx-1'))
        .thenAnswer((_) async => const Left<Failure, void>(ServerFailure()));

    final result = await useCase(userId: userId, accountId: accountId);

    expect(result, isA<Left<Failure, void>>());
    // Stops before deleting the second tx and the account.
    verifyNever(() => txRepo.deleteTransaction('tx-2'));
    verifyNever(() => accountRepo.deleteAccount(any()));
  });

  test('returns Left when the account delete fails (no holdings cleanup)',
      () async {
    stubGetTransactions(const Right([]));
    when(() => accountRepo.deleteAccount(any()))
        .thenAnswer((_) async => const Left<Failure, void>(ServerFailure()));

    final result = await useCase(userId: userId, accountId: accountId);

    expect(result, isA<Left<Failure, void>>());
    verifyNever(() => holdingRepo.deleteHoldingsForAccount(any()));
  });

  test('still succeeds when best-effort holdings cleanup fails', () async {
    stubGetTransactions(const Right([]));
    when(() => accountRepo.deleteAccount(any()))
        .thenAnswer((_) async => const Right<Failure, void>(null));
    when(() => holdingRepo.deleteHoldingsForAccount(any()))
        .thenAnswer((_) async => const Left<Failure, void>(ServerFailure()));

    final result = await useCase(userId: userId, accountId: accountId);

    expect(result, const Right<Failure, void>(null));
  });
}
