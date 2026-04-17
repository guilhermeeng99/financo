import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late GetTransactionsUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  const userId = 'user-1';

  group('GetTransactionsUseCase', () {
    test('should return transactions from repository', () async {
      final transactions = TransactionFactory.list();
      when(
        () => mockRepository.getTransactions(userId: userId),
      ).thenAnswer((_) async => Right(transactions));

      final result = await useCase(userId: userId);

      expect(
        result,
        Right<Failure, List<TransactionEntity>>(transactions),
      );
      verify(() => mockRepository.getTransactions(userId: userId)).called(1);
    });

    test('should pass all filter parameters', () async {
      final start = DateTime(2024, 3);
      final end = DateTime(2024, 4);
      when(
        () => mockRepository.getTransactions(
          userId: userId,
          startDate: start,
          endDate: end,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          forceRefresh: true,
        ),
      ).thenAnswer((_) async => const Right([]));

      await useCase(
        userId: userId,
        startDate: start,
        endDate: end,
        accountId: 'acc-1',
        categoryId: 'cat-1',
        forceRefresh: true,
      );

      verify(
        () => mockRepository.getTransactions(
          userId: userId,
          startDate: start,
          endDate: end,
          accountId: 'acc-1',
          categoryId: 'cat-1',
          forceRefresh: true,
        ),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockRepository.getTransactions(userId: userId),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(userId: userId);

      expect(result, isA<Left<Failure, List<TransactionEntity>>>());
    });
  });
}
