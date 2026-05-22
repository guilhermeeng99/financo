import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/pay_bill_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBillRepository repository;
  late PayBillUseCase useCase;

  const billId = 'bill-1';
  const accountId = 'acc-checking-1';
  const categoryId = 'cat-1';

  setUp(() {
    repository = MockBillRepository();
    useCase = PayBillUseCase(repository);
  });

  group('PayBillUseCase', () {
    test('forwards the payment result and passes its args through', () async {
      final paidBill = BillFactory.paid(id: billId);
      final transaction = TransactionFactory.expense(accountId: accountId);
      final paymentResult = BillPaymentResult(
        paidBill: paidBill,
        transaction: transaction,
      );
      when(
        () => repository.payBill(
          billId: any(named: 'billId'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, BillPaymentResult>(paymentResult),
      );

      final result = await useCase(
        billId: billId,
        accountId: accountId,
        categoryId: categoryId,
      );

      expect(result, Right<Failure, BillPaymentResult>(paymentResult));
      verify(
        () => repository.payBill(
          billId: billId,
          accountId: accountId,
          categoryId: categoryId,
        ),
      ).called(1);
    });

    test('surfaces the next occurrence when the bill is recurrent', () async {
      final paidBill = BillFactory.paid(
        id: billId,
        recurrence: BillRecurrence.monthly,
      );
      final nextOccurrence = BillFactory.monthly(
        id: 'bill-next',
        dueDate: DateTime(2026, 5),
      );
      final paymentResult = BillPaymentResult(
        paidBill: paidBill,
        transaction: TransactionFactory.expense(accountId: accountId),
        nextOccurrence: nextOccurrence,
      );
      when(
        () => repository.payBill(
          billId: any(named: 'billId'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, BillPaymentResult>(paymentResult),
      );

      final result = await useCase(
        billId: billId,
        accountId: accountId,
        categoryId: categoryId,
      );

      result.fold(
        (_) => fail('Expected a payment result'),
        (payment) => expect(payment.nextOccurrence, nextOccurrence),
      );
    });

    test('forwards a failure from the repository', () async {
      when(
        () => repository.payBill(
          billId: any(named: 'billId'),
          accountId: any(named: 'accountId'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, BillPaymentResult>(ServerFailure()),
      );

      final result = await useCase(
        billId: billId,
        accountId: accountId,
        categoryId: categoryId,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
