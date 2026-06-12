import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/csv_import_flow.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Entry point for the categories CSV import: runs the shared flow and
/// pushes the import-preview page on a successful parse.
Future<void> showCategoriesCsvImportDialog(BuildContext context) {
  return runCsvImportFlow<CategoryImportPreview>(
    context,
    CsvImportFlowConfig(
      introTitle: t.categories.importCsvIntroTitle,
      introBody: t.categories.importCsvIntroBody,
      downloadLabel: t.categories.importCsvDownloadExample,
      selectLabel: t.categories.importCsvSelectFile,
      errorTitle: t.categories.importCsvErrorTitle,
      exampleAssetPath: 'lib/app/assets/samples/categories_example.csv',
      exampleFileName: 'categories_example.csv',
      exampleDownloadedMessage: t.categories.importCsvExampleDownloaded,
      exampleFailedMessage: t.categories.importCsvExampleFailed,
      parseCsv: (context, csv) =>
          context.read<CategoriesCubit>().previewCsv(csv),
      onParsed: (context, preview) =>
          context.push(AppRoutes.importCategories, extra: preview),
    ),
  );
}
