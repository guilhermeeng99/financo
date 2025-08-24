import 'package:app_widgets/app_widgets.dart';
import 'package:financo/gen/assets.gen.dart';
import 'package:flutter/services.dart';

ImportCategoriesModel get importCategoriesModel =>
    Modular.get<ImportCategoriesModel>();

class ImportCategoriesModel {
  Future<void> onTapDownloadDefaultExcelCategories(BuildContext context) async {
    try {
      final filePath =
          Assets.lib.app.assets.excels.defaultCategoriesImportModel;

      final byteData = await rootBundle.load(filePath);
      final excelBytes = byteData.buffer.asUint8List();

      const fileName = 'default_categories_import_model.xlsx';

      await AppUtils.fileSaver(fileName: fileName, excelBytes: excelBytes);
      logger.i('Category default excel downloaded successfully!');

      if (context.mounted) {
        AppWidgetsUtils.snackBar(context: context, type: SnackBarType.success);
      }
    } catch (e) {
      logger.e('Error exporting default categories: $e');

      if (context.mounted) {
        AppWidgetsUtils.snackBar(context: context, type: SnackBarType.error);
      }
    }
  }
  Future<void> onTapUploadExcelCategories(BuildContext context) async {
    try {
     
    } catch (e) {
    
    }
  }
}
