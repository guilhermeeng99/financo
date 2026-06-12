import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:financo/app/widgets/csv_import_dialog.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/csv_example_downloader.dart';
import 'package:flutter/material.dart';

/// Parses the picked CSV content — typically by delegating to the feature
/// cubit/bloc (e.g. `context.read<AccountsCubit>().previewCsv(csv)`).
/// A `Left` aborts the flow with the shared error dialog.
typedef CsvParseStep<T> =
    Future<Either<Failure, T>> Function(BuildContext context, String csv);

/// Follow-up after a successful parse — usually pushing the import-preview
/// route or showing a success snackbar.
typedef CsvParsedStep<T> = Future<void> Function(BuildContext context, T value);

/// Per-feature configuration for [runCsvImportFlow]: the slang strings
/// shown along the flow, the bundled example CSV, and the feature-specific
/// [parseCsv] / [onParsed] steps.
class CsvImportFlowConfig<T> {
  const CsvImportFlowConfig({
    required this.introTitle,
    required this.introBody,
    required this.downloadLabel,
    required this.selectLabel,
    required this.errorTitle,
    required this.exampleAssetPath,
    required this.exampleFileName,
    required this.exampleDownloadedMessage,
    required this.exampleFailedMessage,
    required this.parseCsv,
    required this.onParsed,
  });

  final String introTitle;
  final String introBody;
  final String downloadLabel;
  final String selectLabel;

  /// Title of the error dialog shown when [parseCsv] returns a `Left`.
  final String errorTitle;

  final String exampleAssetPath;
  final String exampleFileName;
  final String exampleDownloadedMessage;
  final String exampleFailedMessage;

  final CsvParseStep<T> parseCsv;
  final CsvParsedStep<T> onParsed;
}

/// Runs the CSV import flow shared by every feature (accounts, categories,
/// transactions, budgets): intro dialog (select file / download example /
/// cancel) → file pick → [CsvImportFlowConfig.parseCsv] → error dialog on
/// failure, or [CsvImportFlowConfig.onParsed] on success.
///
/// ```dart
/// await runCsvImportFlow(
///   context,
///   CsvImportFlowConfig(
///     introTitle: t.accounts.importCsvIntroTitle,
///     // ... remaining strings and example-CSV config ...
///     parseCsv: (context, csv) =>
///         context.read<AccountsCubit>().previewCsv(csv),
///     onParsed: (context, preview) =>
///         context.push(AppRoutes.importAccounts, extra: preview),
///   ),
/// );
/// ```
Future<void> runCsvImportFlow<T>(
  BuildContext context,
  CsvImportFlowConfig<T> config,
) async {
  final choice = await showCsvImportIntroDialog(
    context,
    title: config.introTitle,
    body: config.introBody,
    downloadLabel: config.downloadLabel,
    selectLabel: config.selectLabel,
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case CsvImportIntroChoice.downloadExample:
      await _downloadExample(context, config);
    case CsvImportIntroChoice.selectFile:
      await _pickAndParse(context, config);
  }
}

Future<void> _downloadExample(
  BuildContext context,
  CsvImportFlowConfig<dynamic> config,
) async {
  bool didSave;
  try {
    didSave = await downloadCsvExample(
      assetPath: config.exampleAssetPath,
      fileName: config.exampleFileName,
      dialogTitle: config.downloadLabel,
    );
  } on Exception {
    if (!context.mounted) return;
    _showSnackBar(context, config.exampleFailedMessage);
    return;
  }

  if (!context.mounted || !didSave) return;
  _showSnackBar(context, config.exampleDownloadedMessage);
}

Future<void> _pickAndParse<T>(
  BuildContext context,
  CsvImportFlowConfig<T> config,
) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
    withData: true,
  );
  final bytes = result?.files.single.bytes;
  if (bytes == null || !context.mounted) return;

  final parsed = await config.parseCsv(context, utf8.decode(bytes));
  if (!context.mounted) return;

  await parsed.fold(
    (failure) => showCsvImportErrorDialog(
      context,
      title: config.errorTitle,
      message: failure.message,
    ),
    (value) => config.onParsed(context, value),
  );
}

void _showSnackBar(BuildContext context, String message) {
  context.showSnack(message);
}
