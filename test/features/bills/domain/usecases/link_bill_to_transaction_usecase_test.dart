import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/link_bill_to_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBillRepository repository;
  late LinkBillToTransactionUseCase useCase;

  const billId = 'bill-1';
  const transactionId = 'tx-existing-1';

  setUp(() {
    repository = MockBillRepository();
    useCase = LinkBillToTransactionUseCase(repository);
  });

  group('LinkBillToTransactionUseCase', () {
    test('settles the bill against the existing transaction', () async {
      final paymentResult = BillPaymentResult(
        paidBill: BillFactory.paid(
          id: billId,
          paidTransactionId: transactionId,
        ),
        transaction: TransactionFactory.expense(id: transactionId),
      );
      when(
        () => repository.linkBillToExistingTransaction(
          billId: any(named: 'billId'),
          transactionId: any(named: 'transactionId'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, BillPaymentResult>(paymentResult),
      );

      final result = await useCase(
        billId: billId,
        transactionId: transactionId,
      );

      expect(result, Right<Failure, BillPaymentResult>(paymentResult));
      verify(
        () => repository.linkBillToExistingTransaction(
          billId: billId,
          transactionId: transactionId,
        ),
      ).called(1);
    });

    test('forwards a failure from the repository', () async {
      when(
        () => repository.linkBillToExistingTransaction(
          billId: any(named: 'billId'),
          transactionId: any(named: 'transactionId'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, BillPaymentResult>(ServerFailure()),
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
