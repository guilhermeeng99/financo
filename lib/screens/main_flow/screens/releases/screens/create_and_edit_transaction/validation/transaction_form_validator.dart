import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

import 'transaction_form_types.dart';

class TransactionFormErrors {
  const TransactionFormErrors({
    this.description = '',
    this.amount = '',
    this.account = '',
    this.category = '',
    this.actualDate = '',
  });

  final String description;
  final String amount;
  final String account;
  final String category;
  final String actualDate;

  bool get hasErrors =>
      description.isNotEmpty ||
      amount.isNotEmpty ||
      account.isNotEmpty ||
      category.isNotEmpty ||
      actualDate.isNotEmpty;

  TransactionFormErrors copyWith({
    String? description,
    String? amount,
    String? account,
    String? category,
    String? actualDate,
  }) {
    return TransactionFormErrors(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      account: account ?? this.account,
      category: category ?? this.category,
      actualDate: actualDate ?? this.actualDate,
    );
  }

  TransactionFormErrors clearField(TransactionFormField field) {
    return switch (field) {
      TransactionFormField.description => copyWith(description: ''),
      TransactionFormField.amount => copyWith(amount: ''),
      TransactionFormField.account => copyWith(account: ''),
      TransactionFormField.category => copyWith(category: ''),
      TransactionFormField.actualDate => copyWith(actualDate: ''),
    };
  }

  TransactionFormErrors clear() {
    return const TransactionFormErrors();
  }
}

class TransactionFormValidator {
  static ValidationResult<StandardTransactionParams, TransactionFormErrors>
  validateStandardTransaction(
    TransactionFormData formData,
    BuildContext context,
  ) {
    final validationResults = _validateFields(formData, context);

    if (validationResults.categoryValidation == null) {
      final errors = validationResults.errors.copyWith(
        category: context.t.transactions.validation.category_must_be_selected,
      );
      return ValidationResult.failure(errors);
    }

    if (validationResults.hasErrors) {
      return ValidationResult.failure(validationResults.errors);
    }

    return ValidationResult.success(
      StandardTransactionParams(
        amount: validationResults.amountValidation!,
        accountId: validationResults.accountValidation!,
        categoryId: validationResults.categoryValidation!,
        actualDate: validationResults.dateValidation!,
        competenceDate: validationResults.dateValidation!,
        description: validationResults.descriptionValidation,
      ),
    );
  }

  static ValidationResult<TransferTransactionParams, TransactionFormErrors>
  validateTransferTransaction(
    TransactionFormData formData,
    BuildContext context,
  ) {
    final validationResults = _validateFields(formData, context);

    if (validationResults.hasErrors) {
      return ValidationResult.failure(validationResults.errors);
    }

    return ValidationResult.success(
      TransferTransactionParams(
        amount: validationResults.amountValidation!,
        sourceAccountId: validationResults.accountValidation!,
        targetAccountId: validationResults.targetAccountValidation!,
        actualDate: validationResults.dateValidation!,
        description: validationResults.descriptionValidation,
      ),
    );
  }

  static _FieldValidationResults _validateFields(
    TransactionFormData formData,
    BuildContext context,
  ) {
    TransactionAmount? amountValidation;
    TransactionAccountId? accountValidation;
    TransactionAccountId? targetAccountValidation;
    TransactionCategoryId? categoryValidation;
    TransactionDate? dateValidation;
    TransactionDescription? descriptionValidation;
    var errors = const TransactionFormErrors();

    try {
      descriptionValidation = TransactionDescription.create(
        formData.description.trim(),
        context,
      );
    } on ValidationException catch (e) {
      logger.e(e.message);
      errors = errors.copyWith(description: e.message);
    }

    try {
      amountValidation = TransactionAmount.create(
        formData.amount,
        context,
        transactionType: formData.isTransfer
            ? FinancialType.expense
            : formData.selectedTransactionType,
      );
    } on ValidationException catch (e) {
      logger.e(e.message);
      errors = errors.copyWith(amount: e.message);
    }

    try {
      accountValidation = TransactionAccountId.create(
        formData.selectedAccountId,
        context,
      );
    } on ValidationException catch (e) {
      logger.e(e.message);
      errors = errors.copyWith(account: e.message);
    }

    if (formData.isTransfer) {
      try {
        targetAccountValidation = TransactionAccountId.create(
          formData.selectedTargetAccountId,
          context,
        );
      } on ValidationException catch (e) {
        logger.e(e.message);
        errors = errors.copyWith(account: e.message);
      }
    } else {
      try {
        categoryValidation = TransactionCategoryId.create(
          formData.selectedCategoryId,
          context,
        );
      } on ValidationException catch (e) {
        logger.e(e.message);
        errors = errors.copyWith(category: e.message);
      }
    }

    try {
      dateValidation = TransactionDate.create(formData.actualDate, context);
    } on ValidationException catch (e) {
      logger.e(e.message);
      errors = errors.copyWith(actualDate: e.message);
    }

    return _FieldValidationResults(
      amountValidation: amountValidation,
      accountValidation: accountValidation,
      targetAccountValidation: targetAccountValidation,
      categoryValidation: categoryValidation,
      dateValidation: dateValidation,
      descriptionValidation: descriptionValidation,
      errors: errors,
    );
  }
}

class _FieldValidationResults {
  const _FieldValidationResults({
    required this.errors,
    this.amountValidation,
    this.accountValidation,
    this.targetAccountValidation,
    this.categoryValidation,
    this.dateValidation,
    this.descriptionValidation,
  });

  final TransactionAmount? amountValidation;
  final TransactionAccountId? accountValidation;
  final TransactionAccountId? targetAccountValidation;
  final TransactionCategoryId? categoryValidation;
  final TransactionDate? dateValidation;
  final TransactionDescription? descriptionValidation;
  final TransactionFormErrors errors;

  bool get hasErrors =>
      errors.hasErrors ||
      amountValidation == null ||
      accountValidation == null ||
      dateValidation == null;
}
