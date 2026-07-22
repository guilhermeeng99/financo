import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/csv_import_flow.dart';
import 'package:financo/features/investing/domain/usecases/import_assets_csv_usecase.dart';
import 'package:financo/features/investing/presentation/cubit/assets_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Entry point for the investing-assets CSV import: runs the shared flow and
/// pushes the read-only preview page on a successful parse.
Future<void> showInvestingAssetsCsvImportDialog(BuildContext context) {
  return runCsvImportFlow<AssetImportPreview>(
    context,
    CsvImportFlowConfig(
      introTitle: t.investing.assets.import.introTitle,
      introBody: t.investing.assets.import.introBody,
      downloadLabel: t.investing.assets.import.download,
      selectLabel: t.investing.assets.import.select,
      errorTitle: t.investing.assets.import.errorTitle,
      exampleAssetPath: 'lib/app/assets/samples/investing_assets_example.csv',
      exampleFileName: 'investing_assets_example.csv',
      exampleDownloadedMessage: t.investing.assets.import.exampleDownloaded,
      exampleFailedMessage: t.investing.assets.import.exampleFailed,
      parseCsv: (context, csv) => context.read<AssetsCubit>().previewCsv(csv),
      onParsed: (context, preview) =>
          context.push(AppRoutes.importInvestingAssets, extra: preview),
    ),
  );
}
