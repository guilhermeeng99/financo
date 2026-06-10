import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteTransactionSequenceUseCase {
  const DeleteTransactionSequenceUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, void>> call({
    required TransactionEntity transaction,
    required TransactionSequenceScope scope,
  }) async {
    if (scope == TransactionSequenceScope.onlyThis ||
        !transaction.isRecurring) {
      return _repository.deleteTransaction(transaction.id);
    }

    final groupId = transaction.recurrenceGroupId;
    if (groupId == null || groupId.isEmpty) {
      return _repository.deleteTransaction(transaction.id);
    }

    final result = await _repository.getTransactions(
      userId: transaction.userId,
      recurrenceGroupId: groupId,
      forceRefresh: true,
    );

    return result.fold((failure) async => Left(failure), (transactions) async {
      final futurePending = transactions
          .where(
            (tx) =>
                tx.recurrenceGroupId == groupId &&
                tx.isPending &&
                !tx.dueDate.isBefore(transaction.dueDate),
          )
          .map((tx) => tx.id)
          .toList();

      final stopResult = await _stopFixedSequence(
        groupId: groupId,
        stopDate: transaction.dueDate,
        transactions: transactions,
      );
      final stopFailure = stopResult.fold((failure) => failure, (_) => null);
      if (stopFailure != null) return Left(stopFailure);

      if (futurePending.isEmpty) return const Right(null);
      return _repository.deleteTransactions(futurePending);
    });
  }

  Future<Either<Failure, List<TransactionEntity>>> _stopFixedSequence({
    required String groupId,
    required DateTime stopDate,
    required List<TransactionEntity> transactions,
  }) {
    final now = DateTime.now();
    final updates = transactions
        .where(
          (tx) =>
              tx.recurrenceGroupId == groupId &&
              tx.recurrence == TransactionRecurrence.fixed &&
              tx.dueDate.isBefore(stopDate) &&
              (tx.recurrenceEndDate == null ||
                  tx.recurrenceEndDate!.isAfter(stopDate)),
        )
        .map((tx) => tx.copyWith(recurrenceEndDate: stopDate, updatedAt: now))
        .toList();

    if (updates.isEmpty) return Future.value(const Right([]));
    return _repository.updateTransactions(updates);
  }
}
