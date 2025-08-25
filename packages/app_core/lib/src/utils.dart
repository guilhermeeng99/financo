import 'dart:io';

import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static Future<void> urlLaunch(String urlAux) async {
    final url0 = Uri.parse(urlAux);

    try {
      await launchUrl(url0);
    } catch (e) {
      logger.e('Could not launch $url0: $e');
    }
  }

  static void emailLaunch() {
    const email = 'support@capycare.com';
    const subject = 'Feedback - CapyCare App';

    final emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({'subject': subject}),
    );
    urlLaunch(emailLaunchUri.toString());
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}

class AppUtilsSystemFiles {
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
        AppWidgetsUtils.snackBar(
          title: context.t.excel_not_found,
          type: SnackBarType.error,
        );
      }
      return null;
    }

    logger.i('Excel sheet found with ${sheet.maxRows} rows');
    return sheet;
  }
}
