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

  Future<void> onTapSave(TransactionData? transaction) async {
    if (transaction != null) {
      await _updateTransaction(transaction);
    } else {
      await _createTransaction();
    }
  }

  Future<void> _createTransaction() async {
    final amount =
        createAndEditTransactionBloc.selectedTransactionType.value ==
            FinancialType.expense
        ? -createAndEditTransactionBloc.amount.value
        : createAndEditTransactionBloc.amount.value;

    final result = await _transactionUsecase.createTransaction(
      actualDate: createAndEditTransactionBloc.actualDate.value,
      competenceDate: createAndEditTransactionBloc.competenceDate.value,
      transactionType:
          createAndEditTransactionBloc.selectedTransactionType.value,
      amount: amount,
      description: createAndEditTransactionBloc.description.value.trim(),
      paymentStatus: createAndEditTransactionBloc.selectedPaymentStatus.value,
      recurrenceType: createAndEditTransactionBloc.selectedRecurrenceType.value,
      recurrenceFrequency:
          createAndEditTransactionBloc.selectedRecurrenceType.value ==
              TransactionRecurrenceType.fixed
          ? createAndEditTransactionBloc.selectedRecurrenceFrequency.value
          : null,
      accountId: createAndEditTransactionBloc.selectedAccountId.value,
      categoryId: createAndEditTransactionBloc.selectedCategoryId.value,
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
        accountsBloc.loadCheckingAccounts();
        transactionsBloc.loadTransactions();
        PopUpManager.pop();
      },
    );
  }

  Future<void> _updateTransaction(TransactionData originalTransaction) async {
    final amount =
        createAndEditTransactionBloc.selectedTransactionType.value ==
            FinancialType.expense
        ? -createAndEditTransactionBloc.amount.value
        : createAndEditTransactionBloc.amount.value;

    final result = await _transactionUsecase.updateTransaction(
      id: originalTransaction.id,
      actualDate: createAndEditTransactionBloc.actualDate.value,
      competenceDate: createAndEditTransactionBloc.competenceDate.value,
      amount: amount,
      description: createAndEditTransactionBloc.description.value.trim(),
      paymentStatus: createAndEditTransactionBloc.selectedPaymentStatus.value,
      recurrenceType: createAndEditTransactionBloc.selectedRecurrenceType.value,
      recurrenceFrequency:
          createAndEditTransactionBloc.selectedRecurrenceType.value ==
              TransactionRecurrenceType.fixed
          ? createAndEditTransactionBloc.selectedRecurrenceFrequency.value
          : null,
      accountId: createAndEditTransactionBloc.selectedAccountId.value,
      categoryId: createAndEditTransactionBloc.selectedCategoryId.value,
    );

    result.fold(
      (failure) {
        logger.e('Error updating transaction: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (transaction) {
        logger.i(
          'Transaction updated successfully: ${transaction.description}',
        );
        accountsBloc.loadCheckingAccounts();
        transactionsBloc.loadTransactions();
        PopUpManager.pop();
      },
    );
  }
}
