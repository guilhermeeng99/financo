import 'package:app_database/app_database.dart';

abstract class ITransactionUsecase {
  // Core CRUD operations
  Future<Either<Failure, TransactionData>> createTransaction({
    required DateTime actualDate,
    required DateTime competenceDate,
    required FinancialType transactionType,
    required double amount,
    required TransactionPaymentStatus paymentStatus,
    required TransactionRecurrenceType recurrenceType,
    required int? accountId,
    required int? categoryId,
    String description,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  });

  Future<Either<Failure, TransactionData>> updateTransaction({
    required int id,
    DateTime? actualDate,
    DateTime? competenceDate,
    double? amount,
    String? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    int? accountId,
    int? categoryId,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  });

  Future<Either<Failure, bool>> deleteTransaction(int id);

  // Read operations
  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  });

  // Advanced queries
  Future<Either<Failure, List<TransactionI>>> getTransactionsWithDetails({
    Set<int>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  // Balance operations
  Future<Either<Failure, double>> getAccountBalance(int accountId);

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
