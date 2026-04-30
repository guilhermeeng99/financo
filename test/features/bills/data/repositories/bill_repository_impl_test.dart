import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/data/models/bill_model.dart';
import 'package:financo/features/bills/data/repositories/bill_repository_impl.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBillRemoteDataSource remote;
  late MockBillsDao dao;
  late MockTransactionRepository transactionRepo;
  late BillRepositoryImpl repository;

  setUpAll(() {
    registerBillFallbackValues();
    registerTransactionFallbackValues();
  });

  setUp(() {
    remote = MockBillRemoteDataSource();
    dao = MockBillsDao();
    transactionRepo = MockTransactionRepository();
    repository = BillRepositoryImpl(
      remoteDataSource: remote,
      billsDao: dao,
      transactionRepository: transactionRepo,
    );

    when(() => dao.upsertBill(any())).thenAnswer((_) async {});
    when(() => dao.insertAllBills(any())).thenAnswer((_) async {});
  });

  group('payBill', () {
    final bill = BillFactory.pending(
      amount: 200,
      dueDate: DateTime(2026, 4, 30),
    );

    final monthlyBill = BillFactory.monthly(
      dueDate: DateTime(2026, 1, 31),
    );

    test('creates a transaction and marks the bill as paid', () async {
      when(() => dao.getBillById('bill-1')).thenAnswer((_) async => bill);

      final tx = TransactionFactory.expense(id: 'tx-paid', amount: 200);
      when(() => transactionRepo.createTransaction(any()))
          .thenAnswer((_) async => Right<Failure, TransactionEntity>(tx));

      // updateBill via remote+dao path:
      when(() => remote.updateBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );

      final result = await repository.payBill(
        billId: 'bill-1',
        accountId: 'acc-checking',
        categoryId: 'cat-bills',
      );

      expect(result.isRight(), isTrue);
      final payment = result.getOrElse(() => throw StateError('expected'));
      expect(payment.transaction.id, 'tx-paid');
      expect(payment.paidBill.status, BillStatus.paid);
      expect(payment.paidBill.paidTransactionId, 'tx-paid');
      expect(payment.nextOccurrence, isNull);

      // Transaction was created with the bill's amount + chosen account/cat.
      final captured = verify(
        () => transactionRepo.createTransaction(captureAny()),
      ).captured.single as TransactionEntity;
      expect(captured.amount, 200);
      expect(captured.accountId, 'acc-checking');
      expect(captured.categoryId, 'cat-bills');
      expect(captured.type, TransactionType.expense);
    });

    test('rejects when bill is already paid', () async {
      final paidBill = BillFactory.paid(id: 'bill-1');
      when(() => dao.getBillById('bill-1')).thenAnswer((_) async => paidBill);

      final result = await repository.payBill(
        billId: 'bill-1',
        accountId: 'acc-1',
        categoryId: 'cat-1',
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.swap().getOrElse(() => throw StateError('x')),
        isA<ValidationFailure>(),
      );
      verifyNever(() => transactionRepo.createTransaction(any()));
    });

    test('receivable bill creates an income transaction', () async {
      final receivable = BillFactory.receivable();
      when(
        () => dao.getBillById('bill-receivable'),
      ).thenAnswer((_) async => receivable);

      final tx = TransactionFactory.expense(
        id: 'tx-paid',
        amount: receivable.amount,
      );
      when(() => transactionRepo.createTransaction(any())).thenAnswer(
        (_) async => Right<Failure, TransactionEntity>(tx),
      );
      when(() => remote.updateBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );
      when(() => remote.createBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );

      final result = await repository.payBill(
        billId: 'bill-receivable',
        accountId: 'acc-checking',
        categoryId: 'cat-salary',
      );

      expect(result.isRight(), isTrue);
      final captured = verify(
        () => transactionRepo.createTransaction(captureAny()),
      ).captured.single as TransactionEntity;
      expect(captured.type, TransactionType.income);
      expect(captured.amount, receivable.amount);

      // Receivable monthly bills also generate the next occurrence preserving
      // the type.
      final payment = result.getOrElse(() => throw StateError('expected'));
      expect(payment.nextOccurrence?.type, BillType.receivable);
    });

    test(
      'monthly recurrence creates next occurrence with clamped due date',
      () async {
        when(() => dao.getBillById('bill-monthly'))
            .thenAnswer((_) async => monthlyBill);

        final tx = TransactionFactory.expense(id: 'tx-paid', amount: 120);
        when(() => transactionRepo.createTransaction(any()))
            .thenAnswer((_) async => Right<Failure, TransactionEntity>(tx));
        when(() => remote.updateBill(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments.first as BillModel,
        );
        when(() => remote.createBill(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments.first as BillModel,
        );

        final result = await repository.payBill(
          billId: 'bill-monthly',
          accountId: 'acc',
          categoryId: 'cat',
        );

        expect(result.isRight(), isTrue);
        final payment = result.getOrElse(() => throw StateError('expected'));
        expect(payment.nextOccurrence, isNotNull);
        // Jan 31 → Feb 28 (2026 is not a leap year).
        expect(payment.nextOccurrence!.dueDate, DateTime(2026, 2, 28));
        expect(payment.nextOccurrence!.parentBillId, 'bill-monthly');
        expect(payment.nextOccurrence!.status, BillStatus.pending);
      },
    );
  });
}
