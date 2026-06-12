import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/csv_import_flow.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Entry point for the transactions CSV import: runs the shared flow and
/// pushes the import-preview page on a successful parse.
Future<void> showTransactionsCsvImportDialog(BuildContext context) {
  return runCsvImportFlow<TransactionImportPreview>(
    context,
    CsvImportFlowConfig(
      introTitle: t.transactions.importCsvIntroTitle,
      introBody: t.transactions.importCsvIntroBody,
      downloadLabel: t.transactions.importCsvDownloadExample,
      selectLabel: t.transactions.importCsvSelectFile,
      errorTitle: t.transactions.importCsvErrorTitle,
      exampleAssetPath: 'lib/app/assets/samples/transactions_example.csv',
      exampleFileName: 'transactions_example.csv',
      exampleDownloadedMessage: t.transactions.importCsvExampleDownloaded,
      exampleFailedMessage: t.transactions.importCsvExampleFailed,
      parseCsv: (context, csv) =>
          context.read<TransactionsBloc>().previewCsv(csv),
      onParsed: (context, preview) =>
          context.push(AppRoutes.importTransactions, extra: preview),
    ),
  );
}
