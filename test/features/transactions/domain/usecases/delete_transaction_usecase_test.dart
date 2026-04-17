import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late DeleteTransactionUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = DeleteTransactionUseCase(mockRepository);
  });

  group('DeleteTransactionUseCase', () {
    const txId = 'tx-1';

    test('should delegate to repository.deleteTransaction', () async {
      when(
        () => mockRepository.deleteTransaction(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(txId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.deleteTransaction(txId)).called(1);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockRepository.deleteTransaction(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

      final result = await useCase(txId);

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
