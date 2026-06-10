import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transactions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late CreateTransactionsUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = CreateTransactionsUseCase(mockRepository);
  });

  group('CreateTransactionsUseCase', () {
    test('should delegate to repository.createTransactions', () async {
      final transactions = [
        TransactionFactory.expense(id: 'tx-1'),
        TransactionFactory.expense(id: 'tx-2'),
      ];
      when(
        () => mockRepository.createTransactions(any()),
      ).thenAnswer((_) async => Right(transactions));

      final result = await useCase(transactions);

      expect(result, Right<Failure, List<TransactionEntity>>(transactions));
      verify(() => mockRepository.createTransactions(transactions)).called(1);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockRepository.createTransactions(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Create failed')));

      final result = await useCase([TransactionFactory.expense()]);

      expect(result, isA<Left<Failure, List<TransactionEntity>>>());
    });
  });
}
