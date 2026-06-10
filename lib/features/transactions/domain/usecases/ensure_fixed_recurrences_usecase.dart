import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:financo/features/transactions/domain/services/recurring_transaction_builder.dart';

class EnsureFixedRecurrencesUseCase {
  const EnsureFixedRecurrencesUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, int>> call({required String userId}) async {
    final result = await _repository.getTransactions(
      userId: userId,
      recurrence: TransactionRecurrence.fixed,
      forceRefresh: true,
    );

    return result.fold((failure) async => Left(failure), (transactions) async {
      final missing = <TransactionEntity>[];
      final now = DateTime.now();
      for (final group in _groups(transactions).values) {
        final latest = _latestByDueDate(group);
        if (latest == null) continue;
        final stopDate = _stopDate(group);
        missing.addAll(
          buildMissingFixedOccurrences(
            latest: stopDate == null
                ? latest
                : latest.copyWith(recurrenceEndDate: stopDate),
            now: now,
          ),
        );
      }

      if (missing.isEmpty) return const Right(0);
      return (await _repository.createTransactions(missing)).map(
        (created) => created.length,
      );
    });
  }
}

Map<String, List<TransactionEntity>> _groups(
  List<TransactionEntity> transactions,
) {
  final groups = <String, List<TransactionEntity>>{};
  for (final tx in transactions) {
    final groupId = tx.recurrenceGroupId;
    if (groupId == null || groupId.isEmpty) continue;
    groups.putIfAbsent(groupId, () => []).add(tx);
  }
  return groups;
}

TransactionEntity? _latestByDueDate(List<TransactionEntity> transactions) {
  if (transactions.isEmpty) return null;
  return transactions.reduce(
    (a, b) => a.dueDate.isAfter(b.dueDate) ? a : b,
  );
}

DateTime? _stopDate(List<TransactionEntity> transactions) {
  final stops = transactions
      .map((tx) => tx.recurrenceEndDate)
      .whereType<DateTime>()
      .toList();
  if (stops.isEmpty) return null;
  return stops.reduce((a, b) => a.isBefore(b) ? a : b);
}
