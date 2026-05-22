import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/csv_import_dialog.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/csv_example_downloader.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const _exampleAssetPath = 'lib/app/assets/samples/categories_example.csv';

Future<void> showCategoriesCsvImportDialog(BuildContext context) async {
  final choice = await showCsvImportIntroDialog(
    context,
    title: t.categories.importCsvIntroTitle,
    body: t.categories.importCsvIntroBody,
    downloadLabel: t.categories.importCsvDownloadExample,
    selectLabel: t.categories.importCsvSelectFile,
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
      fileName: 'categories_example.csv',
      dialogTitle: t.categories.importCsvDownloadExample,
    );
  } on Exception {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.categories.importCsvExampleFailed)),
    );
    return;
  }

  if (!context.mounted || !didSave) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(t.categories.importCsvExampleDownloaded)),
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
  final previewResult = await context.read<CategoriesCubit>().previewCsv(
    csvContent,
  );
  if (!context.mounted) return;

  Failure? previewFailure;
  CategoryImportPreview? preview;
  previewResult.fold<void>(
    (failure) => previewFailure = failure,
    (value) => preview = value,
  );

  if (previewFailure != null) {
    await _showImportErrorDialog(context, previewFailure!.message);
    return;
  }

  await context.push(AppRoutes.importCategories, extra: preview);
}

Future<void> _showImportErrorDialog(
  BuildContext context,
  String message,
) {
  return showCsvImportErrorDialog(
    context,
    title: t.categories.importCsvErrorTitle,
    message: message,
  );
}
