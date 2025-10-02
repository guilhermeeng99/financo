// ignore_for_file: depend_on_referenced_packages

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/validation/transaction_form_types.dart';

class ExcelTransactionParser {
  TransactionFormData? parseExcelRow(
    List<Data?> row,
    Map<String, int> accounts,
    Map<String, int> categories,
    BuildContext context,
  ) {
    try {
      final dateCell = row[0];
      final descriptionCell = row[1];
      final amountCell = row[3];
      final accountCell = row[4];
      final categoryCell = row[5];
      final paymentStatusCell = row.length > 6 ? row[6] : null;

      if (!_validateRequiredCells(
        dateCell,
        amountCell,
        accountCell,
        categoryCell,
      )) {
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
      final rawAmount = _parseAmount(amountCell!.value);

      if (!_validateParsedValues(
        date,
        rawAmount,
        accountName,
        categoryName,
        accounts,
        categories,
      )) {
        return null;
      }

      final transactionScreenType = _determineTransactionType(rawAmount!);
      final amount = rawAmount.abs();
      final paymentStatus = _parsePaymentStatus(paymentStatusStr, context);
      final accountId = accounts[accountName];
      final categoryId = categories[categoryName];

      logger.d(
        'Parsed values: transactionScreenType=$transactionScreenType, date=$date, amount=$amount, '
        'accountId=$accountId, categoryId=$categoryId, paymentStatus=$paymentStatus',
      );

      if (amount == 0.0) {
        logger.w('Skipping transaction with zero amount');
        return null;
      }

      return TransactionFormData(
        description: description,
        amount: amount,
        actualDate: date,
        competenceDate: date,
        transactionScreenType: transactionScreenType,
        paymentStatus: paymentStatus!,
        selectedAccountId: accountId,
        selectedCategoryId: categoryId,
      );
    } on Exception catch (e) {
      logger.e('Error parsing transaction row: $e');
      return null;
    }
  }

  bool _validateRequiredCells(
    Data? dateCell,
    Data? amountCell,
    Data? accountCell,
    Data? categoryCell,
  ) {
    if (dateCell?.value == null ||
        amountCell?.value == null ||
        accountCell?.value == null ||
        categoryCell?.value == null) {
      logger.w(
        'Skipping row due to null values: '
        'date=${dateCell?.value}, amount=${amountCell?.value}, '
        'account=${accountCell?.value}, category=${categoryCell?.value}',
      );
      return false;
    }
    return true;
  }

  bool _validateParsedValues(
    DateTime? date,
    double? rawAmount,
    String accountName,
    String categoryName,
    Map<String, int> accounts,
    Map<String, int> categories,
  ) {
    if (accountName.isEmpty || categoryName.isEmpty) {
      logger.w(
        'Skipping row due to empty strings: '
        'accountName.isEmpty=${accountName.isEmpty}, '
        'categoryName.isEmpty=${categoryName.isEmpty}',
      );
      return false;
    }

    if (date == null) {
      logger.w('Invalid date value');
      return false;
    }

    if (rawAmount == null) {
      logger.w('Invalid amount value');
      return false;
    }

    final accountId = accounts[accountName];
    if (accountId == null) {
      logger.w(
        'Account not found: "$accountName". Available accounts: ${accounts.keys.toList()}',
      );
      return false;
    }

    final categoryId = categories[categoryName];
    if (categoryId == null) {
      logger.w(
        'Category not found: "$categoryName". Available categories: ${categories.keys.toList()}',
      );
      return false;
    }

    return true;
  }

  TransactionScreenType _determineTransactionType(double rawAmount) {
    return rawAmount >= 0
        ? TransactionScreenType.income
        : TransactionScreenType.expense;
  }

  DateTime? _parseDate(dynamic value) {
    try {
      logger.d('_parseDate: input=$value, type=${value.runtimeType}');

      if (value is DateTime) return value;

      if (value.runtimeType.toString() == 'DateCellValue') {
        return _parseDateCellValue(value);
      }

      if (value.runtimeType.toString() == 'TextCellValue') {
        final stringValue = value.toString();
        logger.d('_parseDate: TextCellValue.toString() = $stringValue');
        return _parseStringDate(stringValue);
      }

      if (value is String) {
        return _parseStringDate(value);
      }

      if (value is double) {
        return _parseExcelSerialDate(value);
      }

      logger.w('_parseDate: unhandled type ${value.runtimeType}');
      return null;
    } on Exception catch (e) {
      logger.w('Error parsing date: $value, error: $e');
      return null;
    }
  }

  DateTime? _parseDateCellValue(dynamic value) {
    try {
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
    return null;
  }

  DateTime? _parseStringDate(String value) {
    try {
      if (value.contains('T') && value.contains('Z')) {
        final parsed = DateTime.parse(value).toLocal();
        logger.d('_parseDate: ISO string parsed to $parsed');
        return parsed;
      }

      if (value.contains('/')) {
        final parts = value.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            final parsed = DateTime(year, month, day);
            logger.d('_parseDate: dd/MM/yyyy format parsed to $parsed');
            return parsed;
          }
        }
      }

      final parsed = DateTime.parse(value);
      logger.d('_parseDate: string parsed to $parsed');
      return parsed;
    } on Exception catch (e) {
      logger.w('Error parsing string date "$value": $e');
      return null;
    }
  }

  DateTime _parseExcelSerialDate(double value) {
    final days = value.toInt();
    final parsed = DateTime(1900).add(Duration(days: days - 2));
    logger.d('_parseDate: double parsed to $parsed');
    return parsed;
  }

  double? _parseAmount(dynamic value) {
    try {
      logger.d('_parseAmount: input=$value, type=${value.runtimeType}');

      if (value is double) return value;
      if (value is int) return value.toDouble();

      String stringValue;
      if (value.runtimeType.toString() == 'TextCellValue') {
        stringValue = value.toString();
        logger.d('_parseAmount: TextCellValue.toString() = $stringValue');
      } else if (value is String) {
        stringValue = value;
      } else {
        stringValue = value.toString();
      }

      final cleanValue = stringValue.trim().replaceAll(',', '.');
      final parsed = double.parse(cleanValue);
      logger.d('_parseAmount: parsed to $parsed');
      return parsed;
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
}
