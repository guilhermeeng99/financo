import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/account_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/transactions_bloc.dart';

import '../models/transaction_form_types.dart';
import '../models/transaction_form_validator.dart';

class TransactionOperationService {
  ITransactionUsecase get _transactionUsecase =>
      Modular.get<ITransactionUsecase>();

  Future<void> createStandardTransaction(
    StandardTransactionParams params,
    TransactionFormData formData,
  ) async {
    final result = await _transactionUsecase.createStandardTransaction(
      actualDate: params.actualDate,
      competenceDate: params.competenceDate,
      transactionType: formData.selectedTransactionType!,
      amount: params.amount,
      description: params.description,
      paymentStatus: formData.paymentStatus,
      recurrenceType: formData.recurrenceType,
      recurrenceFrequency:
          formData.recurrenceType == TransactionRecurrenceType.fixed
          ? formData.recurrenceFrequency
          : null,
      accountId: params.accountId,
      categoryId: params.categoryId,
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
        _onTransactionSuccess();
      },
    );
  }

  Future<void> createTransfer(TransferTransactionParams params) async {
    final result = await _transactionUsecase.createTransferBetweenAccounts(
      sourceAccountId: params.sourceAccountId,
      targetAccountId: params.targetAccountId,
      amount: params.amount,
      date: params.actualDate,
      description: params.description,
    );

    result.fold(
      (failure) {
        logger.e('Error creating transfer: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
      },
      (txs) {
        logger.i(
          'Transfer created successfully: ${txs.map((e) => e.id).join(',')}',
        );
        _onTransactionSuccess();
      },
    );
  }

  Future<void> updateStandardTransaction(
    int transactionId,
    StandardTransactionParams params,
    TransactionFormData formData,
    BuildContext context,
  ) async {
    final result = await _transactionUsecase.updateStandardTransaction(
      id: transactionId,
      actualDate: params.actualDate,
      competenceDate: params.competenceDate,
      amount: params.amount,
      description: params.description,
      paymentStatus: formData.paymentStatus,
      recurrenceType: formData.recurrenceType,
      recurrenceFrequency:
          formData.recurrenceType == TransactionRecurrenceType.fixed
          ? formData.recurrenceFrequency
          : null,
      accountId: params.accountId,
      categoryId: params.categoryId,
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
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        }
      },
      (transaction) {
        logger.i(
          'Transaction updated successfully: ${transaction.description}',
        );
        _onTransactionSuccess();
      },
    );
  }

  Future<void> updateTransferTransaction(
    String transferId,
    TransferTransactionParams params,
    TransactionFormData formData,
    BuildContext context,
  ) async {
    final result = await _transactionUsecase.updateTransferTransaction(
      transferId: transferId,
      actualDate: params.actualDate,
      competenceDate: params.actualDate,
      amount: params.amount,
      description: params.description,
      paymentStatus: formData.paymentStatus,
      recurrenceType: formData.recurrenceType,
      recurrenceFrequency:
          formData.recurrenceType == TransactionRecurrenceType.fixed
          ? formData.recurrenceFrequency
          : null,
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
          logger.e('Error updating transfer: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        }
      },
      (transactions) {
        logger.i(
          'Transfer updated successfully: ${transactions.map((e) => e.id).join(',')}',
        );
        _onTransactionSuccess();
      },
    );
  }

  void _onTransactionSuccess() {
    transactionsAccountsBloc.loadCheckingAccounts();
    transactionsBloc.loadTransactions();
    PopUpManager.pop();
  }
}
