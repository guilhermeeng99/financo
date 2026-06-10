import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financo/features/transactions/domain/services/recurring_transaction_builder.dart';

class UpdateTransactionSequenceUseCase {
  const UpdateTransactionSequenceUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, List<TransactionEntity>>> call({
    required TransactionEntity original,
    required TransactionEntity updated,
    required TransactionSequenceScope scope,
  }) async {
    if (scope == TransactionSequenceScope.onlyThis || !original.isRecurring) {
      return (await _repository.updateTransaction(updated)).map((tx) => [tx]);
    }

    final groupId = original.recurrenceGroupId;
    if (groupId == null || groupId.isEmpty) {
      return (await _repository.updateTransaction(updated)).map((tx) => [tx]);
    }

    final result = await _repository.getTransactions(
      userId: original.userId,
      dueStartDate: original.dueDate,
      recurrenceGroupId: groupId,
      forceRefresh: true,
    );

    return result.fold((failure) async => Left(failure), (transactions) async {
      final pending =
          transactions
              .where(
                (tx) =>
                    tx.recurrenceGroupId == groupId &&
                    tx.isPending &&
                    !tx.dueDate.isBefore(original.dueDate),
              )
              .toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

      if (pending.isEmpty) return const Right([]);
      return _repository.updateTransactions(
        _updatedPendingSequence(
          original: original,
          updated: updated,
          transactions: pending,
        ),
      );
    });
  }
}

List<TransactionEntity> _updatedPendingSequence({
  required TransactionEntity original,
  required TransactionEntity updated,
  required List<TransactionEntity> transactions,
}) {
  final baseIndex =
      original.recurrenceIndex ?? transactions.first.recurrenceIndex ?? 1;
  final baseDescription =
      updated.recurrenceBaseDescription ?? updated.description;
  final interval = _safeInterval(updated.recurrenceIntervalMonths);
  final now = DateTime.now();

  return [
    for (final tx in transactions)
      _copySequenceFields(
        current: tx,
        updated: updated,
        dueDate: addMonthsClamped(
          updated.dueDate,
          ((tx.recurrenceIndex ?? baseIndex) - baseIndex) * interval,
        ),
        baseDescription: baseDescription,
        now: now,
      ),
  ];
}

int _safeInterval(int value) {
  if (value < 1) return 1;
  if (value > 12) return 12;
  return value;
}

TransactionEntity _copySequenceFields({
  required TransactionEntity current,
  required TransactionEntity updated,
  required DateTime dueDate,
  required String baseDescription,
  required DateTime now,
}) {
  final total = current.recurrenceTotal ?? updated.recurrenceTotal;
  final index = current.recurrenceIndex ?? updated.recurrenceIndex ?? 1;
  final description = current.recurrence == TransactionRecurrence.installment
      ? installmentDescription(
          baseDescription: baseDescription,
          index: index,
          total: total ?? index,
        )
      : updated.description;
  final isSelected = current.id == updated.id;
  final settlementStatus = isSelected
      ? updated.settlementStatus
      : TransactionSettlementStatus.pending;

  return TransactionEntity(
    id: current.id,
    userId: current.userId,
    accountId: updated.accountId,
    categoryId: updated.categoryId,
    type: updated.type,
    amount: updated.amount,
    description: description,
    date: dueDate,
    settlementStatus: settlementStatus,
    dueDate: dueDate,
    settledAt: settlementStatus == TransactionSettlementStatus.paid
        ? dueDate
        : null,
    recurrence: current.recurrence,
    recurrenceGroupId: current.recurrenceGroupId,
    recurrenceIntervalMonths: updated.recurrenceIntervalMonths,
    recurrenceIndex: current.recurrenceIndex,
    recurrenceTotal: total,
    recurrenceBaseDescription: baseDescription,
    recurrenceEndDate: current.recurrenceEndDate,
    notes: updated.notes,
    linkedTransactionId: current.linkedTransactionId,
    createdAt: current.createdAt,
    updatedAt: now,
  );
}
