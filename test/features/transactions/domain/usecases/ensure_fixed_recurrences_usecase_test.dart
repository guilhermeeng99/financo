import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/ensure_fixed_recurrences_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late EnsureFixedRecurrencesUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = EnsureFixedRecurrencesUseCase(mockRepository);
  });

  group('EnsureFixedRecurrencesUseCase', () {
    test(
      'creates missing fixed occurrences for each recurrence group',
      () async {
        final latest = TransactionFactory.expense(
          id: 'latest',
          date: DateTime(2026, 6, 10),
          dueDate: DateTime(2026, 6, 10),
          settlementStatus: TransactionSettlementStatus.pending,
          recurrence: TransactionRecurrence.fixed,
          recurrenceGroupId: 'group-1',
          recurrenceIntervalMonths: 3,
          recurrenceIndex: 1,
        );
        late List<TransactionEntity> createdRows;

        when(
          () => mockRepository.getTransactions(
            userId: any(named: 'userId'),
            recurrence: any(named: 'recurrence'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right([latest]));
        when(
          () => mockRepository.createTransactions(any()),
        ).thenAnswer((invocation) async {
          createdRows =
              invocation.positionalArguments.first as List<TransactionEntity>;
          return Right(createdRows);
        });

        final result = await useCase(userId: 'user-1');

        expect(result.getOrElse(() => -1), createdRows.length);
        expect(createdRows, isNotEmpty);
        expect(
          createdRows.every(
            (tx) =>
                tx.recurrence == TransactionRecurrence.fixed &&
                tx.recurrenceGroupId == 'group-1' &&
                tx.isPending &&
                tx.dueDate.isAfter(latest.dueDate),
          ),
          isTrue,
        );
        verify(
          () => mockRepository.getTransactions(
            userId: 'user-1',
            recurrence: TransactionRecurrence.fixed,
            forceRefresh: true,
          ),
        ).called(1);
      },
    );

    test('does not recreate fixed rows after a sequence stop date', () async {
      final stopped = TransactionFactory.expense(
        id: 'stopped',
        date: DateTime(2026, 6, 10),
        dueDate: DateTime(2026, 6, 10),
        recurrence: TransactionRecurrence.fixed,
        recurrenceGroupId: 'group-1',
        recurrenceEndDate: DateTime(2026, 6, 10),
      );
      when(
        () => mockRepository.getTransactions(
          userId: any(named: 'userId'),
          recurrence: any(named: 'recurrence'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right([stopped]));

      final result = await useCase(userId: 'user-1');

      expect(result, const Right<Failure, int>(0));
      verifyNever(() => mockRepository.createTransactions(any()));
    });
  });
}
