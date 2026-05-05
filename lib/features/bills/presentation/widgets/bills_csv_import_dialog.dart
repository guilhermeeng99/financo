import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/csv_example_downloader.dart';
import 'package:financo/features/bills/domain/usecases/import_bills_csv_usecase.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _exampleAssetPath = 'lib/app/assets/samples/bills_example.csv';

enum _CsvImportAction { downloadExample, selectFile }

/// Three-button entry dialog (Cancel / Download example / Select file)
/// mirroring the categories/accounts/transactions import dialogs. We
/// intentionally skip the multi-step preview page here — bills don't
/// reference accounts and category resolution is best-effort, so a
/// straight "import → toast result" flow keeps the UX simple.
Future<void> showBillsCsvImportDialog(BuildContext context) async {
  final action = await showDialog<_CsvImportAction>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.bills.importCsvIntroTitle),
      content: Text(t.bills.importCsvIntroBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t.general.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext)
              .pop(_CsvImportAction.downloadExample),
          child: Text(t.bills.importCsvDownloadExample),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_CsvImportAction.selectFile),
          child: Text(t.bills.importCsvSelectFile),
        ),
      ],
    ),
  );

  if (action == null || !context.mounted) return;

  switch (action) {
    case _CsvImportAction.downloadExample:
      await _downloadExample(context);
    case _CsvImportAction.selectFile:
      await _pickAndImport(context);
  }
}

Future<void> _downloadExample(BuildContext context) async {
  bool didSave;
  try {
    didSave = await downloadCsvExample(
      assetPath: _exampleAssetPath,
      fileName: 'bills_example.csv',
      dialogTitle: t.bills.importCsvDownloadExample,
    );
  } on Exception {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.bills.importCsvExampleFailed)),
    );
    return;
  }

  if (!context.mounted || !didSave) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.bills.importCsvExampleDownloaded)),
  );
}

Future<void> _pickAndImport(BuildContext context) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
    withData: true,
  );

  final bytes = result?.files.single.bytes;
  if (bytes == null || !context.mounted) return;

  final csvContent = utf8.decode(bytes);
  final importResult = await context.read<BillsBloc>().importCsv(csvContent);
  if (!context.mounted) return;

  Failure? failure;
  BillImportResult? success;
  importResult.fold<void>(
    (f) => failure = f,
    (value) => success = value,
  );

  if (failure != null) {
    await _showImportErrorDialog(context, failure!.message);
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        t.bills.importCsvSuccess(
          imported: success!.importedCount,
          skipped: success!.skippedCount,
        ),
      ),
    ),
  );
}

Future<void> _showImportErrorDialog(
  BuildContext context,
  String message,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.bills.importCsvErrorTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t.general.ok),
        ),
      ],
    ),
  );
}
