import 'package:app_database/src/items/transaction/presentation/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../../../database/database_manager.dart';
import '../domain/index.dart';
import '../repository/i_transaction_repository.dart';

mixin TransactionCrudUsecaseOperations {
  ITransactionRepository get transactionRepository;

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
  }) async {
    try {
      final transactionCompanion = TransactionsCompanion(
        actualDate: Value(actualDate.value),
        competenceDate: Value(competenceDate.value),
        transactionType: Value(transactionType),
        amount: Value(amount.value),
        description: Value(description?.value),
        paymentStatus: Value(paymentStatus),
        recurrenceType: Value(recurrenceType),
        accountId: Value(accountId.value),
        categoryId: Value(categoryId.value),
        recurrenceFrequency: Value(recurrenceFrequency),
      );

      return await transactionRepository.createTransaction(
        transactionCompanion,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating transaction: $e'),
      );
    }
  }

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
  }) async {
    try {
      final currentTransactionResult = await transactionRepository
          .getTransactionById(id);

      return await currentTransactionResult.fold(Either.left, (
        currentTransaction,
      ) async {
        if (currentTransaction == null) {
          return Either.left(const ValidationFailure('Transaction not found'));
        }

        if (_hasNoChanges(
          currentTransaction: currentTransaction,
          actualDate: actualDate,
          competenceDate: competenceDate,
          amount: amount,
          description: description,
          paymentStatus: paymentStatus,
          recurrenceType: recurrenceType,
          accountId: accountId,
          categoryId: categoryId,
          recurrenceFrequency: recurrenceFrequency,
        )) {
          return Either.left(
            const NoChangesFailure('No changes were provided'),
          );
        }

        final transactionCompanion = TransactionsCompanion(
          actualDate: actualDate != null
              ? Value(actualDate.value)
              : const Value.absent(),
          competenceDate: competenceDate != null
              ? Value(competenceDate.value)
              : const Value.absent(),
          amount: amount != null ? Value(amount.value) : const Value.absent(),
          description: description != null
              ? Value(description.value)
              : const Value.absent(),
          paymentStatus: paymentStatus != null
              ? Value(paymentStatus)
              : const Value.absent(),
          recurrenceType: recurrenceType != null
              ? Value(recurrenceType)
              : const Value.absent(),
          accountId: accountId != null
              ? Value(accountId.value)
              : const Value.absent(),
          categoryId: categoryId != null
              ? Value(categoryId.value)
              : const Value.absent(),
          recurrenceFrequency: recurrenceFrequency != null
              ? Value(recurrenceFrequency)
              : const Value.absent(),
        );

        return transactionRepository.updateTransaction(
          id,
          transactionCompanion,
        );
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error editing transaction: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteTransaction(int id) async {
    try {
      return await transactionRepository.deleteTransaction(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error deleting transaction: $e'),
      );
    }
  }

  bool _hasNoChanges({
    required TransactionData currentTransaction,
    TransactionDate? actualDate,
    TransactionDate? competenceDate,
    TransactionAmount? amount,
    TransactionDescription? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    TransactionAccountId? accountId,
    TransactionCategoryId? categoryId,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  }) {
    return (actualDate == null ||
            _datesAreEqual(actualDate.value, currentTransaction.actualDate)) &&
        (competenceDate == null ||
            _datesAreEqual(
              competenceDate.value,
              currentTransaction.competenceDate,
            )) &&
        (amount == null || amount.value == currentTransaction.amount) &&
        (description == null ||
            description.value == currentTransaction.description) &&
        (paymentStatus == null ||
            paymentStatus == currentTransaction.paymentStatus) &&
        (recurrenceType == null ||
            recurrenceType == currentTransaction.recurrenceType) &&
        (accountId == null ||
            accountId.value == currentTransaction.accountId) &&
        (categoryId == null ||
            categoryId.value == currentTransaction.categoryId) &&
        (recurrenceFrequency == null ||
            recurrenceFrequency == currentTransaction.recurrenceFrequency);
  }

  bool _datesAreEqual(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day &&
        date1.hour == date2.hour &&
        date1.minute == date2.minute &&
        date1.second == date2.second;
  }

  Future<Either<Failure, List<TransactionData>>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    try {
      return await transactionRepository.getAllTransactions(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error getting transactions: $e'),
      );
    }
  }

  Future<Either<Failure, List<TransactionData>>> getTransactionsByAccount(
    int accountId, {
    int? limit,
    int? offset,
  }) async {
    try {
      return await transactionRepository.getTransactionsByAccount(
        accountId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error getting transactions by account: $e'),
      );
    }
  }
}
