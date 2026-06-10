import 'package:dartz/dartz.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/update_transaction_sequence_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late UpdateTransactionSequenceUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUpAll(registerTransactionFallbackValues);

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = UpdateTransactionSequenceUseCase(mockRepository);
  });

  group('UpdateTransactionSequenceUseCase', () {
    test('onlyThis delegates to repository.updateTransaction', () async {
      final transaction = _installmentTx(id: 'tx-1');
      when(
        () => mockRepository.updateTransaction(any()),
      ).thenAnswer((_) async => Right(transaction));

      final result = await useCase(
        original: transaction,
        updated: transaction.copyWith(amount: 99),
        scope: TransactionSequenceScope.onlyThis,
      );

      expect(result.getOrElse(() => []), [transaction]);
      verify(() => mockRepository.updateTransaction(any())).called(1);
      verifyNever(() => mockRepository.updateTransactions(any()));
    });

    test(
      'thisAndFollowing updates only pending selected and following rows',
      () async {
        final original = _installmentTx(
          id: 'selected',
          dueDate: DateTime(2026, 6, 10),
        );
        final futurePending = _installmentTx(
          id: 'future-pending',
          dueDate: DateTime(2026, 7, 10),
          index: 2,
        );
        final futurePaid = _installmentTx(
          id: 'future-paid',
          dueDate: DateTime(2026, 8, 10),
          index: 3,
          settlementStatus: TransactionSettlementStatus.paid,
        );
        final updated = original.copyWith(
          amount: 99,
          description: 'Notebook',
          recurrenceBaseDescription: 'Notebook',
        );
        late List<TransactionEntity> updatedRows;

        when(
          () => mockRepository.getTransactions(
            userId: any(named: 'userId'),
            dueStartDate: any(named: 'dueStartDate'),
            recurrenceGroupId: any(named: 'recurrenceGroupId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right([original, futurePending, futurePaid]));
        when(
          () => mockRepository.updateTransactions(any()),
        ).thenAnswer((invocation) async {
          updatedRows =
              invocation.positionalArguments.first as List<TransactionEntity>;
          return Right(updatedRows);
        });

        final result = await useCase(
          original: original,
          updated: updated,
          scope: TransactionSequenceScope.thisAndFollowing,
        );

        expect(result.getOrElse(() => []), updatedRows);
        expect(updatedRows.map((tx) => tx.id), ['selected', 'future-pending']);
        expect(updatedRows.every((tx) => tx.amount == 99), isTrue);
        expect(updatedRows.map((tx) => tx.description), [
          'Notebook 1/3',
          'Notebook 2/3',
        ]);
        verifyNever(() => mockRepository.updateTransaction(any()));
      },
    );
  });
}

TransactionEntity _installmentTx({
  required String id,
  int index = 1,
  DateTime? dueDate,
  TransactionSettlementStatus settlementStatus =
      TransactionSettlementStatus.pending,
}) {
  final date = dueDate ?? DateTime(2026, 6, 10);
  return TransactionFactory.expense(
    id: id,
    date: date,
    dueDate: date,
    amount: 50,
    description: 'Old $index/3',
    settlementStatus: settlementStatus,
    recurrence: TransactionRecurrence.installment,
    recurrenceGroupId: 'group-1',
    recurrenceIndex: index,
    recurrenceTotal: 3,
    recurrenceBaseDescription: 'Old',
  );
}
