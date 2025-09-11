import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

import 'transaction_form_types.dart';

class TransactionFormErrors {
  const TransactionFormErrors({
    this.description = '',
    this.amount = '',
    this.account = '',
    this.category = '',
  });

  final String description;
  final String amount;
  final String account;
  final String category;

  bool get hasErrors =>
      description.isNotEmpty ||
      amount.isNotEmpty ||
      account.isNotEmpty ||
      category.isNotEmpty;

  TransactionFormErrors copyWith({
    String? description,
    String? amount,
    String? account,
    String? category,
  }) {
    return TransactionFormErrors(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      account: account ?? this.account,
      category: category ?? this.category,
    );
  }

  TransactionFormErrors clearAll() {
    return const TransactionFormErrors();
  }
}

class TransactionFormValidator {
  static ValidationResult<StandardTransactionParams>
  validateStandardTransaction(
    TransactionFormData formData,
    BuildContext context,
  ) {
    var errors = const TransactionFormErrors();

    final validationResults = _validateCommonFields(formData, context, errors);
    errors = validationResults.errors;

    if (validationResults.categoryValidation == null) {
      errors = errors.copyWith(
        category: context.t.transactions.validation.category_must_be_selected,
      );
    }

    if (errors.hasErrors ||
        validationResults.amountValidation == null ||
        validationResults.accountValidation == null ||
        validationResults.dateValidation == null ||
        validationResults.categoryValidation == null) {
      return ValidationResult.failure(errors);
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

  static ValidationResult<TransferTransactionParams>
  validateTransferTransaction(
    TransactionFormData formData,
    BuildContext context,
  ) {
    var errors = const TransactionFormErrors();

    final validationResults = _validateCommonFields(formData, context, errors);
    errors = validationResults.errors;

    TransactionAccountId? targetAccountValidation;
    try {
      final targetId = formData.selectedTargetAccountId;
      if (targetId == null) {
        errors = errors.copyWith(
          account: context.t.transactions.validation.account_must_be_selected,
        );
      } else {
        targetAccountValidation = TransactionAccountId.create(
          targetId,
          context,
        );
      }
    } on ValidationException catch (e) {
      errors = errors.copyWith(account: e.message);
    }

    if (errors.hasErrors ||
        validationResults.amountValidation == null ||
        validationResults.accountValidation == null ||
        validationResults.dateValidation == null ||
        targetAccountValidation == null) {
      return ValidationResult.failure(errors);
    }

    return ValidationResult.success(
      TransferTransactionParams(
        amount: validationResults.amountValidation!,
        sourceAccountId: validationResults.accountValidation!,
        targetAccountId: targetAccountValidation,
        actualDate: validationResults.dateValidation!,
        description: validationResults.descriptionValidation,
      ),
    );
  }

  static _ValidationResults _validateCommonFields(
    TransactionFormData formData,
    BuildContext context,
    TransactionFormErrors initialErrors,
  ) {
    TransactionAmount? amountValidation;
    TransactionAccountId? accountValidation;
    TransactionCategoryId? categoryValidation;
    TransactionDate? dateValidation;
    TransactionDescription? descriptionValidation;
    var errors = initialErrors;

    try {
      amountValidation = TransactionAmount.create(
        formData.amount,
        context,
        transactionType: formData.isTransfer
            ? FinancialType.expense
            : formData.selectedTransactionType,
      );
    } on ValidationException catch (e) {
      errors = errors.copyWith(amount: e.message);
    }

    try {
      accountValidation = TransactionAccountId.create(
        formData.selectedAccountId,
        context,
      );
    } on ValidationException catch (e) {
      errors = errors.copyWith(account: e.message);
    }

    if (!formData.isTransfer) {
      try {
        categoryValidation = TransactionCategoryId.create(
          formData.selectedCategoryId,
          context,
        );
      } on ValidationException catch (e) {
        errors = errors.copyWith(category: e.message);
      }
    }

    try {
      dateValidation = TransactionDate.create(formData.actualDate, context);
    } on ValidationException catch (e) {
      CWSnackBar.snackBar(title: e.message, type: SnackBarType.error);
    }

    try {
      descriptionValidation = TransactionDescription.create(
        formData.description.trim(),
        context,
      );
    } on ValidationException catch (e) {
      errors = errors.copyWith(description: e.message);
    }

    return _ValidationResults(
      amountValidation: amountValidation,
      accountValidation: accountValidation,
      categoryValidation: categoryValidation,
      dateValidation: dateValidation,
      descriptionValidation: descriptionValidation,
      errors: errors,
    );
  }
}

class _ValidationResults {
  const _ValidationResults({
    required this.errors,
    this.amountValidation,
    this.accountValidation,
    this.categoryValidation,
    this.dateValidation,
    this.descriptionValidation,
  });

  final TransactionAmount? amountValidation;
  final TransactionAccountId? accountValidation;
  final TransactionCategoryId? categoryValidation;
  final TransactionDate? dateValidation;
  final TransactionDescription? descriptionValidation;
  final TransactionFormErrors errors;
}

class ValidationResult<T> {
  factory ValidationResult.failure(TransactionFormErrors errors) {
    return ValidationResult._(errors: errors);
  }

  factory ValidationResult.success(T data) {
    return ValidationResult._(data: data);
  }
  
  const ValidationResult._({this.data, this.errors});

  final T? data;
  final TransactionFormErrors? errors;

  bool get isSuccess => data != null;
  bool get isFailure => errors != null;
}

class StandardTransactionParams {
  const StandardTransactionParams({
    required this.amount,
    required this.accountId,
    required this.categoryId,
    required this.actualDate,
    required this.competenceDate,
    this.description,
  });

  final TransactionAmount amount;
  final TransactionAccountId accountId;
  final TransactionCategoryId categoryId;
  final TransactionDate actualDate;
  final TransactionDate competenceDate;
  final TransactionDescription? description;
}

class TransferTransactionParams {
  const TransferTransactionParams({
    required this.amount,
    required this.sourceAccountId,
    required this.targetAccountId,
    required this.actualDate,
    this.description,
  });

  final TransactionAmount amount;
  final TransactionAccountId sourceAccountId;
  final TransactionAccountId targetAccountId;
  final TransactionDate actualDate;
  final TransactionDescription? description;
}
