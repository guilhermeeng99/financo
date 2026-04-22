import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/csv_example_downloader.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _exampleAssetPath = 'lib/app/assets/samples/categories_example.csv';

enum _CsvImportAction { downloadExample, selectFile }

Future<void> showCategoriesCsvImportDialog(BuildContext context) async {
  final action = await showDialog<_CsvImportAction>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.categories.importCsvIntroTitle),
      content: Text(t.categories.importCsvIntroBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t.general.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext)
              .pop(_CsvImportAction.downloadExample),
          child: Text(t.categories.importCsvDownloadExample),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_CsvImportAction.selectFile),
          child: Text(t.categories.importCsvSelectFile),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(previewFailure!.message)),
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.categories.importCsv),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.categories.importReview(arg: preview!.toCreate.length),
              ),
              const SizedBox(height: 12),
              ...preview!.toCreate.map(
                (item) => Text(
                  item.parentName == null
                      ? '• ${item.name}'
                      : '• ${item.parentName} → ${item.name}',
                ),
              ),
              if (preview!.duplicates.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  t.categories.importDuplicates(
                    arg: preview!.duplicates.length,
                  ),
                  style: TextStyle(
                    color: dialogContext.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ...preview!.duplicates.map(
                  (item) => Text(
                    item.parentName == null
                        ? '• ${item.name}'
                        : '• ${item.parentName} → ${item.name}',
                    style: TextStyle(
                      color: dialogContext.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(t.general.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(t.general.confirm),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  await context.read<CategoriesCubit>().importCsv(csvContent);
  if (!context.mounted) return;

  final newState = context.read<CategoriesCubit>().state;
  if (newState is CategoriesImported) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t.categories.importSuccessDetailed(
            imported: newState.importedCount,
            duplicates: newState.duplicateCount,
          ),
        ),
      ),
    );
  } else if (newState is CategoriesError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(newState.failure.message)),
    );
  }
}
