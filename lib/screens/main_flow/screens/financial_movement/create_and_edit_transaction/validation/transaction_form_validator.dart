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

    descriptionValidation = ValidationResult.validateField(
      () => TransactionDescription.create(formData.description.trim(), context),
      (errorMessage) => errors = errors.copyWith(description: errorMessage),
    );

    amountValidation = ValidationResult.validateField(
      () => TransactionAmount.create(
        formData.amount,
        context,
        transactionType: formData.isTransfer
            ? FinancialType.expense
            : formData.selectedTransactionType,
      ),
      (errorMessage) => errors = errors.copyWith(amount: errorMessage),
    );

    accountValidation = ValidationResult.validateField(
      () => TransactionAccountId.create(formData.selectedAccountId, context),
      (errorMessage) => errors = errors.copyWith(account: errorMessage),
    );

    if (formData.isTransfer) {
      targetAccountValidation = ValidationResult.validateField(
        () => TransactionAccountId.create(
          formData.selectedTargetAccountId,
          context,
        ),
        (errorMessage) => errors = errors.copyWith(account: errorMessage),
      );
    } else {
      categoryValidation = ValidationResult.validateField(
        () =>
            TransactionCategoryId.create(formData.selectedCategoryId, context),
        (errorMessage) => errors = errors.copyWith(category: errorMessage),
      );
    }

    dateValidation = ValidationResult.validateField(
      () => TransactionDate.create(formData.actualDate, context),
      (errorMessage) => errors = errors.copyWith(actualDate: errorMessage),
    );

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
