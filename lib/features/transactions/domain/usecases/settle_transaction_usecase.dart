import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

/// Flips a pending transaction to paid without moving it in time.
///
/// `date` stays on the row's `dueDate`, so the movement keeps belonging to
/// the month it was scheduled for — confirming a credit-card instalment due
/// in September does not drag it onto August's invoice. The `settledAt`
/// argument only records *when the user confirmed it* and defaults to now.
///
/// This is why a paid transaction may legally carry a future `date`: see
/// docs/specs/payables_receivables_refactor.md rule 4.
///
/// ```dart
/// final result = await settleTransaction(pendingRow);
/// ```
class SettleTransactionUseCase {
  const SettleTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction, {
    DateTime? settledAt,
  }) {
    if (transaction.isTransfer) {
      return Future.value(const Left(TransferNotSettleableFailure()));
    }

    final confirmedAt = settledAt ?? DateTime.now();
    return _repository.updateTransaction(
      transaction.copyWith(
        settlementStatus: TransactionSettlementStatus.paid,
        date: transaction.dueDate,
        settledAt: confirmedAt,
        updatedAt: confirmedAt,
      ),
    );
  }
}
