import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/account_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/transactions_bloc.dart';

import 'create_and_edit_transaction_bloc.dart';

CreateAndEditTransactionModel get createAndEditTransactionModel =>
    Modular.get<CreateAndEditTransactionModel>();

class CreateAndEditTransactionModel {
  ITransactionUsecase get _transactionUsecase =>
      Modular.get<ITransactionUsecase>();

  Future<void> onTapSave(
    TransactionData? transaction,
    BuildContext context,
  ) async {
    if (transaction != null) {
      await _updateTransaction(transaction, context);
    } else {
      await _createTransaction(context);
    }
  }

  Future<void> _createTransaction(BuildContext context) async {
    await _executeValidation(context, (
      amount,
      accountId,
      categoryId,
      actualDate,
      competenceDate,
      description,
    ) async {
      final result = await _transactionUsecase.createTransaction(
        actualDate: actualDate,
        competenceDate: competenceDate,
        transactionType:
            createAndEditTransactionBloc.selectedTransactionType.value,
        amount: amount,
        description: description,
        paymentStatus: createAndEditTransactionBloc.selectedPaymentStatus.value,
        recurrenceType:
            createAndEditTransactionBloc.selectedRecurrenceType.value,
        recurrenceFrequency:
            createAndEditTransactionBloc.selectedRecurrenceType.value ==
                TransactionRecurrenceType.fixed
            ? createAndEditTransactionBloc.selectedRecurrenceFrequency.value
            : null,
        accountId: accountId,
        categoryId: categoryId,
      );

      result.fold(
        (failure) {
          logger.e('Error creating transaction: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        },
        (transaction) {
          logger.i(
            'Transaction created successfully: ${transaction.description}',
          );
          transactionsAccountsBloc.loadCheckingAccounts();
          transactionsBloc.loadTransactions();
          PopUpManager.pop();
        },
      );
    });
  }

  Future<void> _updateTransaction(
    TransactionData originalTransaction,
    BuildContext context,
  ) async {
    await _executeValidation(context, (
      amount,
      accountId,
      categoryId,
      actualDate,
      competenceDate,
      description,
    ) async {
      final result = await _transactionUsecase.updateTransaction(
        id: originalTransaction.id,
        actualDate: actualDate,
        competenceDate: competenceDate,
        amount: amount,
        description: description,
        paymentStatus: createAndEditTransactionBloc.selectedPaymentStatus.value,
        recurrenceType:
            createAndEditTransactionBloc.selectedRecurrenceType.value,
        recurrenceFrequency:
            createAndEditTransactionBloc.selectedRecurrenceType.value ==
                TransactionRecurrenceType.fixed
            ? createAndEditTransactionBloc.selectedRecurrenceFrequency.value
            : null,
        accountId: accountId,
        categoryId: categoryId,
      );

      result.fold(
        (failure) {
          if (failure is NoChangesFailure) {
            logger.i(context.t.messages.warnings.no_changes_provided);
            CWSnackBar.snackBar(
              title: context.t.messages.warnings.no_changes_provided,
              type: SnackBarType.info,
            );
            PopUpManager.pop();
          } else {
            logger.e('Error updating transaction: ${failure.message}');
            CWSnackBar.snackBar(
              title: failure.message,
              type: SnackBarType.error,
            );
          }
        },
        (transaction) {
          logger.i(
            'Transaction updated successfully: ${transaction.description}',
          );
          transactionsAccountsBloc.loadCheckingAccounts();
          transactionsBloc.loadTransactions();
          PopUpManager.pop();
        },
      );
    });
  }

  Future<void> _executeValidation(
    BuildContext context,
    Future<void> Function(
      TransactionAmount amount,
      TransactionAccountId accountId,
      TransactionCategoryId categoryId,
      TransactionDate actualDate,
      TransactionDate competenceDate,
      TransactionDescription? description,
    )
    execute,
  ) async {
    final validatedInputs = _validateInputs(context);
    if (validatedInputs == null) return;

    final (
      amount,
      accountId,
      categoryId,
      actualDate,
      competenceDate,
      description,
    ) = validatedInputs;
    await execute(
      amount,
      accountId,
      categoryId,
      actualDate,
      competenceDate,
      description,
    );
  }

  (
    TransactionAmount,
    TransactionAccountId,
    TransactionCategoryId,
    TransactionDate,
    TransactionDate,
    TransactionDescription?,
  )?
  _validateInputs(BuildContext context) {
    TransactionAmount? amount;
    TransactionAccountId? accountId;
    TransactionCategoryId? categoryId;
    TransactionDate? actualDate;
    TransactionDate? competenceDate;
    TransactionDescription? description;

    try {
      amount = TransactionAmount.create(
        createAndEditTransactionBloc.amount.value,
        context,
      );
    } on ValidationException catch (e) {
      createAndEditTransactionBloc.amountError.value = e.message;
    }

    try {
      accountId = TransactionAccountId.create(
        createAndEditTransactionBloc.selectedAccountId.value,
        context,
      );
    } on ValidationException catch (e) {
      createAndEditTransactionBloc.accountError.value = e.message;
    }

    try {
      categoryId = TransactionCategoryId.create(
        createAndEditTransactionBloc.selectedCategoryId.value,
        context,
      );
    } on ValidationException catch (e) {
      createAndEditTransactionBloc.categoryError.value = e.message;
    }

    try {
      actualDate = TransactionDate.create(
        createAndEditTransactionBloc.actualDate.value,
        context,
      );
    } on ValidationException catch (e) {
      CWSnackBar.snackBar(title: e.message, type: SnackBarType.error);
    }

    try {
      competenceDate = TransactionDate.create(
        createAndEditTransactionBloc.competenceDate.value,
        context,
      );
    } on ValidationException catch (e) {
      CWSnackBar.snackBar(title: e.message, type: SnackBarType.error);
    }

    try {
      description = TransactionDescription.create(
        createAndEditTransactionBloc.description.value.trim(),
        context,
      );
    } on ValidationException catch (e) {
      createAndEditTransactionBloc.descriptionError.value = e.message;
    }

    if (amount == null ||
        accountId == null ||
        categoryId == null ||
        actualDate == null ||
        competenceDate == null) {
      return null;
    }

    return (
      amount,
      accountId,
      categoryId,
      actualDate,
      competenceDate,
      description,
    );
  }
}
