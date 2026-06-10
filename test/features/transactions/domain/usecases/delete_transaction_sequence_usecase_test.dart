import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_sequence_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late DeleteTransactionSequenceUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = DeleteTransactionSequenceUseCase(mockRepository);
  });

  group('DeleteTransactionSequenceUseCase', () {
    test('onlyThis deletes only the selected transaction', () async {
      final transaction = TransactionFactory.expense(
        id: 'tx-1',
        recurrence: TransactionRecurrence.fixed,
        recurrenceGroupId: 'group-1',
      );
      when(
        () => mockRepository.deleteTransaction(any()),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(
        transaction: transaction,
        scope: TransactionSequenceScope.onlyThis,
      );

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.deleteTransaction('tx-1')).called(1);
      verifyNever(() => mockRepository.deleteTransactions(any()));
    });

    test(
      'thisAndFollowing deletes pending rows and stops fixed series',
      () async {
        final selected = _fixedTx(
          id: 'selected',
          dueDate: DateTime(2026, 6, 10),
          index: 2,
        );
        final previousPaid = _fixedTx(
          id: 'previous-paid',
          dueDate: DateTime(2026, 5, 10),
          index: 1,
          settlementStatus: TransactionSettlementStatus.paid,
        );
        final futurePending = _fixedTx(
          id: 'future-pending',
          dueDate: DateTime(2026, 7, 10),
          index: 3,
        );
        final futurePaid = _fixedTx(
          id: 'future-paid',
          dueDate: DateTime(2026, 8, 10),
          index: 4,
          settlementStatus: TransactionSettlementStatus.paid,
        );
        final transactions = [
          previousPaid,
          selected,
          futurePending,
          futurePaid,
        ];
        late List<TransactionEntity> stopUpdates;
        late List<String> deletedIds;

        when(
          () => mockRepository.getTransactions(
            userId: any(named: 'userId'),
            recurrenceGroupId: any(named: 'recurrenceGroupId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right(transactions));
        when(
          () => mockRepository.updateTransactions(any()),
        ).thenAnswer((invocation) async {
          stopUpdates =
              invocation.positionalArguments.first as List<TransactionEntity>;
          return Right(stopUpdates);
        });
        when(
          () => mockRepository.deleteTransactions(any()),
        ).thenAnswer((invocation) async {
          deletedIds = invocation.positionalArguments.first as List<String>;
          return const Right(null);
        });

        final result = await useCase(
          transaction: selected,
          scope: TransactionSequenceScope.thisAndFollowing,
        );

        expect(result, const Right<Failure, void>(null));
        expect(stopUpdates, hasLength(1));
        expect(stopUpdates.single.id, 'previous-paid');
        expect(stopUpdates.single.recurrenceEndDate, selected.dueDate);
        expect(deletedIds, ['selected', 'future-pending']);
        verifyNever(() => mockRepository.deleteTransaction(any()));
      },
    );
  });
}

TransactionEntity _fixedTx({
  required String id,
  required DateTime dueDate,
  required int index,
  TransactionSettlementStatus settlementStatus =
      TransactionSettlementStatus.pending,
}) {
  return TransactionFactory.expense(
    id: id,
    date: dueDate,
    dueDate: dueDate,
    settlementStatus: settlementStatus,
    recurrence: TransactionRecurrence.fixed,
    recurrenceGroupId: 'group-1',
    recurrenceIndex: index,
  );
}
