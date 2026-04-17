import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/usecases/toggle_reconciled_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late ToggleReconciledUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = ToggleReconciledUseCase(mockRepository);
  });

  group('ToggleReconciledUseCase', () {
    const txId = 'tx-1';

    test('should delegate to repository.toggleReconciled', () async {
      when(
        () => mockRepository.toggleReconciled(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(txId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.toggleReconciled(txId)).called(1);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockRepository.toggleReconciled(any()),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Transaction not found.')),
      );

      final result = await useCase(txId);

      expect(result, isA<Left<Failure, void>>());
    });
  });
}
