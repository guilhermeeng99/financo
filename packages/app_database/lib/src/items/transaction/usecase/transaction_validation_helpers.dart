import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

/// Helper methods for validation and data transformation in transaction operations
mixin TransactionValidationHelpers {
  /// Checks if no fields are provided for update operation
  bool noFieldsProvided(
    DateTime? actualDate,
    DateTime? competenceDate,
    double? amount,
    String? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    int? accountId,
    int? categoryId,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  ) {
    return actualDate == null &&
        competenceDate == null &&
        amount == null &&
        description == null &&
        paymentStatus == null &&
        recurrenceType == null &&
        accountId == null &&
        categoryId == null &&
        recurrenceFrequency == null;
  }

  /// Builds a TransactionsCompanion for update operations with validation
  TransactionsCompanion buildUpdateCompanion({
    DateTime? actualDate,
    DateTime? competenceDate,
    double? amount,
    String? description,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    int? accountId,
    int? categoryId,
    TransactionRecurrenceFrequency? recurrenceFrequency,
  }) {
    return TransactionsCompanion(
      actualDate: actualDate != null
          ? Value(TransactionDate.create(actualDate).value)
          : const Value.absent(),
      competenceDate: competenceDate != null
          ? Value(TransactionDate.create(competenceDate).value)
          : const Value.absent(),
      amount: amount != null
          ? Value(TransactionAmount.create(amount).value)
          : const Value.absent(),
      description: description != null
          ? Value(TransactionDescription.create(description).value)
          : const Value.absent(),
      paymentStatus: paymentStatus != null
          ? Value(paymentStatus)
          : const Value.absent(),
      recurrenceType: recurrenceType != null
          ? Value(recurrenceType)
          : const Value.absent(),
      recurrenceFrequency: recurrenceFrequency != null
          ? Value(recurrenceFrequency)
          : const Value.absent(),
      accountId: accountId != null
          ? Value(TransactionAccountId.create(accountId).value)
          : const Value.absent(),
      categoryId: categoryId != null
          ? Value(TransactionCategoryId.create(categoryId).value)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Builds a TransactionsCompanion for create operations with validation
  TransactionsCompanion buildCreateCompanion({
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
  }) {
    // Validate inputs using domain objects
    final validatedAmount = TransactionAmount.create(amount);
    final validatedDescription = TransactionDescription.create(description);
    final validatedAccountId = TransactionAccountId.create(accountId);
    final validatedCategoryId = TransactionCategoryId.create(categoryId);
    final validatedActualDate = TransactionDate.create(actualDate);
    final validatedCompetenceDate = TransactionDate.create(competenceDate);

    return TransactionsCompanion(
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
  }
}
