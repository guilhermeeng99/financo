import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/cubit/bill_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCreateBillUseCase createBill;
  late MockUpdateBillUseCase updateBill;

  const userId = 'user-1';

  setUpAll(registerBillFallbackValues);

  setUp(() {
    createBill = MockCreateBillUseCase();
    updateBill = MockUpdateBillUseCase();
  });

  BillFormCubit build({BillEntity? existing}) => BillFormCubit(
    createBill: createBill,
    updateBill: updateBill,
    userId: userId,
    existingBill: existing,
  );

  group('validation', () {
    test('isValid is false when description is empty', () {
      final cubit = build();
      expect(cubit.state.isValid, isFalse);
      addTearDown(cubit.close);
    });

    test('isValid is true once description and amount are set', () {
      final cubit = build()
        ..updateDescription('Internet')
        ..updateAmount('120');
      expect(cubit.state.isValid, isTrue);
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
          ..updateAmount('200');
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state.status, BillFormStatus.success);
        verify(() => createBill(any())).called(1);
      },
    );

    blocTest<BillFormCubit, BillFormState>(
      'edit path uses updateBill instead of createBill',
      build: () => build(existing: BillFactory.pending()),
      setUp: () {
        when(() => updateBill(any())).thenAnswer(
          (invocation) async => Right<Failure, BillEntity>(
            invocation.positionalArguments.first as BillEntity,
          ),
        );
      },
      act: (cubit) async {
        cubit.updateAmount('150');
        await cubit.submit();
      },
      verify: (_) {
        verify(() => updateBill(any())).called(1);
        verifyNever(() => createBill(any()));
      },
    );
  });
}
