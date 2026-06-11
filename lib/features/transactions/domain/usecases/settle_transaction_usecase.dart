import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class SettleTransactionUseCase {
  const SettleTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction, {
    DateTime? settledAt,
  }) {
    if (transaction.isTransfer) {
      return Future.value(
        const Left(
          ValidationFailure('Transfers cannot be pending payables.'),
        ),
      );
    }

    final settlementDate = settledAt ?? DateTime.now();
    return _repository.updateTransaction(
      transaction.copyWith(
        settlementStatus: TransactionSettlementStatus.paid,
        date: settlementDate,
        settledAt: settlementDate,
        updatedAt: settlementDate,
      ),
    );
  }
}
