import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late CreateTransferUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = CreateTransferUseCase(mockRepository);
  });

  group('CreateTransferUseCase', () {
    test('should delegate to repository.createTransfer', () async {
      final pair = TransactionFactory.transfer();
      when(
        () => mockRepository.createTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      ).thenAnswer((_) async => Right([pair.expense, pair.income]));

      final result = await useCase(
        expense: pair.expense,
        income: pair.income,
      );

      expect(result.isRight(), isTrue);
      verify(
        () => mockRepository.createTransfer(
          expense: pair.expense,
          income: pair.income,
        ),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      final pair = TransactionFactory.transfer();
      when(
        () => mockRepository.createTransfer(
          expense: any(named: 'expense'),
          income: any(named: 'income'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to create transfer.')),
      );

      final result = await useCase(
        expense: pair.expense,
        income: pair.income,
      );

      expect(result, isA<Left<Failure, List<TransactionEntity>>>());
    });
  });
}
