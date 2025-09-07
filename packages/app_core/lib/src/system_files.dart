import 'dart:io';

import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';

class AppSystemFiles {
  static Future<void> onTapDownloadDefaultExcel({
    required BuildContext context,
    required String filePath,
  }) async {
    try {
      final byteData = await rootBundle.load(filePath);
      final excelBytes = byteData.buffer.asUint8List();

      final fileName = filePath.split('/').last;

      await fileSaver(
        fileName: fileName,
        excelBytes: excelBytes,
      );
      logger.i('Default excel downloaded successfully!');

      if (context.mounted) {
        CWSnackBar.snackBar(
          title: context.t.messages.success.export_successfully,
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      logger.e('Error exporting default excel: $e');

      if (context.mounted) {
        CWSnackBar.snackBar(
          title: context.t.messages.errors.export_error,
          type: SnackBarType.error,
        );
      }
    }
  }

  static Future<void> showImportResult(
    BuildContext context,
    ImportResult result,
  ) async {
    if (!context.mounted) return;

    final totalProcessed = result.successCount + result.errorCount;
    final totalFound = result.validRowsFound ?? totalProcessed;

    logger.i(
      'Import result - successCount: ${result.successCount}, totalProcessed: $totalProcessed, validRowsFound: ${result.validRowsFound}',
    );

    if (result.errorCount == 0) {
      CWSnackBar.snackBar(
        title:
            '${result.successCount}/$totalFound ${context.t.messages.success.excel_import_successfully}',
        type: SnackBarType.success,
      );
    } else {
      CWSnackBar.snackBar(
        title:
            '${result.successCount}/$totalFound ${context.t.messages.errors.excel_not_valid}',
        type: SnackBarType.error,
      );
    }
  }

  static Future<void> fileSaver({
    required String fileName,
    required List<int> excelBytes,
  }) async {
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(excelBytes),
      mimeType: MimeType.microsoftExcel,
    );
  }

  static Future<Uint8List?> filePicker() async {
    String? selectedFilePath;
    try {
      if (Platform.isWindows) {
        selectedFilePath = await _windowsFilePicker();
      } else {
        logger.e('Platform not supported for file picking');
        return null;
      }

      if (selectedFilePath == null) {
        logger.i('No file selected by user');
        return null;
      }

      logger.i('File selected: $selectedFilePath');

      final fileName = selectedFilePath.toLowerCase();
      if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
        logger.w('Selected file is not an Excel file');
        return null;
      }

      try {
        final file = File(selectedFilePath);
        final bytes = await file.readAsBytes();
        logger.i('File read successfully (${bytes.length} bytes)');
        return Uint8List.fromList(bytes);
      } catch (e) {
        logger.e('Error reading file: $e');
        return null;
      }
    } catch (e, stackTrace) {
      logger
        ..e('Error in file picker: $e')
        ..e('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<String?> _windowsFilePicker() async {
    try {
      logger.i('Using Windows PowerShell file picker...');

      const script = r'''
Add-Type -AssemblyName System.Windows.Forms
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Title = "Selecione um arquivo Excel"
$openFileDialog.Filter = "Arquivos Excel|*.xlsx;*.xls|Todos os arquivos|*.*"
$openFileDialog.FilterIndex = 1
$openFileDialog.Multiselect = $false

if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output $openFileDialog.FileName
} else {
    exit 1
}
''';

      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', script],
      );

      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      } else {
        logger.i('User cancelled file selection or dialog failed');
        return null;
      }
    } catch (e) {
      logger.e('Windows file picker failed: $e');
      return null;
    }
  }

  static Future<Sheet?> processExcelFile(
    Uint8List fileBytes,
    BuildContext context,
  ) async {
    logger.i('File selected, processing Excel data...');

    final excel = Excel.decodeBytes(fileBytes);
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];

    if (sheet == null) {
      logger.e('Excel sheet not found');
      if (context.mounted) {
        CWSnackBar.snackBar(
          title: context.t.messages.errors.excel_not_found,
          type: SnackBarType.error,
        );
      }
      return null;
    }

    var validRowsCount = 0;

    for (var rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.rows[rowIndex];
      final rowData = <String>[];

      for (var colIndex = 0; colIndex < row.length; colIndex++) {
        final cellValue = row[colIndex]?.value?.toString() ?? 'NULL';
        rowData.add(cellValue);
      }

      final isEmpty =
          rowData.every((cell) => cell == 'NULL' || cell.trim().isEmpty);

      if (!isEmpty) {
        validRowsCount++;
        logger.i(
          'Valid Row $validRowsCount (index $rowIndex): [${rowData.join(', ')}]',
        );
      }
    }

    logger.i(
      'Excel sheet found with $validRowsCount valid rows out of ${sheet.maxRows} total rows and ${sheet.maxColumns} columns',
    );

    return sheet;
  }
}

class ImportResult {
  const ImportResult(this.successCount, this.errorCount, [this.validRowsFound]);

  final int successCount;
  final int errorCount;
  final int? validRowsFound;

  int get totalProcessed => successCount + errorCount;
}
