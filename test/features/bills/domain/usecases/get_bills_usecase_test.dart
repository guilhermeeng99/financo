import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/bill_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockBillRepository repository;
  late GetBillsUseCase useCase;

  const userId = 'user-1';

  setUp(() {
    repository = MockBillRepository();
    useCase = GetBillsUseCase(repository);
  });

  group('GetBillsUseCase', () {
    test('forwards the repository list on success', () async {
      final bills = [BillFactory.pending(), BillFactory.paid()];
      when(
        () => repository.getBills(
          userId: any(named: 'userId'),
          status: any(named: 'status'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<BillEntity>>(bills),
      );

      final result = await useCase(userId: userId);

      expect(result, Right<Failure, List<BillEntity>>(bills));
    });

    test('passes status and forceRefresh through to the repository', () async {
      when(
        () => repository.getBills(
          userId: any(named: 'userId'),
          status: any(named: 'status'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<BillEntity>>(<BillEntity>[]),
      );

      await useCase(
        userId: userId,
        status: BillStatus.pending,
        forceRefresh: true,
      );

      verify(
        () => repository.getBills(
          userId: userId,
          status: BillStatus.pending,
          forceRefresh: true,
        ),
      ).called(1);
    });

    test('forwards a failure from the repository', () async {
      when(
        () => repository.getBills(
          userId: any(named: 'userId'),
          status: any(named: 'status'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<BillEntity>>(ServerFailure()),
      );

      final result = await useCase(userId: userId);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected ServerFailure'),
      );
    });
  });
}
