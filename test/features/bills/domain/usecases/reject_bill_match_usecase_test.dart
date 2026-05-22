import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/reject_bill_match_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBillRepository repository;
  late RejectBillMatchUseCase useCase;

  const billId = 'bill-1';
  const transactionId = 'tx-not-this-1';

  setUp(() {
    repository = MockBillRepository();
    useCase = RejectBillMatchUseCase(repository);
  });

  group('RejectBillMatchUseCase', () {
    test('forwards the bill with the rejected transaction recorded', () async {
      // The factory default id already equals `billId`.
      final bill = BillFactory.pending().copyWith(
        rejectedTransactionIds: const [transactionId],
      );
      when(
        () => repository.rejectBillTransactionMatch(
          billId: any(named: 'billId'),
          transactionId: any(named: 'transactionId'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, BillEntity>(bill),
      );

      final result = await useCase(
        billId: billId,
        transactionId: transactionId,
      );

      expect(result, Right<Failure, BillEntity>(bill));
      verify(
        () => repository.rejectBillTransactionMatch(
          billId: billId,
          transactionId: transactionId,
        ),
      ).called(1);
    });

    test('forwards a failure from the repository', () async {
      when(
        () => repository.rejectBillTransactionMatch(
          billId: any(named: 'billId'),
          transactionId: any(named: 'transactionId'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, BillEntity>(ServerFailure()),
      );

      final result = await useCase(
        billId: billId,
        transactionId: transactionId,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
