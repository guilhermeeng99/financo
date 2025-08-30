import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/releases_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/screens/create_and_edit_transaction/create_and_edit_transaction_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/screens/create_and_edit_transaction/create_and_edit_transaction_module.dart';
import 'package:financo/screens/main_flow/screens/releases/screens/create_and_edit_transaction/create_and_edit_transaction_screen.dart';

ReleasesModel get releasesModel => Modular.get<ReleasesModel>();

class ReleasesModel {
  void onTapFloatingActionButton() {
    PopUpManager.showDialog(
      builder: (c) => WidgetModuleProvider(
        module: CreateAndEditTransactionModule(),
        child: () => CreateAndEditTransactionPopUp(
          CreateAndEditTransactionPopUpArgs(
            type: CreateAndEditTransactionPopUpType.create,
          ),
        ),
      ),
    );
  }

  void onTapOpenTransaction(TransactionData transaction) {
    PopUpManager.showDialog(
      builder: (c) => WidgetModuleProvider(
        module: CreateAndEditTransactionModule(),
        child: () => CreateAndEditTransactionPopUp(
          CreateAndEditTransactionPopUpArgs(
            type: CreateAndEditTransactionPopUpType.edit,
            transaction: transaction,
          ),
        ),
      ),
    );
  }

  Future<void> onTapDeleteTransaction(TransactionData transaction) async {
    final transactionUsecase = Modular.get<TransactionUsecase>();

    final result = await transactionUsecase.deleteTransaction(transaction.id);

    result.fold(
      (failure) {
        logger.e('Error deleting transaction: ${failure.message}');
        AppWidgetsUtils.snackBar(
          title: 'Error deleting transaction: ${failure.message}',
          type: SnackBarType.error,
        );
      },
      (success) {
        logger.i(
          'Transaction deleted successfully: ${transaction.description}',
        );

        transactionsBloc.loadTransactions();
      },
    );
  }

  void onTapCloneTransaction(TransactionData transaction) {
    PopUpManager.showDialog(
      builder: (c) => WidgetModuleProvider(
        module: CreateAndEditTransactionModule(),
        child: () {
          createAndEditTransactionBloc.initializeWithTransactionData(
            transaction,
          );

          return CreateAndEditTransactionPopUp(
            CreateAndEditTransactionPopUpArgs(
              type: CreateAndEditTransactionPopUpType.create,
            ),
          );
        },
      ),
    );
  }

  Future<void> onTapPayOrUnpayTransaction({
    required TransactionData transaction,
    required TransactionPaymentStatus paymentStatus,
  }) async {
    final transactionUsecase = Modular.get<TransactionUsecase>();

    final result = await transactionUsecase.updateTransaction(
      id: transaction.id,
      paymentStatus: paymentStatus,
    );

    result.fold(
      (failure) {
        logger.e('Error updating payment status: ${failure.message}');
        AppWidgetsUtils.snackBar(
          title: 'Error updating payment status:  ${failure.message}',
          type: SnackBarType.error,
        );
      },
      (updatedTransaction) {
        logger.i('Payment status updated successfully');

        transactionsBloc.loadTransactions();
        accountsBloc.loadCheckingAccounts();
      },
    );
  }

  void toggleAccountEnabled(int accountId) {
    final accountIndex = accountsBloc.checkingAccounts.indexWhere(
      (account) => account.a.id == accountId,
    );

    if (accountIndex != -1) {
      accountsBloc.checkingAccounts[accountIndex].isEnabled.toggle();
    }
  }
}
