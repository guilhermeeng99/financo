import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/get_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late GetTransactionUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionUseCase(mockRepository);
  });

  const txId = 'tx-1';

  test('delegates to repository.getTransaction with the given id', () async {
    final transaction = TransactionFactory.expense(id: txId);
    when(
      () => mockRepository.getTransaction(any()),
    ).thenAnswer((_) async => Right(transaction));

    await useCase(txId);

    final captured =
        verify(() => mockRepository.getTransaction(captureAny())).captured;
    expect(captured.single, txId);
  });

  test('forwards the Right branch from the repository unchanged', () async {
    final transaction = TransactionFactory.expense(id: txId);
    when(
      () => mockRepository.getTransaction(txId),
    ).thenAnswer((_) async => Right(transaction));

    final result = await useCase(txId);

    expect(result, Right<Failure, TransactionEntity>(transaction));
  });

  test('forwards the Left branch from the repository unchanged', () async {
    const failure = ServerFailure('boom');
    when(
      () => mockRepository.getTransaction(txId),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase(txId);

    expect(result, const Left<Failure, TransactionEntity>(failure));
  });
}
