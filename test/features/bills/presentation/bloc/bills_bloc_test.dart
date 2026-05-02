import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetBillsUseCase getBills;
  late MockDeleteBillUseCase deleteBill;
  late MockPayBillUseCase payBill;
  late MockGetTransactionsUseCase getTransactions;
  late MockLinkBillToTransactionUseCase linkBillToTransaction;
  late MockRejectBillMatchUseCase rejectBillMatch;

  const userId = 'user-1';

  void stubEmptyTransactions() {
    when(
      () => getTransactions(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async =>
          const Right<Failure, List<TransactionEntity>>(<TransactionEntity>[]),
    );
  }

  setUp(() {
    getBills = MockGetBillsUseCase();
    deleteBill = MockDeleteBillUseCase();
    payBill = MockPayBillUseCase();
    getTransactions = MockGetTransactionsUseCase();
    linkBillToTransaction = MockLinkBillToTransactionUseCase();
    rejectBillMatch = MockRejectBillMatchUseCase();
    stubEmptyTransactions();
  });

  BillsBloc build() => BillsBloc(
    getBills: getBills,
    deleteBill: deleteBill,
    payBill: payBill,
    getTransactions: getTransactions,
    linkBillToTransaction: linkBillToTransaction,
    rejectBillMatch: rejectBillMatch,
    userId: userId,
  );

  group('BillsLoadRequested', () {
    final bills = [BillFactory.pending(), BillFactory.paid()];

    blocTest<BillsBloc, BillsState>(
      'emits [Loading, Loaded] on success',
      build: build,
      setUp: () {
        when(
          () => getBills(
            userId: any(named: 'userId'),
            status: any(named: 'status'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right<Failure, List<BillEntity>>(bills));
      },
      act: (bloc) => bloc.add(const BillsLoadRequested()),
      expect: () => [
        const BillsLoading(),
        isA<BillsLoaded>().having((s) => s.bills.length, 'bills.length', 2),
      ],
    );

    blocTest<BillsBloc, BillsState>(
      'short-circuits when already loaded with same filter and month',
      build: build,
      seed: () {
        final now = DateTime.now();
        return BillsLoaded(
          bills,
          targetYear: now.year,
          targetMonth: now.month,
        );
      },
      act: (bloc) {
        final now = DateTime.now();
        return bloc.add(
          BillsLoadRequested(year: now.year, month: now.month),
        );
      },
      expect: () => <BillsState>[],
    );

    blocTest<BillsBloc, BillsState>(
      'derives matchCandidates from bills + transactions',
      build: build,
      setUp: () {
        // The bill and tx share category, amount, day, and the type pairs up.
        final dueDate = DateTime(2026, 5);
        final bill = BillFactory.pending(amount: 200, dueDate: dueDate);
        final tx = TransactionFactory.expense(
          id: 'tx-match',
          amount: 200,
          date: dueDate,
        );
        when(
          () => getBills(
            userId: any(named: 'userId'),
            status: any(named: 'status'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right<Failure, List<BillEntity>>([bill]));
        when(
          () => getTransactions(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            accountId: any(named: 'accountId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, List<TransactionEntity>>([tx]),
        );
      },
      act: (bloc) => bloc.add(const BillsLoadRequested()),
      expect: () => [
        const BillsLoading(),
        isA<BillsLoaded>().having(
          (s) => s.matchCandidates.length,
          'matchCandidates.length',
          1,
        ),
      ],
    );
  });

  group('BillPaymentRequested', () {
    final bill = BillFactory.monthly();

    blocTest<BillsBloc, BillsState>(
      'emits [BillPaid, Loading, Loaded] on success',
      build: build,
      setUp: () {
        when(
          () => payBill(
            billId: any(named: 'billId'),
            accountId: any(named: 'accountId'),
            categoryId: any(named: 'categoryId'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, BillPaymentResult>(
            BillPaymentResult(
              paidBill: bill.copyWith(status: BillStatus.paid),
              transaction: TransactionFactory.expense(),
              nextOccurrence: BillFactory.monthly(id: 'bill-next'),
            ),
          ),
        );
        when(
          () => getBills(
            userId: any(named: 'userId'),
            status: any(named: 'status'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right<Failure, List<BillEntity>>([bill]));
      },
      act: (bloc) => bloc.add(
        const BillPaymentRequested(
          billId: 'bill-1',
          accountId: 'acc-1',
          categoryId: 'cat-1',
        ),
      ),
      expect: () => [
        isA<BillPaid>(),
        const BillsLoading(),
        isA<BillsLoaded>(),
      ],
    );
  });

  group('BillMatchAccepted', () {
    final bill = BillFactory.pending();

    blocTest<BillsBloc, BillsState>(
      'emits [BillPaid, Loading, Loaded] using existing transaction',
      build: build,
      setUp: () {
        final existingTx = TransactionFactory.expense(id: 'tx-existing');
        when(
          () => linkBillToTransaction(
            billId: any(named: 'billId'),
            transactionId: any(named: 'transactionId'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, BillPaymentResult>(
            BillPaymentResult(
              paidBill: bill.copyWith(
                status: BillStatus.paid,
                paidTransactionId: 'tx-existing',
              ),
              transaction: existingTx,
            ),
          ),
        );
        when(
          () => getBills(
            userId: any(named: 'userId'),
            status: any(named: 'status'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right<Failure, List<BillEntity>>([bill]));
      },
      act: (bloc) => bloc.add(
        const BillMatchAccepted(
          billId: 'bill-1',
          transactionId: 'tx-existing',
        ),
      ),
      expect: () => [
        isA<BillPaid>().having(
          (s) => s.result.transaction.id,
          'transaction.id',
          'tx-existing',
        ),
        const BillsLoading(),
        isA<BillsLoaded>(),
      ],
    );
  });

  group('BillMatchRejected', () {
    final bill = BillFactory.pending();

    blocTest<BillsBloc, BillsState>(
      'emits [Loading, Loaded] after appending the rejection',
      build: build,
      setUp: () {
        when(
          () => rejectBillMatch(
            billId: any(named: 'billId'),
            transactionId: any(named: 'transactionId'),
          ),
        ).thenAnswer(
          (_) async => Right<Failure, BillEntity>(
            bill.copyWith(rejectedTransactionIds: const ['tx-not-this']),
          ),
        );
        when(
          () => getBills(
            userId: any(named: 'userId'),
            status: any(named: 'status'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right<Failure, List<BillEntity>>([bill]));
      },
      act: (bloc) => bloc.add(
        const BillMatchRejected(
          billId: 'bill-1',
          transactionId: 'tx-not-this',
        ),
      ),
      expect: () => [
        const BillsLoading(),
        isA<BillsLoaded>(),
      ],
    );
  });
}
