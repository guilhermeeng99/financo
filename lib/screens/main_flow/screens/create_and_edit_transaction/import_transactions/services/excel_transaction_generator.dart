// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';

class ExcelTransactionGenerator {
  Future<void> generateAndDownloadTemplate(BuildContext context) async {
    try {
      final sheetName = context.t.common.labels.transactions;
      final excel = Excel.createExcel()..rename('Sheet1', sheetName);
      final sheet = excel[sheetName];

      _createHeaders(sheet, context);
      _fillSampleData(sheet, context);

      final excelBytes = excel.encode();
      if (excelBytes != null) {
        await _saveExcelFile(excelBytes, context);
        if (context.mounted) {
          _showSuccessMessage(context);
        }
      }
    } on Exception catch (e, stackTrace) {
      logger
        ..e('Error generating Excel template: $e')
        ..e('Stack trace: $stackTrace');
      if (context.mounted) {
        _showErrorMessage(context);
      }
    }
  }

  void _createHeaders(Sheet sheet, BuildContext context) {
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
  }

  void _fillSampleData(Sheet sheet, BuildContext context) {
    final sampleData = _generateSampleData(context);

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
  }

  List<List<String>> _generateSampleData(BuildContext context) {
    final random = Random();
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    final transactions = <List<String>>[];
    final amountOptions = [10, 50, 100, 200];

    for (var i = 0; i < 30; i++) {
      final monthOffset = i < 10 ? -1 : (i < 20 ? 0 : 1);
      final targetMonth = currentMonth + monthOffset;
      final targetYear =
          currentYear + (targetMonth < 1 ? -1 : (targetMonth > 12 ? 1 : 0));
      final adjustedMonth = targetMonth < 1
          ? 12
          : (targetMonth > 12 ? 1 : targetMonth);

      final daysInMonth = DateTime(targetYear, adjustedMonth + 1, 0).day;
      final day = random.nextInt(daysInMonth) + 1;
      final date =
          '$day/${adjustedMonth.toString().padLeft(2, '0')}/$targetYear';

      final isIncome = i.isEven;
      final type = isIncome
          ? context.t.transactions.types.income
          : context.t.transactions.types.expense;

      final amount = amountOptions[random.nextInt(amountOptions.length)];
      final formattedAmount = isIncome
          ? amount.toStringAsFixed(2).replaceAll('.', ',')
          : '-${amount.toStringAsFixed(2).replaceAll('.', ',')}';

      final accountNumber = random.nextInt(3) + 1;
      final categoryNumber = random.nextInt(3) + 1;

      final status = isIncome
          ? (monthOffset < 0
                ? context.t.transactions.status_type.paid
                : context.t.transactions.status_type.unpaid)
          : (monthOffset < 0
                ? context.t.transactions.status_type.paid
                : context.t.transactions.status_type.unpaid);

      transactions.add(
        _createSampleRow(
          date,
          '',
          type,
          formattedAmount,
          '${context.t.common.labels.account(n: 1)} $accountNumber',
          '${context.t.common.labels.category(n: 1)} $categoryNumber',
          status,
        ),
      );
    }

    return transactions;
  }

  List<String> _createSampleRow(
    String date,
    String description,
    String type,
    String amount,
    String account,
    String category,
    String status,
  ) {
    return [date, description, type, amount, account, category, status];
  }

  Future<void> _saveExcelFile(
    List<int> excelBytes,
    BuildContext context,
  ) async {
    final fileName = context.t.common.labels.transactions.toLowerCase();
    await AppSystemFiles.fileSaver(
      fileName: '${fileName}_import_template.xlsx',
      excelBytes: excelBytes,
    );
  }

  void _showSuccessMessage(BuildContext context) {
    CWSnackBar.snackBar(
      title: context.t.messages.success.export_successfully,
      type: SnackBarType.success,
    );
  }

  void _showErrorMessage(BuildContext context) {
    CWSnackBar.snackBar(
      title: context.t.messages.errors.excel_not_valid,
      type: SnackBarType.error,
    );
  }
}
