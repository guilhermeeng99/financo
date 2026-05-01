import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/csv_example_downloader.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const _exampleAssetPath = 'lib/app/assets/samples/transactions_example.csv';

enum _CsvImportAction { downloadExample, selectFile }

Future<void> showTransactionsCsvImportDialog(BuildContext context) async {
  final action = await showDialog<_CsvImportAction>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.transactions.importCsvIntroTitle),
      content: Text(t.transactions.importCsvIntroBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t.general.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext)
              .pop(_CsvImportAction.downloadExample),
          child: Text(t.transactions.importCsvDownloadExample),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_CsvImportAction.selectFile),
          child: Text(t.transactions.importCsvSelectFile),
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
      fileName: 'transactions_example.csv',
      dialogTitle: t.transactions.importCsvDownloadExample,
    );
  } on Exception {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.transactions.importCsvExampleFailed)),
    );
    return;
  }

  if (!context.mounted || !didSave) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.transactions.importCsvExampleDownloaded)),
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
  final previewResult = await context.read<TransactionsBloc>().previewCsv(
    csvContent,
  );
  if (!context.mounted) return;

  Failure? previewFailure;
  TransactionImportPreview? preview;
  previewResult.fold<void>(
    (failure) => previewFailure = failure,
    (value) => preview = value,
  );

  if (previewFailure != null) {
    await _showImportErrorDialog(context, previewFailure!.message);
    return;
  }

  await context.push(AppRoutes.importTransactions, extra: preview);
}

Future<void> _showImportErrorDialog(
  BuildContext context,
  String message,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.transactions.importCsvErrorTitle),
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
