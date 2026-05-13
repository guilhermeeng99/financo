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

    // Use a future dueDate so the "next occurrence" assertion stays exact
    // regardless of when the test runs. The settlement flow fast-forwards
    // when the original is older than today (covered separately by the
    // `nextMonthlyDueDateAfter` unit tests); here we want to verify the
    // base case where one calendar step lands in the future.
    final monthlyBill = BillFactory.monthly(
      dueDate: DateTime(2099, 1, 31),
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
        // Jan 31 → Feb 28 (2099 is not a leap year). The base dueDate is
        // far in the future so no fast-forward kicks in for this case.
        expect(payment.nextOccurrence!.dueDate, DateTime(2099, 2, 28));
        expect(payment.nextOccurrence!.parentBillId, 'bill-monthly');
        expect(payment.nextOccurrence!.status, BillStatus.pending);
      },
    );
  });

  group('linkBillToExistingTransaction', () {
    test(
      'marks the bill paid against the existing tx without creating one',
      () async {
        final bill = BillFactory.pending(amount: 200);
        when(() => dao.getBillById('bill-1')).thenAnswer((_) async => bill);

        final existingTx = TransactionFactory.expense(
          id: 'tx-existing',
          amount: 200,
        );
        when(() => transactionRepo.getTransaction('tx-existing')).thenAnswer(
          (_) async => Right<Failure, TransactionEntity>(existingTx),
        );

        when(() => remote.updateBill(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments.first as BillModel,
        );

        final result = await repository.linkBillToExistingTransaction(
          billId: 'bill-1',
          transactionId: 'tx-existing',
        );

        expect(result.isRight(), isTrue);
        final payment = result.getOrElse(() => throw StateError('expected'));
        expect(payment.transaction.id, 'tx-existing');
        expect(payment.paidBill.status, BillStatus.paid);
        expect(payment.paidBill.paidTransactionId, 'tx-existing');
        verifyNever(() => transactionRepo.createTransaction(any()));
      },
    );

    test('rejects when the bill is already paid', () async {
      final paidBill = BillFactory.paid(id: 'bill-1');
      when(() => dao.getBillById('bill-1')).thenAnswer((_) async => paidBill);

      final result = await repository.linkBillToExistingTransaction(
        billId: 'bill-1',
        transactionId: 'tx-anything',
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.swap().getOrElse(() => throw StateError('x')),
        isA<ValidationFailure>(),
      );
      verifyNever(() => transactionRepo.getTransaction(any()));
    });

    test('monthly bill linked to tx still creates next occurrence', () async {
      // Future dueDate keeps the assertion deterministic — see the
      // `payBill` group above for the same rationale.
      final monthly = BillFactory.monthly(dueDate: DateTime(2099, 1, 31));
      when(() => dao.getBillById('bill-monthly'))
          .thenAnswer((_) async => monthly);

      final existingTx = TransactionFactory.expense(
        id: 'tx-existing',
        amount: monthly.amount,
      );
      when(() => transactionRepo.getTransaction('tx-existing')).thenAnswer(
        (_) async => Right<Failure, TransactionEntity>(existingTx),
      );
      when(() => remote.updateBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );
      when(() => remote.createBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );

      final result = await repository.linkBillToExistingTransaction(
        billId: 'bill-monthly',
        transactionId: 'tx-existing',
      );

      final payment = result.getOrElse(() => throw StateError('expected'));
      expect(payment.nextOccurrence?.dueDate, DateTime(2099, 2, 28));
      expect(payment.nextOccurrence?.parentBillId, 'bill-monthly');
    });

    test(
      'fast-forwards next occurrence past today when settling a late bill',
      () async {
        // Bill due 6 months ago — paying it today should NOT spawn an
        // occurrence with a stale dueDate (which would trigger
        // notifyBillsDue tomorrow morning, then again the next day, etc.).
        final today = DateTime.now();
        final staleDueDate = DateTime(today.year, today.month - 6);
        final stale = BillFactory.monthly(
          id: 'bill-stale',
          dueDate: staleDueDate,
        );
        when(() => dao.getBillById('bill-stale'))
            .thenAnswer((_) async => stale);

        final existingTx = TransactionFactory.expense(
          id: 'tx-existing',
          amount: stale.amount,
        );
        when(() => transactionRepo.getTransaction('tx-existing')).thenAnswer(
          (_) async => Right<Failure, TransactionEntity>(existingTx),
        );
        when(() => remote.updateBill(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments.first as BillModel,
        );
        when(() => remote.createBill(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments.first as BillModel,
        );

        final result = await repository.linkBillToExistingTransaction(
          billId: 'bill-stale',
          transactionId: 'tx-existing',
        );

        final payment = result.getOrElse(() => throw StateError('expected'));
        final nextDue = payment.nextOccurrence!.dueDate;
        // Newly-created occurrence must NOT be already overdue — otherwise
        // the daily Cloud Function notification keeps firing on stale chains.
        final startOfToday = DateTime(today.year, today.month, today.day);
        expect(
          nextDue.isBefore(startOfToday),
          isFalse,
          reason: 'next occurrence must not be born overdue',
        );
        // Day-of-month from the original bill is preserved (clamped).
        expect(nextDue.day, stale.dueDate.day);
      },
    );
  });

  group('updateBillAndSubsequents', () {
    test('updates only the source when chain has no descendants', () async {
      final lone = BillFactory.monthly(
        id: 'bill-lone',
        dueDate: DateTime(2026, 5),
      );
      when(() => dao.getBills(userId: any(named: 'userId')))
          .thenAnswer((_) async => [lone]);
      when(() => remote.updateBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );

      final edited = lone.copyWith(amount: 2500);
      final result = await repository.updateBillAndSubsequents(edited);

      expect(result.isRight(), isTrue);
      // Single update — no subsequents to propagate to.
      verify(() => remote.updateBill(any())).called(1);
    });

    test('propagates non-temporal fields + day-of-month to subsequents',
        () async {
      // Chain: mai (source) → jun → jul. User edits mai's amount + day.
      final mai = BillFactory.monthly(
        id: 'bill-mai',
        amount: 2000,
        dueDate: DateTime(2026, 5),
      );
      final jun = BillFactory.monthly(
        id: 'bill-jun',
        amount: 2000,
        dueDate: DateTime(2026, 6),
      ).copyWith(parentBillId: 'bill-mai');
      final jul = BillFactory.monthly(
        id: 'bill-jul',
        amount: 2000,
        dueDate: DateTime(2026, 7),
      ).copyWith(parentBillId: 'bill-jun');

      when(() => dao.getBills(userId: any(named: 'userId')))
          .thenAnswer((_) async => [mai, jun, jul]);
      when(() => remote.updateBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );
      when(() => remote.updateBillsBatch(any())).thenAnswer((_) async {});

      // Edit: amount 2000 → 2500, dueDate from day 1 → day 5.
      final edited = mai.copyWith(
        amount: 2500,
        dueDate: DateTime(2026, 5, 5),
      );
      final result = await repository.updateBillAndSubsequents(edited);

      expect(result.isRight(), isTrue);
      // Source goes through `updateBill`; descendants go through the
      // atomic `updateBillsBatch`. Verify each individually.
      final sourceCaptured = verify(
        () => remote.updateBill(captureAny()),
      ).captured.cast<BillModel>();
      expect(sourceCaptured, hasLength(1));
      expect(sourceCaptured.first.id, 'bill-mai');
      expect(sourceCaptured.first.amount, 2500);
      expect(sourceCaptured.first.dueDate, DateTime(2026, 5, 5));

      final batchCaptured = verify(
        () => remote.updateBillsBatch(captureAny()),
      ).captured.cast<List<BillModel>>();
      expect(batchCaptured, hasLength(1));
      final byId = {for (final m in batchCaptured.first) m.id: m};
      expect(byId['bill-jun']!.amount, 2500);
      expect(byId['bill-jun']!.dueDate, DateTime(2026, 6, 5));
      expect(byId['bill-jul']!.amount, 2500);
      expect(byId['bill-jul']!.dueDate, DateTime(2026, 7, 5));
    });

    test('clamps day-of-month for descendants whose month is shorter',
        () async {
      // jan (source, day 31) → feb (April-like with 30 days actually, but
      // we use Feb on purpose: 28 days in 2026 → must clamp 31 → 28).
      final jan = BillFactory.monthly(
        id: 'bill-jan',
        dueDate: DateTime(2026, 1, 31),
      );
      final feb = BillFactory.monthly(
        id: 'bill-feb',
        dueDate: DateTime(2026, 2, 28),
      ).copyWith(parentBillId: 'bill-jan');

      when(() => dao.getBills(userId: any(named: 'userId')))
          .thenAnswer((_) async => [jan, feb]);
      when(() => remote.updateBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );
      when(() => remote.updateBillsBatch(any())).thenAnswer((_) async {});

      // Source stays on day 31 — day 31 must clamp to Feb's last day (28).
      final result = await repository.updateBillAndSubsequents(
        jan.copyWith(amount: 2500),
      );
      expect(result.isRight(), isTrue);

      final sourceCaptured = verify(
        () => remote.updateBill(captureAny()),
      ).captured.cast<BillModel>();
      expect(sourceCaptured.first.id, 'bill-jan');
      expect(sourceCaptured.first.dueDate, DateTime(2026, 1, 31));

      final batchCaptured = verify(
        () => remote.updateBillsBatch(captureAny()),
      ).captured.cast<List<BillModel>>();
      final byId = {for (final m in batchCaptured.first) m.id: m};
      // Feb 31 → clamped to Feb 28 (2026 is not a leap year).
      expect(byId['bill-feb']!.dueDate, DateTime(2026, 2, 28));
    });

    test('does not mutate paid descendants', () async {
      final mai = BillFactory.monthly(
        id: 'bill-mai',
        amount: 2000,
        dueDate: DateTime(2026, 5),
      );
      final junPaid = BillFactory.paid(
        id: 'bill-jun',
        recurrence: BillRecurrence.monthly,
        dueDate: DateTime(2026, 6),
      ).copyWith(parentBillId: 'bill-mai');
      final julPending = BillFactory.monthly(
        id: 'bill-jul',
        amount: 2000,
        dueDate: DateTime(2026, 7),
      ).copyWith(parentBillId: 'bill-jun');

      when(() => dao.getBills(userId: any(named: 'userId')))
          .thenAnswer((_) async => [mai, junPaid, julPending]);
      when(() => remote.updateBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );
      when(() => remote.updateBillsBatch(any())).thenAnswer((_) async {});

      final edited = mai.copyWith(amount: 2500);
      final result = await repository.updateBillAndSubsequents(edited);
      expect(result.isRight(), isTrue);

      final sourceCaptured = verify(
        () => remote.updateBill(captureAny()),
      ).captured.cast<BillModel>();
      expect(sourceCaptured.first.id, 'bill-mai');

      final batchCaptured = verify(
        () => remote.updateBillsBatch(captureAny()),
      ).captured.cast<List<BillModel>>();
      final byId = {for (final m in batchCaptured.first) m.id: m};
      // jul (descendant of paid jun) updated; paid jun walked through but
      // never written.
      expect(byId.keys, contains('bill-jul'));
      expect(byId.containsKey('bill-jun'), isFalse);
      expect(byId['bill-jul']!.amount, 2500);
    });
  });

  group('rejectBillTransactionMatch', () {
    test('appends the transaction id to rejectedTransactionIds', () async {
      final bill = BillFactory.pending();
      when(() => dao.getBillById('bill-1')).thenAnswer((_) async => bill);
      when(() => remote.updateBill(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as BillModel,
      );

      final result = await repository.rejectBillTransactionMatch(
        billId: 'bill-1',
        transactionId: 'tx-not-this',
      );

      expect(result.isRight(), isTrue);
      final updated = result.getOrElse(() => throw StateError('expected'));
      expect(updated.rejectedTransactionIds, contains('tx-not-this'));
    });

    test('is idempotent — rejecting the same tx twice keeps a single id',
        () async {
      final alreadyRejected = BillFactory.pending().copyWith(
        rejectedTransactionIds: const ['tx-not-this'],
      );
      when(() => dao.getBillById('bill-1'))
          .thenAnswer((_) async => alreadyRejected);

      final result = await repository.rejectBillTransactionMatch(
        billId: 'bill-1',
        transactionId: 'tx-not-this',
      );

      expect(result.isRight(), isTrue);
      // No remote write needed when the id is already rejected.
      verifyNever(() => remote.updateBill(any()));
    });
  });
}
