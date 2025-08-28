import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/releases_bloc.dart';

import 'create_and_edit_transaction_bloc.dart';

CreateAndEditTransactionModel get createAndEditTransactionModel =>
    Modular.get<CreateAndEditTransactionModel>();

class CreateAndEditTransactionModel {
  TransactionUsecase get _transactionUsecase =>
      Modular.get<TransactionUsecase>();

  Future<void> onTapSave(TransactionData? transaction) async {
    final canSave =
        createAndEditTransactionBloc.amount.value != 0 &&
        createAndEditTransactionBloc.selectedAccountId.value != null &&
        createAndEditTransactionBloc.selectedCategoryId.value != null;

    if (canSave) {
      if (transaction != null) {
        await _updateTransaction(transaction);
      } else {
        await _createTransaction();
      }
    }
  }

  Future<void> _createTransaction() async {
    final result = await _transactionUsecase.createTransaction(
      actualDate: createAndEditTransactionBloc.actualDate.value,
      competenceDate: createAndEditTransactionBloc.competenceDate.value,
      transactionType:
          createAndEditTransactionBloc.selectedTransactionType.value,
      amount: createAndEditTransactionBloc.amount.value,
      description: createAndEditTransactionBloc.description.value.trim(),
      paymentStatus: createAndEditTransactionBloc.selectedPaymentStatus.value,
      recurrenceType: createAndEditTransactionBloc.selectedRecurrenceType.value,
      recurrenceFrequency:
          createAndEditTransactionBloc.selectedRecurrenceType.value ==
              TransactionRecurrenceType.fixed
          ? createAndEditTransactionBloc.selectedRecurrenceFrequency.value
          : null,
      accountId: createAndEditTransactionBloc.selectedAccountId.value!,
      categoryId: createAndEditTransactionBloc.selectedCategoryId.value!,
    );

    result.fold(
      (failure) {
        logger.e('Error creating transaction: ${failure.message}');
        AppWidgetsUtils.snackBar(
          title: failure.message,
          type: SnackBarType.error,
        );
      },
      (transaction) {
        logger.i(
          'Transaction created successfully: ${transaction.description}',
        );

        releasesBloc.loadTransactions();
        PopUpManager.pop();
      },
    );
  }

  Future<void> _updateTransaction(TransactionData originalTransaction) async {
    final result = await _transactionUsecase.updateTransaction(
      id: originalTransaction.id,
      actualDate: createAndEditTransactionBloc.actualDate.value,
      competenceDate: createAndEditTransactionBloc.competenceDate.value,
      amount: createAndEditTransactionBloc.amount.value,
      description: createAndEditTransactionBloc.description.value.trim(),
      paymentStatus: createAndEditTransactionBloc.selectedPaymentStatus.value,
      recurrenceType: createAndEditTransactionBloc.selectedRecurrenceType.value,
      recurrenceFrequency:
          createAndEditTransactionBloc.selectedRecurrenceType.value ==
              TransactionRecurrenceType.fixed
          ? createAndEditTransactionBloc.selectedRecurrenceFrequency.value
          : null,
      accountId: createAndEditTransactionBloc.selectedAccountId.value!,
      categoryId: createAndEditTransactionBloc.selectedCategoryId.value!,
    );

    result.fold(
      (failure) {
        logger.e('Error updating transaction: ${failure.message}');
        AppWidgetsUtils.snackBar(
          title: failure.message,
          type: SnackBarType.error,
        );
      },
      (transaction) {
        logger.i(
          'Transaction updated successfully: ${transaction.description}',
        );

        releasesBloc.loadTransactions();
        PopUpManager.pop();
      },
    );
  }
}
