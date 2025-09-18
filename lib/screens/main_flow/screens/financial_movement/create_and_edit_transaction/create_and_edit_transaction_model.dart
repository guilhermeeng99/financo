import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

import 'create_and_edit_transaction_bloc.dart';
import 'create_and_edit_transaction_service.dart';
import 'validation/transaction_form_types.dart';
import 'validation/transaction_form_validator.dart';

CreateAndEditTransactionModel get createAndEditTransactionModel =>
    Modular.get<CreateAndEditTransactionModel>();

class CreateAndEditTransactionModel {
  final TransactionOperationService _operationService =
      TransactionOperationService();

  Future<void> onTapSave(
    DataTransaction? transaction,
    BuildContext context,
  ) async {
    createAndEditTransactionBloc.clearAllErrors();

    if (transaction != null) {
      await _updateTransaction(transaction, context);
    } else {
      await _createTransaction(context);
    }
  }

  Future<void> _createTransaction(BuildContext context) async {
    final formData = createAndEditTransactionBloc.formData.value;

    if (formData.isTransfer) {
      await _createTransfer(formData, context);
    } else {
      await _createStandardTransaction(formData, context);
    }
  }

  Future<void> _createStandardTransaction(
    TransactionFormData formData,
    BuildContext context,
  ) async {
    final validationResult =
        TransactionFormValidator.validateStandardTransaction(formData, context);

    if (validationResult.isFailure) {
      createAndEditTransactionBloc.formErrorsValue = validationResult.errors!;
      return;
    }

    await _operationService.createStandardTransaction(
      validationResult.data!,
      formData,
    );
  }

  Future<void> _createTransfer(
    TransactionFormData formData,
    BuildContext context,
  ) async {
    final validationResult =
        TransactionFormValidator.validateTransferTransaction(formData, context);

    if (validationResult.isFailure) {
      createAndEditTransactionBloc.formErrorsValue = validationResult.errors!;
      return;
    }

    await _operationService.createTransfer(validationResult.data!);
  }

  Future<void> _updateTransaction(
    DataTransaction originalTransaction,
    BuildContext context,
  ) async {
    final formData = createAndEditTransactionBloc.formData.value;

    if (formData.isTransfer) {
      await _updateTransfer(originalTransaction, formData, context);
    } else {
      await _updateStandardTransaction(originalTransaction, formData, context);
    }
  }

  Future<void> _updateStandardTransaction(
    DataTransaction originalTransaction,
    TransactionFormData formData,
    BuildContext context,
  ) async {
    final validationResult =
        TransactionFormValidator.validateStandardTransaction(formData, context);

    if (validationResult.isFailure) {
      createAndEditTransactionBloc.formErrorsValue = validationResult.errors!;
      return;
    }

    await _operationService.updateStandardTransaction(
      originalTransaction.id,
      validationResult.data!,
      formData,
      context,
    );
  }

  Future<void> _updateTransfer(
    DataTransaction originalTransaction,
    TransactionFormData formData,
    BuildContext context,
  ) async {
    final validationResult =
        TransactionFormValidator.validateTransferTransaction(formData, context);

    if (validationResult.isFailure) {
      createAndEditTransactionBloc.formErrorsValue = validationResult.errors!;
      return;
    }

    await _operationService.updateTransferTransaction(
      originalTransaction.transferId!,
      validationResult.data!,
      formData,
      context,
    );
  }
}
