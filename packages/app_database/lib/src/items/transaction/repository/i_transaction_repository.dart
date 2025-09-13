import 'package:app_database/src/items/transaction/domain/index.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';

abstract class ITransactionRepository {
  // Core CRUD operations
  Future<Either<Failure, StandardTransaction>> createStandardTransaction(
    TransactionsCompanion transaction,
  );

  Future<Either<Failure, StandardTransaction>> updateStandardTransaction(
    int id,
    TransactionsCompanion transaction,
  );

  Future<Either<Failure, bool>> deleteStandardTransaction(int id);

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
    required int sourceAccountId,
    required int targetAccountId,
    required double amount,
    required DateTime date,
    String? description,
  });

  Future<Either<Failure, List<TransferTransaction>>> updateTransferTransaction({
    required String transferId,
    DateTime? actualDate,
    DateTime? competenceDate,
    double? amount,
    String? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  });

  Future<Either<Failure, bool>> deleteTransferTransaction(String transferId);

  // Summary calculations
  Future<Either<Failure, TransactionSummaryData>> getTransactionSummary({
    required Set<int> accountIds,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class TransactionSummaryData {
  const TransactionSummaryData({
    required this.projectedTotalIncome,
    required this.projectedTotalExpense,
    required this.projectedTotalTransfers,
  });

  final double projectedTotalIncome;
  final double projectedTotalExpense;
  final double projectedTotalTransfers;
}
