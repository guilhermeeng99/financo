import 'package:financo/app/widgets/csv_import_flow.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/budgets/domain/usecases/import_budgets_csv_usecase.dart';
import 'package:financo/features/budgets/presentation/cubit/budgets_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Entry point for the budgets CSV import. Skips the multi-step preview
/// page used by categories/accounts/transactions — budgets only have two
/// columns (Category, Amount) so a parse → import → toast flow is enough.
Future<void> showBudgetsCsvImportDialog(BuildContext context) {
  return runCsvImportFlow<BudgetImportResult>(
    context,
    CsvImportFlowConfig(
      introTitle: t.budgets.importCsvIntroTitle,
      introBody: t.budgets.importCsvIntroBody,
      downloadLabel: t.budgets.importCsvDownloadExample,
      selectLabel: t.budgets.importCsvSelectFile,
      errorTitle: t.budgets.importCsvErrorTitle,
      exampleAssetPath: 'lib/app/assets/samples/budgets_example.csv',
      exampleFileName: 'budgets_example.csv',
      exampleDownloadedMessage: t.budgets.importCsvExampleDownloaded,
      exampleFailedMessage: t.budgets.importCsvExampleFailed,
      parseCsv: (context, csv) => context.read<BudgetsCubit>().importCsv(csv),
      onParsed: _showImportSuccessSnackBar,
    ),
  );
}

Future<void> _showImportSuccessSnackBar(
  BuildContext context,
  BudgetImportResult result,
) async {
  context.showSnack(
    t.budgets.importCsvSuccess(
      imported: result.importedCount,
      skipped: result.skippedCount,
    ),
  );
}
