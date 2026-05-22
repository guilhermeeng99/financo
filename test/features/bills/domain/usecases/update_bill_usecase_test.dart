import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBillRepository repository;
  late UpdateBillUseCase useCase;

  setUpAll(registerBillFallbackValues);

  setUp(() {
    repository = MockBillRepository();
    useCase = UpdateBillUseCase(repository);
  });

  group('UpdateBillUseCase', () {
    test('delegates to the repository and forwards the updated bill', () async {
      final bill = BillFactory.pending(description: 'Internet Plus');
      when(() => repository.updateBill(any())).thenAnswer(
        (_) async => Right<Failure, BillEntity>(bill),
      );

      final result = await useCase(bill);

      expect(result, Right<Failure, BillEntity>(bill));
      verify(() => repository.updateBill(bill)).called(1);
    });

    test('forwards a failure from the repository', () async {
      final bill = BillFactory.pending();
      when(() => repository.updateBill(any())).thenAnswer(
        (_) async => const Left<Failure, BillEntity>(ServerFailure()),
      );

      final result = await useCase(bill);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
