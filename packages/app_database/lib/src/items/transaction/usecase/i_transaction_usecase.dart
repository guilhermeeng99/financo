import 'package:app_database/app_database.dart';

abstract class ITransactionUsecase {
  // Core CRUD operations
  Future<Either<Failure, StandardTransaction>> createStandardTransaction({
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

  Future<Either<Failure, StandardTransaction>> updateStandardTransaction({
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

  Future<Either<Failure, bool>> deleteStandardTransaction(int id);

  // Read operations
  Future<Either<Failure, List<DataTransaction>>> getAllTransactions({
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<DataTransaction>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, DataTransaction?>> getTransactionById(int id);

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

  // Transfer operations
  Future<Either<Failure, List<TransferTransaction>>>
  createTransferBetweenAccounts({
    required TransactionAccountId sourceAccountId,
    required TransactionAccountId targetAccountId,
    required TransactionAmount amount,
    required TransactionDate date,
    TransactionDescription? description,
  });

  Future<Either<Failure, List<TransferTransaction>>> updateTransferTransaction({
    required String transferId,
    TransactionDate? actualDate,
    TransactionDate? competenceDate,
    TransactionAmount? amount,
    TransactionDescription? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  });

  Future<Either<Failure, bool>> deleteTransferTransaction(String transferId);

  // Summary calculations
  Future<Either<Failure, TransactionSummary>> getTransactionSummary({
    required Set<int> accountIds,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class TransactionSummary {
  const TransactionSummary({
    required this.projectedTotalIncome,
    required this.projectedTotalExpense,
    required this.projectedTotalTransfersIn,
    required this.projectedTotalTransfersOut,
  });
  final double projectedTotalIncome;
  final double projectedTotalExpense;
  final double projectedTotalTransfersIn;
  final double projectedTotalTransfersOut;

  double get projectedTotalResult =>
      projectedTotalIncome - projectedTotalExpense;
}
