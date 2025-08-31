import 'package:app_widgets/app_widgets.dart';
import 'package:financo/gen/assets.gen.dart';

ImportTransactionsModel get importTransactionsModel =>
    Modular.get<ImportTransactionsModel>();

class ImportTransactionsModel {
  Future<void> onTapDownloadDefaultExcelTransactions(
    BuildContext context,
  ) async {
    await AppSystemFiles.onTapDownloadDefaultExcel(
      context: context,
      filePath: Assets.lib.app.assets.excels.defaultTransactionsImportModel,
    );
  }
}
