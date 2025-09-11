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

      return await transactionRepository.createStandardTransaction(
        transactionCompanion,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating transaction: $e'),
      );
    }
  }

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

        final result = await transactionRepository.updateStandardTransaction(
          id,
          transactionCompanion,
        );

        return result;
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error editing standard transaction: $e'),
      );
    }
  }

  Future<Either<Failure, List<TransferTransaction>>> updateTransferTransaction({
    required String transferId,
    TransactionDate? actualDate,
    TransactionDate? competenceDate,
    TransactionAmount? amount,
    TransactionDescription? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  }) async {
    try {
      return await transactionRepository.updateTransferTransaction(
        transferId: transferId,
        actualDate: actualDate?.value,
        competenceDate: competenceDate?.value,
        amount: amount?.value,
        description: description?.value,
        paymentStatus: paymentStatus,
        recurrenceType: recurrenceType,
        recurrenceFrequency: recurrenceFrequency,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error updating transfer transaction: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteStandardTransaction(int id) async {
    try {
      return await transactionRepository.deleteStandardTransaction(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error deleting standard transaction: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteTransferTransaction(
    String transferId,
  ) async {
    try {
      return await transactionRepository.deleteTransferTransaction(transferId);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error deleting transfer transaction: $e'),
      );
    }
  }

  Future<Either<Failure, List<TransferTransaction>>>
  createTransferBetweenAccounts({
    required TransactionAccountId sourceAccountId,
    required TransactionAccountId targetAccountId,
    required TransactionAmount amount,
    required TransactionDate date,
    TransactionDescription? description,
  }) async {
    try {
      if (sourceAccountId.value == targetAccountId.value) {
        return Either.left(
          const ValidationFailure('Source and target accounts must differ'),
        );
      }
      return transactionRepository.createTransferBetweenAccounts(
        sourceAccountId: sourceAccountId.value,
        targetAccountId: targetAccountId.value,
        amount: amount.value.abs(),
        date: date.value,
        description: description?.value,
      );
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error transferring between accounts: $e'),
      );
    }
  }

  bool _hasNoChanges({
    required DataTransaction currentTransaction,
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
}
