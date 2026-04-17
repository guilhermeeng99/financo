import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late CreateTransactionUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = CreateTransactionUseCase(mockRepository);
  });

  group('CreateTransactionUseCase', () {
    test('should delegate to repository.createTransaction', () async {
      final transaction = TransactionFactory.expense();
      when(
        () => mockRepository.createTransaction(any()),
      ).thenAnswer((_) async => Right(transaction));

      final result = await useCase(transaction);

      expect(result, Right<Failure, TransactionEntity>(transaction));
      verify(() => mockRepository.createTransaction(transaction)).called(1);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockRepository.createTransaction(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Create failed')));

      final result = await useCase(TransactionFactory.expense());

      expect(result, isA<Left<Failure, TransactionEntity>>());
    });
  });
}
