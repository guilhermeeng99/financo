// ignore_for_file: use_build_context_synchronously

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';

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
    try {
      final sheetName = context.t.common.labels.transactions;
      final excel = Excel.createExcel()..rename('Sheet1', sheetName);

      final sheet = excel[sheetName];

      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
        context.t.common.labels.date,
      );
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
        context.t.common.labels.description,
      );
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
        context.t.common.labels.type,
      );
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue(
        context.t.common.labels.amount,
      );
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue(
        context.t.common.labels.account(n: 1),
      );
      sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue(
        context.t.common.labels.category(n: 1),
      );
      sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue(
        context.t.common.labels.status,
      );

      final sampleData = _sampleDataForTransactionsDownload(context);

      for (var i = 0; i < sampleData.length; i++) {
        final row = sampleData[i];
        sheet.cell(CellIndex.indexByString('A${i + 2}')).value = TextCellValue(
          row[0],
        );
        sheet.cell(CellIndex.indexByString('B${i + 2}')).value = TextCellValue(
          row[1],
        );
        sheet.cell(CellIndex.indexByString('C${i + 2}')).value = TextCellValue(
          row[2],
        );
        sheet.cell(CellIndex.indexByString('D${i + 2}')).value = TextCellValue(
          row[3],
        );
        sheet.cell(CellIndex.indexByString('E${i + 2}')).value = TextCellValue(
          row[4],
        );
        sheet.cell(CellIndex.indexByString('F${i + 2}')).value = TextCellValue(
          row[5],
        );
        sheet.cell(CellIndex.indexByString('G${i + 2}')).value = TextCellValue(
          row[6],
        );
      }

      final excelBytes = excel.encode();
      if (excelBytes != null) {
        final sheetName = context.t.common.labels.transactions.toLowerCase();
        await AppSystemFiles.fileSaver(
          fileName: '${sheetName}_import_template.xlsx',
          excelBytes: excelBytes,
        );

        if (context.mounted) {
          CWSnackBar.snackBar(
            title: context.t.messages.success.export_successfully,
            type: SnackBarType.success,
          );
        }
      }
    } on Exception catch (e, stackTrace) {
      logger
        ..e('Error generating Excel template: $e')
        ..e('Stack trace: $stackTrace');

      if (context.mounted) {
        CWSnackBar.snackBar(
          title: context.t.messages.errors.excel_not_valid,
          type: SnackBarType.error,
        );
      }
    }
  }

  List<List<String>> _sampleDataForTransactionsDownload(BuildContext context) {
    return [
      [
        '31/08/2025',
        '',
        context.t.transactions.types.income,
        '100,00',
        '${context.t.common.labels.account(n: 1)} 1',
        '${context.t.common.labels.category(n: 1)} 2',
        context.t.transactions.status_type.unpaid,
      ],
      [
        '31/08/2025',
        '',
        context.t.transactions.types.expense,
        '-100,00',
        '${context.t.common.labels.account(n: 1)} 2',
        '${context.t.common.labels.category(n: 1)} 1',
        context.t.transactions.status_type.unpaid,
      ],
      [
        '31/08/2025',
        '',
        context.t.transactions.types.income,
        '200,00',
        '${context.t.common.labels.account(n: 1)} 2',
        '${context.t.common.labels.category(n: 1)} 2',
        context.t.transactions.status_type.unpaid,
      ],
      [
        '31/08/2025',
        '',
        context.t.transactions.types.expense,
        '-50,00',
        '${context.t.common.labels.account(n: 1)} 1',
        '${context.t.common.labels.category(n: 1)} 1',
        context.t.transactions.status_type.unpaid,
      ],
      [
        '31/08/2025',
        '',
        context.t.transactions.types.expense,
        '-50,00',
        '${context.t.common.labels.account(n: 1)} 1',
        '${context.t.common.labels.category(n: 1)} 1',
        context.t.transactions.status_type.unpaid,
      ],
      [
        '31/07/2025',
        '',
        context.t.transactions.types.income,
        '100,00',
        '${context.t.common.labels.account(n: 1)} 1',
        '${context.t.common.labels.category(n: 1)} 2',
        context.t.transactions.status_type.paid,
      ],
      [
        '31/07/2025',
        '',
        context.t.transactions.types.expense,
        '-100,00',
        '${context.t.common.labels.account(n: 1)} 2',
        '${context.t.common.labels.category(n: 1)} 1',
        context.t.transactions.status_type.paid,
      ],
      [
        '31/07/2025',
        '',
        context.t.transactions.types.income,
        '200,00',
        '${context.t.common.labels.account(n: 1)} 2',
        '${context.t.common.labels.category(n: 1)} 2',
        context.t.transactions.status_type.paid,
      ],
      [
        '31/07/2025',
        '',
        context.t.transactions.types.expense,
        '-50,00',
        '${context.t.common.labels.account(n: 1)} 1',
        '${context.t.common.labels.category(n: 1)} 1',
        context.t.transactions.status_type.paid,
      ],
      [
        '31/07/2025',
        '',
        context.t.transactions.types.expense,
        '-50,00',
        '${context.t.common.labels.account(n: 1)} 1',
        '${context.t.common.labels.category(n: 1)} 1',
        context.t.transactions.status_type.paid,
      ],
    ];
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

      final transactionsToCreate = await _parseExcelData(sheet, context);
      if (transactionsToCreate.isEmpty) {
        await _showError(context, context.t.messages.errors.excel_not_valid);
        return;
      }

      final importResult = await _importTransactions(
        transactionsToCreate,
        context,
      );
      await coreTransactionsBloc.loadTransactions();

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

  Future<List<Map<String, dynamic>>> _parseExcelData(
    Sheet sheet,
    BuildContext context,
  ) async {
    final transactionsToCreate = <Map<String, dynamic>>[];
    final accounts = await _getAccountsMap();
    logger.i('Available accounts: ${accounts.keys.toList()}');
    final categories = await _getCategoriesMap();
    logger.i('Available categories: ${categories.keys.toList()}');

    for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.rows[rowIndex];
      if (row.length < 7) continue;

      logger.d(
        'Processing row ${rowIndex + 1}: ${row.map((cell) => cell?.value).toList()}',
      );
      final transactionData = _parseExcelRow(
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

  Map<String, dynamic>? _parseExcelRow(
    List<Data?> row,
    Map<String, int> accounts,
    Map<String, int> categories,
    BuildContext context,
  ) {
    try {
      // Expected columns: Date, Description, Type, Amount, Account, Category, Status
      // Note: Type column is ignored, transaction type is determined by amount sign
      final dateCell = row[0];
      final descriptionCell = row[1];
      final amountCell = row[3];
      final accountCell = row[4];
      final categoryCell = row[5];
      final paymentStatusCell = row.length > 6 ? row[6] : null;

      if (dateCell?.value == null ||
          amountCell?.value == null ||
          accountCell?.value == null ||
          categoryCell?.value == null) {
        logger.w(
          'Skipping row due to null values: '
          'date=${dateCell?.value}, amount=${amountCell?.value}, '
          'account=${accountCell?.value}, '
          'category=${categoryCell?.value}',
        );
        return null;
      }

      final description = descriptionCell?.value?.toString().trim() ?? '';
      final accountName = accountCell!.value.toString().trim();
      final categoryName = categoryCell!.value.toString().trim();
      final paymentStatusStr =
          paymentStatusCell?.value?.toString().toLowerCase() ?? 'paid';

      logger.d(
        'Raw extracted values: description="$description", accountName="$accountName", categoryName="$categoryName", paymentStatusStr="$paymentStatusStr"',
      );

      final date = _parseDate(dateCell!.value);
      logger.d('Date parsing: input=${dateCell.value}, output=$date');

      final actualDate = date;
      final competenceDate = date;
      final rawAmount = _parseAmount(amountCell!.value);
      logger.d('Amount parsing: input=${amountCell.value}, output=$rawAmount');

      // Determine transaction type based on amount sign (positive = income, negative = expense)
      final transactionType = rawAmount != null && rawAmount >= 0
          ? FinancialType.income
          : FinancialType.expense;

      // Pass the original amount with sign to TransactionAmount.create
      final amount = rawAmount;
      final paymentStatus = _parsePaymentStatus(paymentStatusStr, context);
      logger.d(
        'Payment status parsing: input="$paymentStatusStr", output=$paymentStatus',
      );

      final accountId = accounts[accountName];
      final categoryId = categories[categoryName];

      if (accountName.isEmpty || categoryName.isEmpty) {
        logger.w(
          'Skipping row due to empty strings: '
          'accountName.isEmpty=${accountName.isEmpty}, '
          'categoryName.isEmpty=${categoryName.isEmpty}',
        );
        return null;
      }

      logger.d(
        'Parsed values: transactionType=$transactionType (determined by amount sign), date=$date, rawAmount=$rawAmount, amount=$amount, '
        'accountName="$accountName" -> accountId=$accountId, '
        'categoryName="$categoryName" -> categoryId=$categoryId, '
        'paymentStatus=$paymentStatus',
      );

      if (actualDate == null ||
          competenceDate == null ||
          amount == null ||
          accountId == null ||
          categoryId == null ||
          paymentStatus == null) {
        logger.w(
          'Invalid transaction data in row ${row.hashCode}: '
          'date=${dateCell.value}, description=$description, '
          'rawAmount=${amountCell.value}, parsedAmount=$rawAmount, finalAmount=$amount, '
          'account=$accountName, category=$categoryName, status=$paymentStatusStr, '
          'transactionType=$transactionType, actualDate=$actualDate, '
          'competenceDate=$competenceDate, accountId=$accountId, '
          'categoryId=$categoryId, paymentStatus=$paymentStatus',
        );
        return null;
      }

      // Validate amount is not zero
      if (amount == 0.0) {
        logger.w(
          'Skipping transaction with zero amount in row ${row.hashCode}',
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
    } on Exception catch (e) {
      logger.e('Error parsing transaction row: $e');
      return null;
    }
  }

  DateTime? _parseDate(dynamic value) {
    try {
      logger.d('_parseDate: input=$value, type=${value.runtimeType}');
      if (value is DateTime) return value;

      // Handle DateCellValue from Excel package
      if (value.runtimeType.toString() == 'DateCellValue') {
        try {
          // Use toString() which gives us the ISO date string
          final stringValue = value.toString();
          logger.d('_parseDate: DateCellValue.toString() = $stringValue');

          if (stringValue.contains('T') && stringValue.contains('Z')) {
            final parsed = DateTime.parse(stringValue).toLocal();
            logger.d('_parseDate: DateCellValue parsed to $parsed');
            return parsed;
          }
        } on Exception catch (e) {
          logger.w('Error parsing DateCellValue toString: $e');
        }
      }

      if (value is String) {
        if (value.contains('T') && value.contains('Z')) {
          final parsed = DateTime.parse(value).toLocal();
          logger.d('_parseDate: ISO string parsed to $parsed');
          return parsed;
        }
        final parsed = DateTime.parse(value);
        logger.d('_parseDate: string parsed to $parsed');
        return parsed;
      }
      if (value is double) {
        final days = value.toInt();
        final parsed = DateTime(1900).add(Duration(days: days - 2));
        logger.d('_parseDate: double parsed to $parsed');
        return parsed;
      }
      logger.w('_parseDate: unhandled type ${value.runtimeType}');
      return null;
    } on Exception catch (e) {
      logger.w('Error parsing date: $value, error: $e');
      return null;
    }
  }

  double? _parseAmount(dynamic value) {
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Replace comma with dot for Portuguese number format
        final cleanValue = value.trim().replaceAll(',', '.');
        return double.parse(cleanValue);
      }
      // Handle numeric values that come as other types
      final numValue = double.tryParse(value.toString());
      return numValue;
    } on Exception catch (e) {
      logger.w(
        'Error parsing amount: $value (type: ${value.runtimeType}), error: $e',
      );
      return null;
    }
  }

  TransactionPaymentStatus? _parsePaymentStatus(
    String statusStr,
    BuildContext context,
  ) {
    final lowercaseStatus = statusStr.toLowerCase().trim();
    final unpaidText = context.t.transactions.status_type.unpaid.toLowerCase();
    final paidText = context.t.transactions.status_type.paid.toLowerCase();

    logger.d(
      'Payment status comparison: input="$lowercaseStatus", unpaid="$unpaidText", paid="$paidText"',
    );

    if (lowercaseStatus.contains(unpaidText)) {
      return TransactionPaymentStatus.unpaid;
    } else if (lowercaseStatus.contains(paidText)) {
      return TransactionPaymentStatus.paid;
    }

    logger.w('Unknown payment status: "$statusStr", defaulting to paid');
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
    BuildContext context,
  ) async {
    var successCount = 0;
    var errorCount = 0;

    logger.i('Creating ${transactionsToCreate.length} transactions...');

    for (final transactionData in transactionsToCreate) {
      final result = await _createStandardTransaction(transactionData, context);
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
    Map<String, dynamic> transactionData,
    BuildContext context,
  ) async {
    try {
      logger.d(
        'Creating transaction: amount=${transactionData['amount']}, type=${transactionData['transactionType']}',
      );
      final amount = TransactionAmount.create(
        transactionData['amount'] as double,

        transactionType: transactionData['transactionType'] as FinancialType,
      );

      final accountId = TransactionAccountId.create(
        transactionData['accountId'] as int,
      );

      final categoryId = TransactionCategoryId.create(
        transactionData['categoryId'] as int,
      );

      final actualDate = TransactionDate.create(
        transactionData['actualDate'] as DateTime,
      );

      final competenceDate = TransactionDate.create(
        transactionData['competenceDate'] as DateTime,
      );

      final description = TransactionDescription.create(
        transactionData['description'] as String,
      );

      return _transactionUsecase.createStandardTransaction(
        transactionType: transactionData['transactionType'] as FinancialType,
        actualDate: actualDate,
        competenceDate: competenceDate,
        amount: amount,
        description: description,
        paymentStatus:
            transactionData['paymentStatus'] as TransactionPaymentStatus,
        recurrenceType: TransactionRecurrenceType.unique,
        accountId: accountId,
        categoryId: categoryId,
      );
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    }
  }

  Future<void> _showError(BuildContext context, String message) async {
    logger.w('No valid transactions found in Excel file');
    if (context.mounted) {
      CWSnackBar.snackBar(title: message, type: SnackBarType.error);
    }
  }
}
