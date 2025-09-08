import 'package:app_database/app_database.dart';

abstract class ITransactionUsecase {
  // Core CRUD operations
  Future<Either<Failure, TransactionData>> createTransaction({
    required TransactionDate actualDate,
    required TransactionDate competenceDate,
    required FinancialType transactionType,
    required TransactionAmount amount,
    required TransactionPaymentStatus paymentStatus,
    required TransactionRecurrenceType recurrenceType,
    required TransactionAccountId accountId,
    required TransactionCategoryId categoryId,
    TransactionDescription? description,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  });

  Future<Either<Failure, TransactionData>> updateTransaction({
    required int id,
    TransactionDate? actualDate,
    TransactionDate? competenceDate,
    TransactionAmount? amount,
    TransactionDescription? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    TransactionAccountId? accountId,
    TransactionCategoryId? categoryId,
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
    DateTime endDate, {
    bool onlyPaidTransactions = true,
  });

  Future<Either<Failure, Map<int, double>>> getMultipleAccountsBalanceForPeriod(
    Set<int> accountIds,
    DateTime startDate,
    DateTime endDate, {
    bool onlyPaidTransactions = true,
  });
}
