import 'package:app_database/app_database.dart';

/// Mixin containing CRUD operations for transaction usecase
mixin TransactionCrudUsecaseOperations on TransactionValidationHelpers {
  ITransactionRepository get repository;

  Future<Either<Failure, TransactionData>> createTransaction({
    required DateTime actualDate,
    required DateTime competenceDate,
    required FinancialType transactionType,
    required double amount,
    required TransactionPaymentStatus paymentStatus,
    required TransactionRecurrenceType recurrenceType,
    required int? accountId,
    required int? categoryId,
    String? description,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  }) async {
    try {
      final companion = buildCreateCompanion(
        actualDate: actualDate,
        competenceDate: competenceDate,
        transactionType: transactionType,
        amount: amount,
        description: description,
        paymentStatus: paymentStatus,
        recurrenceType: recurrenceType,
        accountId: accountId,
        categoryId: categoryId,
        recurrenceFrequency: recurrenceFrequency,
      );

      return await repository.createTransaction(companion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating transaction: $e'),
      );
    }
  }

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
      // Validate that at least one field is provided
      if (noFieldsProvided(
        actualDate,
        competenceDate,
        amount,
        description,
        paymentStatus,
        recurrenceType,
        accountId,
        categoryId,
        recurrenceFrequency,
      )) {
        return Either.left(
          const ValidationFailure(
            'At least one field must be provided for update',
          ),
        );
      }

      final companion = buildUpdateCompanion(
        actualDate: actualDate,
        competenceDate: competenceDate,
        amount: amount,
        description: description,
        paymentStatus: paymentStatus,
        recurrenceType: recurrenceType,
        accountId: accountId,
        categoryId: categoryId,
        recurrenceFrequency: recurrenceFrequency,
      );

      return await repository.updateTransaction(id, companion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error updating transaction: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteTransaction(int id) async {
    return repository.deleteTransaction(id);
  }

  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    return repository.getAllTransactions(limit: limit, offset: offset);
  }

  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  }) async {
    return repository.getTransactionsByAccount(
      accountId,
      limit: limit,
      offset: offset,
    );
  }
}
