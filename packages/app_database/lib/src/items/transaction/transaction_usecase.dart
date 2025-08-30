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
      final validatedAmount = TransactionAmount.create(amount);
      final validatedDescription = TransactionDescription.create(description);
      final validatedAccountId = TransactionAccountId.create(accountId);
      final validatedCategoryId = TransactionCategoryId.create(categoryId);
      final validatedActualDate = TransactionDate.create(actualDate);
      final validatedCompetenceDate = TransactionDate.create(competenceDate);

      final companion = TransactionsCompanion(
        actualDate: Value(validatedActualDate.value),
        competenceDate: Value(validatedCompetenceDate.value),
        transactionType: Value(transactionType),
        amount: Value(validatedAmount.value),
        description: Value(validatedDescription.value),
        paymentStatus: Value(paymentStatus),
        recurrenceType: Value(recurrenceType),
        recurrenceFrequency: Value(recurrenceFrequency),
        accountId: Value(validatedAccountId.value),
        categoryId: Value(validatedCategoryId.value),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      return await _repository.createTransaction(companion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating transaction: $e'),
      );
    }
  }

  @override
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
  }) async {
    try {
      Value<DateTime>? actualDateValue;
      Value<DateTime>? competenceDateValue;
      Value<double>? amountValue;
      Value<String>? descriptionValue;
      Value<int>? accountIdValue;
      Value<int>? categoryIdValue;

      if (actualDate != null) {
        final validatedActualDate = TransactionDate.create(actualDate);
        actualDateValue = Value(validatedActualDate.value);
      }

      if (competenceDate != null) {
        final validatedCompetenceDate = TransactionDate.create(competenceDate);
        competenceDateValue = Value(validatedCompetenceDate.value);
      }

      if (amount != null) {
        final validatedAmount = TransactionAmount.create(amount);
        amountValue = Value(validatedAmount.value);
      }

      if (description != null) {
        final validatedDescription = TransactionDescription.create(description);
        descriptionValue = Value(validatedDescription.value);
      }

      if (accountId != null) {
        final validatedAccountId = TransactionAccountId.create(accountId);
        accountIdValue = Value(validatedAccountId.value);
      }

      if (categoryId != null) {
        final validatedCategoryId = TransactionCategoryId.create(categoryId);
        categoryIdValue = Value(validatedCategoryId.value);
      }

      if (actualDateValue == null &&
          competenceDateValue == null &&
          amountValue == null &&
          descriptionValue == null &&
          paymentStatus == null &&
          recurrenceType == null &&
          accountIdValue == null &&
          categoryIdValue == null &&
          recurrenceFrequency == null) {
        return Either.left(
          const ValidationFailure(
            'At least one field must be provided for update',
          ),
        );
      }

      final companion = TransactionsCompanion(
        actualDate: actualDateValue ?? const Value.absent(),
        competenceDate: competenceDateValue ?? const Value.absent(),
        amount: amountValue ?? const Value.absent(),
        description: descriptionValue ?? const Value.absent(),
        paymentStatus: paymentStatus != null
            ? Value(paymentStatus)
            : const Value.absent(),
        recurrenceType: recurrenceType != null
            ? Value(recurrenceType)
            : const Value.absent(),
        recurrenceFrequency: recurrenceFrequency != null
            ? Value(recurrenceFrequency)
            : const Value.absent(),
        accountId: accountIdValue ?? const Value.absent(),
        categoryId: categoryIdValue ?? const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      return await _repository.updateTransaction(id, companion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error updating transaction: $e'),
      );
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
