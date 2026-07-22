import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/csv_import_flow.dart';
import 'package:financo/features/investing/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/investing/presentation/cubit/investing_transactions_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Entry point for the investing-transactions CSV import: runs the shared flow
/// and pushes the read-only preview page on a successful parse.
Future<void> showInvestingTransactionsCsvImportDialog(BuildContext context) {
  return runCsvImportFlow<InvestingTransactionImportPreview>(
    context,
    CsvImportFlowConfig(
      introTitle: t.investing.transactions.import.introTitle,
      introBody: t.investing.transactions.import.introBody,
      downloadLabel: t.investing.transactions.import.download,
      selectLabel: t.investing.transactions.import.select,
      errorTitle: t.investing.transactions.import.errorTitle,
      exampleAssetPath:
          'lib/app/assets/samples/investing_transactions_example.csv',
      exampleFileName: 'investing_transactions_example.csv',
      exampleDownloadedMessage:
          t.investing.transactions.import.exampleDownloaded,
      exampleFailedMessage: t.investing.transactions.import.exampleFailed,
      parseCsv: (context, csv) =>
          context.read<InvestingTransactionsCubit>().previewCsv(csv),
      onParsed: (context, preview) =>
          context.push(AppRoutes.importInvestingTransactions, extra: preview),
    ),
  );
}
