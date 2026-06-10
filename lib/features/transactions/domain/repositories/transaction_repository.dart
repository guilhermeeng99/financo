import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueStartDate,
    DateTime? dueEndDate,
    String? categoryId,
    String? accountId,
    TransactionSettlementStatus? settlementStatus,
    TransactionRecurrence? recurrence,
    String? recurrenceGroupId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, TransactionEntity>> getTransaction(String id);

  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );

  Future<Either<Failure, List<TransactionEntity>>> createTransactions(
    List<TransactionEntity> transactions,
  );

  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );

  Future<Either<Failure, List<TransactionEntity>>> updateTransactions(
    List<TransactionEntity> transactions,
  );

  Future<Either<Failure, void>> deleteTransaction(String id);

  Future<Either<Failure, void>> deleteTransactions(List<String> ids);

  Future<Either<Failure, List<TransactionEntity>>> createTransfer({
    required TransactionEntity expense,
    required TransactionEntity income,
  });

  Future<Either<Failure, void>> reassignTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  });
}
