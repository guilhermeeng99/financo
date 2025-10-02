// ignore_for_file: depend_on_referenced_packages

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/import_transactions/services/excel_transaction_generator.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/import_transactions/services/excel_transaction_parser.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/import_transactions/services/transaction_data_loader.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/validation/transaction_form_types.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/validation/transaction_form_validator.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/validation/transaction_validation_exceptions.dart';

ImportTransactionsModel get importTransactionsModel =>
    Modular.get<ImportTransactionsModel>();

class ImportTransactionsModel {
  ImportTransactionsModel({
    ExcelTransactionGenerator? excelGenerator,
    ExcelTransactionParser? excelParser,
    TransactionDataLoader? dataLoader,
  }) : _excelGenerator = excelGenerator ?? ExcelTransactionGenerator(),
       _excelParser = excelParser ?? ExcelTransactionParser(),
       _dataLoader =
           dataLoader ??
           TransactionDataLoader(
             accountUsecase: Modular.get<IAccountUsecase>(),
             categoryUsecase: Modular.get<ICategoryUsecase>(),
           );

  final ExcelTransactionGenerator _excelGenerator;
  final ExcelTransactionParser _excelParser;
  final TransactionDataLoader _dataLoader;

  ITransactionUsecase get _transactionUsecase =>
      Modular.get<ITransactionUsecase>();

  Future<void> onTapDownloadDefaultExcelTransactions(
    BuildContext context,
  ) async {
    await _excelGenerator.generateAndDownloadTemplate(context);
  }

  Future<void> onTapUploadExcelTransactions(BuildContext context) async {
    try {
      final fileBytes = await AppSystemFiles.filePicker();
      if (fileBytes == null) {
        logger.i('No file selected by user');
        return;
      }

      if (!context.mounted) return;
      final sheet = await AppSystemFiles.processExcelFile(fileBytes, context);
      if (sheet == null) return;

      if (!context.mounted) return;
      final transactionsToCreate = await _parseExcelData(sheet, context);
      if (transactionsToCreate.isEmpty) {
        if (!context.mounted) return;
        final errorMessage = context.t.messages.errors.excel_not_valid;
        await _showError(context, errorMessage);
        return;
      }

      if (!context.mounted) return;
      final importResult = await _importTransactions(
        transactionsToCreate,
        context,
      );
      await coreTransactionsBloc.loadTransactions();

      if (!context.mounted) return;
      await AppSystemFiles.showImportResult(context, importResult);
    } on Exception catch (e, stackTrace) {
      logger
        ..e('Error importing transactions from Excel: $e')
        ..e('Stack trace: $stackTrace');

      if (context.mounted) {
        CWSnackBar.snackBar(
          title: context.t.messages.errors.excel_not_valid,
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<List<TransactionFormData>> _parseExcelData(
    Sheet sheet,
    BuildContext context,
  ) async {
    final transactionsToCreate = <TransactionFormData>[];
    final accounts = await _dataLoader.getAccountsMap();
    logger.i('Available accounts: ${accounts.keys.toList()}');
    final categories = await _dataLoader.getCategoriesMap();
    logger.i('Available categories: ${categories.keys.toList()}');

    if (accounts.isEmpty) {
      logger.e('No accounts found. Cannot import transactions.');
      if (context.mounted) {
        await _showError(
          context,
          context.t.messages.errors.no_accounts_to_import,
        );
      }
      return transactionsToCreate;
    }

    if (categories.isEmpty) {
      logger.e('No categories found. Cannot import transactions.');
      if (context.mounted) {
        await _showError(
          context,
          context.t.messages.errors.no_categories_to_import,
        );
      }
      return transactionsToCreate;
    }

    if (!context.mounted) return transactionsToCreate;

    for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.rows[rowIndex];
      if (row.length < 7) continue;

      logger.d(
        'Processing row ${rowIndex + 1}: ${row.map((cell) => cell?.value).toList()}',
      );
      final transactionData = _excelParser.parseExcelRow(
        row,
        accounts,
        categories,
        context,
      );
      if (transactionData != null) {
        transactionsToCreate.add(transactionData);
      }
    }

    logger.i('Found ${transactionsToCreate.length} transactions to create');
    return transactionsToCreate;
  }

  Future<ImportResult> _importTransactions(
    List<TransactionFormData> transactionsToCreate,
    BuildContext context,
  ) async {
    var successCount = 0;
    var errorCount = 0;

    logger.i('Creating ${transactionsToCreate.length} transactions...');

    for (final formData in transactionsToCreate) {
      final result = await _createStandardTransaction(formData, context);
      result.fold(
        (failure) {
          errorCount++;
          logger.e('Error creating transaction: ${failure.message}');
        },
        (createdTransaction) {
          successCount++;
          logger.i('Transaction created: ${createdTransaction.description}');
        },
      );
    }

    logger.i('Import completed: $successCount success, $errorCount errors');
    return ImportResult(successCount, errorCount);
  }

  Future<Either<Failure, StandardTransaction>> _createStandardTransaction(
    TransactionFormData formData,
    BuildContext context,
  ) async {
    try {
      logger.d(
        'Validating transaction: amount=${formData.amount}, type=${formData.transactionScreenType}',
      );

      final validationResult =
          TransactionFormValidator.validateStandardTransaction(
            formData,
            context,
          );

      if (validationResult.isFailure) {
        final errors = validationResult.errors!;
        final errorMessage = _collectErrorMessages(errors);
        logger.w('Validation failed: $errorMessage');
        return Either.left(ValidationFailure(errorMessage));
      }

      final params = validationResult.data!;
      logger.d(
        'Creating transaction: amount=${params.amount.value}, type=${formData.selectedTransactionType}',
      );

      final transactionType = formData.transactionScreenType.financialType;
      if (transactionType == null) {
        logger.e('Invalid transaction type: transfer not supported in import');
        return Either.left(
          const ValidationFailure(
            'Transfer transactions are not supported in import',
          ),
        );
      }

      return _transactionUsecase.createStandardTransaction(
        transactionType: transactionType,
        actualDate: params.actualDate,
        competenceDate: params.competenceDate,
        amount: params.amount,
        description: params.description,
        paymentStatus: formData.paymentStatus,
        recurrenceType: formData.recurrenceType,
        accountId: params.accountId,
        categoryId: params.categoryId,
      );
    } on Exception catch (e) {
      final errorMessage = TransactionValidationException.getMessage(
        e,
        context,
      );
      logger.e('Error creating transaction: $errorMessage');
      return Either.left(ValidationFailure(errorMessage));
    }
  }

  String _collectErrorMessages(TransactionFormErrors errors) {
    final errorMessages = [
      errors.description,
      errors.amount,
      errors.account,
      errors.category,
      errors.actualDate,
    ].where((error) => error.isNotEmpty);

    return errorMessages.join(', ');
  }

  Future<void> _showError(BuildContext context, String message) async {
    logger.w('No valid transactions found in Excel file');
    if (context.mounted) {
      CWSnackBar.snackBar(title: message, type: SnackBarType.error);
    }
  }
}
