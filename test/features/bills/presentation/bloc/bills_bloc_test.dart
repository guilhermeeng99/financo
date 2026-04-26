import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockGetBillsUseCase getBills;
  late MockDeleteBillUseCase deleteBill;
  late MockPayBillUseCase payBill;

  const userId = 'user-1';

  setUp(() {
    getBills = MockGetBillsUseCase();
    deleteBill = MockDeleteBillUseCase();
    payBill = MockPayBillUseCase();
  });

  BillsBloc build() => BillsBloc(
    getBills: getBills,
    deleteBill: deleteBill,
    payBill: payBill,
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
      'short-circuits when already loaded with same filter',
      build: build,
      seed: () => BillsLoaded(bills),
      act: (bloc) => bloc.add(const BillsLoadRequested()),
      expect: () => <BillsState>[],
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
}
