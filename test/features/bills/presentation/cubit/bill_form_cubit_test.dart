import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_scoped_usecase.dart';
import 'package:financo/features/bills/presentation/cubit/bill_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateBillUseCase createBill;
  late MockUpdateBillScopedUseCase updateBillScoped;

  const userId = 'user-1';

  setUpAll(registerBillFallbackValues);

  setUp(() {
    createBill = MockCreateBillUseCase();
    updateBillScoped = MockUpdateBillScopedUseCase();
  });

  BillFormCubit build({BillEntity? existing}) => BillFormCubit(
    createBill: createBill,
    updateBillScoped: updateBillScoped,
    userId: userId,
    existingBill: existing,
  );

  group('validation', () {
    test('isValid is true with empty description (not required)', () {
      // Description is intentionally optional — list/sheet show a
      // type-based fallback when blank. Same behaviour as transactions.
      final cubit = build()
        ..updateAmount('120')
        ..updateCategoryId('cat-1');
      expect(cubit.state.isValid, isTrue);
      expect(cubit.state.description, isEmpty);
      addTearDown(cubit.close);
    });

    test('isValid is true once amount and category are set', () {
      final cubit = build()
        ..updateDescription('Internet')
        ..updateAmount('120')
        ..updateCategoryId('cat-1');
      expect(cubit.state.isValid, isTrue);
      addTearDown(cubit.close);
    });

    test('isValid is false when category is not set', () {
      final cubit = build()
        ..updateDescription('Internet')
        ..updateAmount('120');
      expect(cubit.state.isValid, isFalse);
      addTearDown(cubit.close);
    });

    test('isValid is false when amount is zero', () {
      final cubit = build()
        ..updateDescription('Internet')
        ..updateCategoryId('cat-1');
      expect(cubit.state.isValid, isFalse);
      addTearDown(cubit.close);
    });

    test('paid bills are not editable', () {
      final cubit = build(existing: BillFactory.paid());
      expect(cubit.state.isPaid, isTrue);
      expect(cubit.state.isValid, isFalse);
      addTearDown(cubit.close);
    });

    test('recurrence is immutable when editing', () {
      final cubit = build(
        existing: BillFactory.pending(recurrence: BillRecurrence.monthly),
      )..updateRecurrence(BillRecurrence.oneShot);
      expect(cubit.state.recurrence, BillRecurrence.monthly);
      addTearDown(cubit.close);
    });

    test('type defaults to payable for new bills', () {
      final cubit = build();
      expect(cubit.state.type, BillType.payable);
      addTearDown(cubit.close);
    });

    test('switching type clears the previously selected category', () {
      final cubit = build()
        ..updateCategoryId('cat-expense-1')
        ..updateType(BillType.receivable);
      expect(cubit.state.type, BillType.receivable);
      expect(cubit.state.categoryId, isNull);
      addTearDown(cubit.close);
    });

    test('type is immutable when editing', () {
      final cubit = build(existing: BillFactory.receivable())
        ..updateType(BillType.payable);
      expect(cubit.state.type, BillType.receivable);
      addTearDown(cubit.close);
    });
  });

  group('submit', () {
    blocTest<BillFormCubit, BillFormState>(
      'create path emits submitting → success',
      build: build,
      setUp: () {
        when(() => createBill(any())).thenAnswer(
          (invocation) async => Right<Failure, BillEntity>(
            invocation.positionalArguments.first as BillEntity,
          ),
        );
      },
      act: (cubit) async {
        cubit
          ..updateDescription('Conta de luz')
          ..updateAmount('200')
          ..updateCategoryId('cat-1');
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state.status, BillFormStatus.success);
        verify(() => createBill(any())).called(1);
      },
    );

    blocTest<BillFormCubit, BillFormState>(
      'edit path uses updateBillScoped instead of createBill',
      build: () => build(existing: BillFactory.pending()),
      setUp: () {
        when(
          () => updateBillScoped(
            bill: any(named: 'bill'),
            scope: any(named: 'scope'),
          ),
        ).thenAnswer(
          (invocation) async => Right<Failure, BillEntity>(
            invocation.namedArguments[#bill] as BillEntity,
          ),
        );
      },
      act: (cubit) async {
        cubit.updateAmount('150');
        await cubit.submit();
      },
      verify: (_) {
        verify(
          () => updateBillScoped(
            bill: any(named: 'bill'),
            scope: any(named: 'scope'),
          ),
        ).called(1);
        verifyNever(() => createBill(any()));
      },
    );

    blocTest<BillFormCubit, BillFormState>(
      'edit path forwards the chosen scope to updateBillScoped',
      build: () => build(
        existing: BillFactory.pending(recurrence: BillRecurrence.monthly),
      ),
      setUp: () {
        when(
          () => updateBillScoped(
            bill: any(named: 'bill'),
            scope: any(named: 'scope'),
          ),
        ).thenAnswer(
          (invocation) async => Right<Failure, BillEntity>(
            invocation.namedArguments[#bill] as BillEntity,
          ),
        );
      },
      act: (cubit) async {
        cubit.updateAmount('150');
        await cubit.submit(scope: BillEditScope.alsoSubsequents);
      },
      verify: (_) {
        verify(
          () => updateBillScoped(
            bill: any(named: 'bill'),
            scope: BillEditScope.alsoSubsequents,
          ),
        ).called(1);
      },
    );
  });
}
