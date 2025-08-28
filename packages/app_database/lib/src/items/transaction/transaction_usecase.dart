import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

import 'transaction_repository.dart';

abstract class ITransactionUsecase {
  Future<Either<Failure, TransactionData>> createTransaction({
    required DateTime actualDate,
    required DateTime competenceDate,
    required FinancialType transactionType,
    required double amount,
    required String description,
    required TransactionPaymentStatus paymentStatus,
    required TransactionRecurrenceType recurrenceType,
    required int accountId,
    required int categoryId,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  });

  Future<Either<Failure, TransactionData>> updateTransaction({
    required int id,
    required DateTime actualDate,
    required DateTime competenceDate,
    required double amount,
    required String description,
    required TransactionPaymentStatus paymentStatus,
    required TransactionRecurrenceType recurrenceType,
    required int accountId,
    required int categoryId,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  });

  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, bool>> deleteTransaction(int id);
}

class TransactionUsecase implements ITransactionUsecase {
  TransactionUsecase(this._repository);

  final ITransactionRepository _repository;

  @override
  Future<Either<Failure, TransactionData>> createTransaction({
    required DateTime actualDate,
    required DateTime competenceDate,
    required FinancialType transactionType,
    required double amount,
    required String description,
    required TransactionPaymentStatus paymentStatus,
    required TransactionRecurrenceType recurrenceType,
    required int accountId,
    required int categoryId,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  }) async {
    try {
      final companion = TransactionsCompanion(
        actualDate: Value(actualDate),
        competenceDate: Value(competenceDate),
        transactionType: Value(transactionType),
        amount: Value(amount),
        description: Value(description),
        paymentStatus: Value(paymentStatus),
        recurrenceType: Value(recurrenceType),
        recurrenceFrequency: Value(recurrenceFrequency),
        accountId: Value(accountId),
        categoryId: Value(categoryId),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      return await _repository.createTransaction(companion);
    } catch (e) {
      return Either.left(DatabaseFailure('Error creating transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionData>> updateTransaction({
    required int id,
    required DateTime actualDate,
    required DateTime competenceDate,
    required double amount,
    required String description,
    required TransactionPaymentStatus paymentStatus,
    required TransactionRecurrenceType recurrenceType,
    required int accountId,
    required int categoryId,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  }) async {
    try {
      final companion = TransactionsCompanion(
        actualDate: Value(actualDate),
        competenceDate: Value(competenceDate),
        amount: Value(amount),
        description: Value(description),
        paymentStatus: Value(paymentStatus),
        recurrenceType: Value(recurrenceType),
        recurrenceFrequency: Value(recurrenceFrequency),
        accountId: Value(accountId),
        categoryId: Value(categoryId),
        updatedAt: Value(DateTime.now()),
      );

      return await _repository.updateTransaction(id, companion);
    } catch (e) {
      return Either.left(DatabaseFailure('Error updating transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    return _repository.getAllTransactions(limit: limit, offset: offset);
  }

  @override
  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  }) async {
    return _repository.getTransactionsByAccount(
      accountId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id) async {
    return _repository.deleteTransaction(id);
  }
}
