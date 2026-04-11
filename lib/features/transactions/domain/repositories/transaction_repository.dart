import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, TransactionEntity>> getTransaction(String id);

  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );

  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );

  Future<Either<Failure, void>> deleteTransaction(String id);

  Future<Either<Failure, void>> toggleReconciled(String id);
}
