import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_scoped_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBillRepository repository;
  late UpdateBillScopedUseCase useCase;

  setUpAll(registerBillFallbackValues);

  setUp(() {
    repository = MockBillRepository();
    useCase = UpdateBillScopedUseCase(repository);
  });

  group('UpdateBillScopedUseCase', () {
    group('BillEditScope.onlyThis', () {
      test('updates only the chosen bill and never the chain', () async {
        final bill = BillFactory.monthly();
        when(() => repository.updateBill(any())).thenAnswer(
          (_) async => Right<Failure, BillEntity>(bill),
        );

        final result = await useCase(
          bill: bill,
          scope: BillEditScope.onlyThis,
        );

        expect(result, Right<Failure, BillEntity>(bill));
        verify(() => repository.updateBill(bill)).called(1);
        verifyNever(() => repository.updateBillAndSubsequents(any()));
      });

      test('forwards a failure from updateBill', () async {
        final bill = BillFactory.monthly();
        when(() => repository.updateBill(any())).thenAnswer(
          (_) async => const Left<Failure, BillEntity>(ServerFailure()),
        );

        final result = await useCase(
          bill: bill,
          scope: BillEditScope.onlyThis,
        );

        expect(result.isLeft(), isTrue);
        verifyNever(() => repository.updateBillAndSubsequents(any()));
      });
    });

    group('BillEditScope.alsoSubsequents', () {
      test('propagates the edit through updateBillAndSubsequents', () async {
        final bill = BillFactory.monthly();
        when(() => repository.updateBillAndSubsequents(any())).thenAnswer(
          (_) async => Right<Failure, BillEntity>(bill),
        );

        final result = await useCase(
          bill: bill,
          scope: BillEditScope.alsoSubsequents,
        );

        expect(result, Right<Failure, BillEntity>(bill));
        verify(() => repository.updateBillAndSubsequents(bill)).called(1);
        verifyNever(() => repository.updateBill(any()));
      });

      test('forwards a failure from updateBillAndSubsequents', () async {
        final bill = BillFactory.monthly();
        when(() => repository.updateBillAndSubsequents(any())).thenAnswer(
          (_) async => const Left<Failure, BillEntity>(ServerFailure()),
        );

        final result = await useCase(
          bill: bill,
          scope: BillEditScope.alsoSubsequents,
        );

        expect(result.isLeft(), isTrue);
        verifyNever(() => repository.updateBill(any()));
      });
    });
  });
}
