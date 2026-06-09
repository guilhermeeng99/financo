import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  const GetTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, List<TransactionEntity>>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueStartDate,
    DateTime? dueEndDate,
    String? categoryId,
    String? accountId,
    TransactionSettlementStatus? settlementStatus,
    bool forceRefresh = false,
  }) => _repository.getTransactions(
    userId: userId,
    startDate: startDate,
    endDate: endDate,
    dueStartDate: dueStartDate,
    dueEndDate: dueEndDate,
    categoryId: categoryId,
    accountId: accountId,
    settlementStatus: settlementStatus,
    forceRefresh: forceRefresh,
  );
}
