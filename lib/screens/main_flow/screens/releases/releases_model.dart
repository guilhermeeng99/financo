import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/account_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/transactions_bloc.dart';
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
    final transactionUsecase = Modular.get<ITransactionUsecase>();

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
        accountsBloc.loadCheckingAccounts();
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
    final transactionUsecase = Modular.get<ITransactionUsecase>();

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

ReleasesModelExcel get releasesModelExcel => Modular.get<ReleasesModelExcel>();

class ReleasesModelExcel {
  Future<void> onTapDownloadUserTransactions(
    BuildContext context,
    List<TransactionI> transactions,
  ) async {
    try {
      final excel = Excel.createExcel()..rename('Sheet1', 'Transactions');

      final sheet = excel['Transactions'];

      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Date');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
        'Description',
      );
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Type');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Amount');
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue(
        'Account',
      );
      sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue(
        'Category',
      );
      sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Status');

      var currentRow = 2;

      for (final transaction in transactions) {
        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 0,
                rowIndex: currentRow - 1,
              ),
            )
            .value = TextCellValue(
          '${transaction.t.actualDate.day.toString().padLeft(2, '0')}/'
          '${transaction.t.actualDate.month.toString().padLeft(2, '0')}/'
          '${transaction.t.actualDate.year}',
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 1,
                rowIndex: currentRow - 1,
              ),
            )
            .value = TextCellValue(
          transaction.t.description,
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 2,
                rowIndex: currentRow - 1,
              ),
            )
            .value = TextCellValue(
          transaction.t.transactionType.name,
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 3,
                rowIndex: currentRow - 1,
              ),
            )
            .value = DoubleCellValue(
          transaction.t.amount,
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 4,
                rowIndex: currentRow - 1,
              ),
            )
            .value = TextCellValue(
          transaction.accountName,
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 5,
                rowIndex: currentRow - 1,
              ),
            )
            .value = TextCellValue(
          transaction.categoryName,
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 6,
                rowIndex: currentRow - 1,
              ),
            )
            .value = TextCellValue(
          transaction.t.paymentStatus.name,
        );

        currentRow++;
      }

      final excelBytes = excel.save();
      if (excelBytes == null) {
        logger.e('Error generating Excel file');

        if (context.mounted) {
          AppWidgetsUtils.snackBar(
            title: context.t.messages.errors.export_error,
            type: SnackBarType.error,
          );
        }

        return;
      }

      const fileName = 'user_transactions.xlsx';

      await AppSystemFiles.fileSaver(
        fileName: fileName,
        excelBytes: excelBytes,
      );
      logger.i('Transactions archive saved successfully!');

      if (context.mounted) {
        AppWidgetsUtils.snackBar(
          title: context.t.messages.success.export_successfully,
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      logger.e('Error exporting transactions: $e');
      if (context.mounted) {
        AppWidgetsUtils.snackBar(
          title: context.t.messages.errors.export_error,
          type: SnackBarType.error,
        );
      }
    }
  }
}
