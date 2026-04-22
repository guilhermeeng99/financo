import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/csv_example_downloader.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(previewFailure!.message)),
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.transactions.importCsv),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.transactions.importReview(count: preview!.rows.length),
              ),
              const SizedBox(height: 8),
              _ImportRowSummary(preview: preview!),
              if (preview!.skippedRows > 0) ...[
                const SizedBox(height: 8),
                Text(
                  t.transactions.importSkippedRows(
                    count: preview!.skippedRows,
                  ),
                  style: TextStyle(
                    color: dialogContext.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (preview!.missingCategories.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  t.transactions.importMissingCategories,
                  style: TextStyle(color: dialogContext.colorScheme.error),
                ),
                const SizedBox(height: 4),
                ...preview!.missingCategories.map(
                  (name) => Text(
                    '• $name',
                    style: TextStyle(color: dialogContext.colorScheme.error),
                  ),
                ),
              ],
              if (preview!.missingAccounts.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  t.transactions.importMissingAccounts,
                  style: TextStyle(color: dialogContext.colorScheme.error),
                ),
                const SizedBox(height: 4),
                ...preview!.missingAccounts.map(
                  (name) => Text(
                    '• $name',
                    style: TextStyle(color: dialogContext.colorScheme.error),
                  ),
                ),
              ],
              if (!preview!.canImport) ...[
                const SizedBox(height: 16),
                Text(
                  t.transactions.importBlocked,
                  style: TextStyle(
                    color: dialogContext.colorScheme.error,
                    fontWeight: FontWeight.bold,
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
          onPressed: preview!.canImport
              ? () => Navigator.of(dialogContext).pop(true)
              : null,
          child: Text(t.general.confirm),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  context.read<TransactionsBloc>().add(
    TransactionsImportCsvRequested(csvContent),
  );
}

class _ImportRowSummary extends StatelessWidget {
  const _ImportRowSummary({required this.preview});

  final TransactionImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final expenses = preview.rows.where(
      (row) => row.csvType == CsvTransactionType.despesa,
    );
    final incomes = preview.rows.where(
      (row) => row.csvType == CsvTransactionType.receita,
    );
    final transfers = preview.rows.where((row) => row.isTransfer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expenses.isNotEmpty)
          Text(t.transactions.importExpenses(count: expenses.length)),
        if (incomes.isNotEmpty)
          Text(t.transactions.importIncomes(count: incomes.length)),
        if (transfers.isNotEmpty)
          Text(t.transactions.importTransfers(count: transfers.length)),
      ],
    );
  }
}
