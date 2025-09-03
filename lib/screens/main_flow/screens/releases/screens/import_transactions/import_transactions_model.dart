// ignore_for_file: use_build_context_synchronously

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/gen/assets.gen.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/transactions_bloc.dart';

ImportTransactionsModel get importTransactionsModel =>
    Modular.get<ImportTransactionsModel>();

class ImportTransactionsModel {
  ITransactionUsecase get _transactionUsecase =>
      Modular.get<ITransactionUsecase>();
  ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();
  IAccountUsecase get _accountUsecase => Modular.get<IAccountUsecase>();

  Future<void> onTapDownloadDefaultExcelTransactions(
    BuildContext context,
  ) async {
    await AppSystemFiles.onTapDownloadDefaultExcel(
      context: context,
      filePath: Assets.lib.app.assets.excels.defaultTransactionsImportModel,
    );
  }

  Future<void> onTapUploadExcelTransactions(BuildContext context) async {
    try {
      final fileBytes = await AppSystemFiles.filePicker();
      if (fileBytes == null) {
        logger.i('No file selected by user');
        return;
      }

      final sheet = await AppSystemFiles.processExcelFile(fileBytes, context);
      if (sheet == null) return;

      final transactionsToCreate = await _parseExcelData(sheet);
      if (transactionsToCreate.isEmpty) {
        await _showError(context, context.t.messages.errors.excel_not_valid);
        return;
      }

      final importResult = await _importTransactions(transactionsToCreate);
      await transactionsBloc.loadTransactions();

      await AppSystemFiles.showImportResult(context, importResult);
    } catch (e, stackTrace) {
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

  Future<List<Map<String, dynamic>>> _parseExcelData(Sheet sheet) async {
    final transactionsToCreate = <Map<String, dynamic>>[];
    final accounts = await _getAccountsMap();
    final categories = await _getCategoriesMap();

    for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.rows[rowIndex];
      if (row.length < 7) continue;

      final transactionData = _parseExcelRow(row, accounts, categories);
      if (transactionData != null) {
        transactionsToCreate.add(transactionData);
      }
    }

    logger.i('Found ${transactionsToCreate.length} transactions to create');
    return transactionsToCreate;
  }

  Map<String, dynamic>? _parseExcelRow(
    List<Data?> row,
    Map<String, int> accounts,
    Map<String, int> categories,
  ) {
    try {
      // Expected columns: Type, ActualDate, CompetenceDate, Amount, Description, Account, Category, PaymentStatus
      final typeCell = row[0];
      final actualDateCell = row[1];
      final competenceDateCell = row[2];
      final amountCell = row[3];
      final descriptionCell = row[4];
      final accountCell = row[5];
      final categoryCell = row[6];
      final paymentStatusCell = row.length > 7 ? row[7] : null;

      if (typeCell?.value == null ||
          actualDateCell?.value == null ||
          competenceDateCell?.value == null ||
          amountCell?.value == null ||
          descriptionCell?.value == null ||
          accountCell?.value == null ||
          categoryCell?.value == null) {
        return null;
      }

      final typeStr = typeCell!.value.toString().toLowerCase();
      final description = descriptionCell!.value.toString().trim();
      final accountName = accountCell!.value.toString().trim();
      final categoryName = categoryCell!.value.toString().trim();
      final paymentStatusStr =
          paymentStatusCell?.value?.toString().toLowerCase() ?? 'paid';

      if (description.isEmpty || accountName.isEmpty || categoryName.isEmpty) {
        return null;
      }

      final transactionType = _parseTransactionType(typeStr);
      final actualDate = _parseDate(actualDateCell!.value);
      final competenceDate = _parseDate(competenceDateCell!.value);
      final amount = _parseAmount(amountCell!.value);
      final paymentStatus = _parsePaymentStatus(paymentStatusStr);
      final accountId = accounts[accountName];
      final categoryId = categories[categoryName];

      if (transactionType == null ||
          actualDate == null ||
          competenceDate == null ||
          amount == null ||
          accountId == null ||
          categoryId == null) {
        logger.w(
          'Invalid transaction data in row ${row.hashCode}: '
          'type=$typeStr, actualDate=${actualDateCell.value}, '
          'competenceDate=${competenceDateCell.value}, amount=${amountCell.value}, '
          'account=$accountName, category=$categoryName',
        );
        return null;
      }

      return {
        'transactionType': transactionType,
        'actualDate': actualDate,
        'competenceDate': competenceDate,
        'amount': amount,
        'description': description,
        'paymentStatus': paymentStatus,
        'accountId': accountId,
        'categoryId': categoryId,
      };
    } catch (e) {
      logger.e('Error parsing transaction row: $e');
      return null;
    }
  }

  FinancialType? _parseTransactionType(String typeStr) {
    if (typeStr.contains('expense') || typeStr.contains('despesa')) {
      return FinancialType.expense;
    } else if (typeStr.contains('income') || typeStr.contains('receita')) {
      return FinancialType.income;
    }
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    try {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      if (value is double) {
        // Excel date as number of days since 1900-01-01
        final days = value.toInt();
        return DateTime(1900).add(Duration(days: days - 2));
      }
      return null;
    } catch (e) {
      logger.w('Error parsing date: $value, error: $e');
      return null;
    }
  }

  double? _parseAmount(dynamic value) {
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.parse(value);
      return null;
    } catch (e) {
      logger.w('Error parsing amount: $value, error: $e');
      return null;
    }
  }

  TransactionPaymentStatus _parsePaymentStatus(String statusStr) {
    if (statusStr.contains('unpaid') || statusStr.contains('não pago')) {
      return TransactionPaymentStatus.unpaid;
    }
    return TransactionPaymentStatus.paid;
  }

  Future<Map<String, int>> _getAccountsMap() async {
    final accountsResult = await _accountUsecase.getAllAccounts();
    return accountsResult.fold(
      (Failure failure) {
        logger.e('Error loading accounts: ${failure.message}');
        return <String, int>{};
      },
      (List<AccountData> accounts) {
        final accountsMap = <String, int>{};
        for (final account in accounts) {
          accountsMap[account.name] = account.id;
        }
        return accountsMap;
      },
    );
  }

  Future<Map<String, int>> _getCategoriesMap() async {
    final incomeResult = await _categoryUsecase.getCategoriesByType(
      FinancialType.income,
    );
    final expenseResult = await _categoryUsecase.getCategoriesByType(
      FinancialType.expense,
    );

    final categoriesMap = <String, int>{};

    incomeResult.fold(
      (Failure failure) =>
          logger.e('Error loading income categories: ${failure.message}'),
      (List<CategoryData> categories) {
        for (final category in categories) {
          categoriesMap[category.name] = category.id;
        }
      },
    );

    expenseResult.fold(
      (Failure failure) =>
          logger.e('Error loading expense categories: ${failure.message}'),
      (List<CategoryData> categories) {
        for (final category in categories) {
          categoriesMap[category.name] = category.id;
        }
      },
    );

    return categoriesMap;
  }

  Future<ImportResult> _importTransactions(
    List<Map<String, dynamic>> transactionsToCreate,
  ) async {
    var successCount = 0;
    var errorCount = 0;

    logger.i('Creating ${transactionsToCreate.length} transactions...');

    for (final transactionData in transactionsToCreate) {
      final result = await _createTransaction(transactionData);
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

  Future<Either<Failure, TransactionData>> _createTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    return _transactionUsecase.createTransaction(
      transactionType: transactionData['transactionType'] as FinancialType,
      actualDate: transactionData['actualDate'] as DateTime,
      competenceDate: transactionData['competenceDate'] as DateTime,
      amount: transactionData['amount'] as double,
      description: transactionData['description'] as String,
      paymentStatus:
          transactionData['paymentStatus'] as TransactionPaymentStatus,
      recurrenceType: TransactionRecurrenceType.unique,
      accountId: transactionData['accountId'] as int,
      categoryId: transactionData['categoryId'] as int,
    );
  }

  Future<void> _showError(BuildContext context, String message) async {
    logger.w('No valid transactions found in Excel file');
    if (context.mounted) {
      CWSnackBar.snackBar(title: message, type: SnackBarType.error);
    }
  }
}
