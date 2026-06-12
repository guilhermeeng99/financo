import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/csv_import_flow.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Entry point for the accounts CSV import: runs the shared flow and
/// pushes the import-preview page on a successful parse.
Future<void> showAccountsCsvImportDialog(BuildContext context) {
  return runCsvImportFlow<AccountImportPreview>(
    context,
    CsvImportFlowConfig(
      introTitle: t.accounts.importCsvIntroTitle,
      introBody: t.accounts.importCsvIntroBody,
      downloadLabel: t.accounts.importCsvDownloadExample,
      selectLabel: t.accounts.importCsvSelectFile,
      errorTitle: t.accounts.importCsvErrorTitle,
      exampleAssetPath: 'lib/app/assets/samples/accounts_example.csv',
      exampleFileName: 'accounts_example.csv',
      exampleDownloadedMessage: t.accounts.importCsvExampleDownloaded,
      exampleFailedMessage: t.accounts.importCsvExampleFailed,
      parseCsv: (context, csv) => context.read<AccountsCubit>().previewCsv(csv),
      onParsed: (context, preview) =>
          context.push(AppRoutes.importAccounts, extra: preview),
    ),
  );
}
