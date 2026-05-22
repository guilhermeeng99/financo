import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:financo/app/widgets/csv_import_dialog.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/csv_example_downloader.dart';
import 'package:financo/features/budgets/domain/usecases/import_budgets_csv_usecase.dart';
import 'package:financo/features/budgets/presentation/cubit/budgets_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _exampleAssetPath = 'lib/app/assets/samples/budgets_example.csv';

/// Three-button entry dialog (Select file / Download example / Cancel)
/// for the budgets CSV import. Skips the multi-step preview page used by
/// categories/accounts/transactions — budgets only have two columns
/// (Category, Amount) so a parse → import → toast flow is enough.
Future<void> showBudgetsCsvImportDialog(BuildContext context) async {
  final choice = await showCsvImportIntroDialog(
    context,
    title: t.budgets.importCsvIntroTitle,
    body: t.budgets.importCsvIntroBody,
    downloadLabel: t.budgets.importCsvDownloadExample,
    selectLabel: t.budgets.importCsvSelectFile,
  );

  if (choice == null || !context.mounted) return;

  switch (choice) {
    case CsvImportIntroChoice.downloadExample:
      await _downloadExample(context);
    case CsvImportIntroChoice.selectFile:
      await _pickAndImport(context);
  }
}

Future<void> _downloadExample(BuildContext context) async {
  bool didSave;
  try {
    didSave = await downloadCsvExample(
      assetPath: _exampleAssetPath,
      fileName: 'budgets_example.csv',
      dialogTitle: t.budgets.importCsvDownloadExample,
    );
  } on Exception {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.budgets.importCsvExampleFailed)),
    );
    return;
  }

  if (!context.mounted || !didSave) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.budgets.importCsvExampleDownloaded)),
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
  final importResult =
      await context.read<BudgetsCubit>().importCsv(csvContent);
  if (!context.mounted) return;

  Failure? failure;
  BudgetImportResult? success;
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
        t.budgets.importCsvSuccess(
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
) {
  return showCsvImportErrorDialog(
    context,
    title: t.budgets.importCsvErrorTitle,
    message: message,
  );
}
