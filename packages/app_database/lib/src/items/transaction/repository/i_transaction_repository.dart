import 'package:app_database/src/items/transaction/domain/index.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';

abstract class ITransactionRepository {
  // Core CRUD operations
  Future<Either<Failure, TransactionData>> createTransaction(
    TransactionsCompanion transaction,
  );

  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, TransactionData?>> getTransactionById(int id);

  Future<Either<Failure, TransactionData>> updateTransaction(
    int id,
    TransactionsCompanion transaction,
  );

  Future<Either<Failure, bool>> deleteTransaction(int id);

  // Balance operations
  Future<Either<Failure, double>> getAccountBalanceById(int accountId);

  // Advanced queries with details
  Future<Either<Failure, List<TransactionI>>> getTransactionsWithDetails({
    Set<int>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  // Period-specific balance calculations
  Future<Either<Failure, double>> getAccountBalanceForPeriod(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  );

  Future<Either<Failure, Map<int, double>>> getMultipleAccountsBalanceForPeriod(
    Set<int> accountIds,
    DateTime startDate,
    DateTime endDate,
  );
}
