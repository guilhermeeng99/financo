import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockBillRepository repository;
  late DeleteBillUseCase useCase;

  const billId = 'bill-1';

  setUp(() {
    repository = MockBillRepository();
    useCase = DeleteBillUseCase(repository);
  });

  group('DeleteBillUseCase', () {
    test('delegates to the repository with the given id', () async {
      when(() => repository.deleteBill(any())).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );

      final result = await useCase(billId);

      expect(result.isRight(), isTrue);
      verify(() => repository.deleteBill(billId)).called(1);
    });

    test('forwards a failure from the repository', () async {
      when(() => repository.deleteBill(any())).thenAnswer(
        (_) async => const Left<Failure, void>(ServerFailure()),
      );

      final result = await useCase(billId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
