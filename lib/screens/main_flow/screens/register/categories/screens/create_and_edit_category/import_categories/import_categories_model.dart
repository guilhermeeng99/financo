// ignore_for_file: use_build_context_synchronously

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/import_categories/services/category_import_service.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/import_categories/services/category_validator_service.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/import_categories/services/excel_parser_service.dart';

ImportCategoriesModel get importCategoriesModel =>
    Modular.get<ImportCategoriesModel>();

class ImportCategoriesModel {
  ImportCategoriesModel()
    : _excelParserService = ExcelParserService(),
      _categoryImportService = CategoryImportService(
        categoryUsecase: Modular.get<ICategoryUsecase>(),
        validatorService: CategoryValidatorService(),
      );

  final ExcelParserService _excelParserService;
  final CategoryImportService _categoryImportService;

  Future<void> onTapDownloadDefaultExcelCategories(BuildContext context) async {
    try {
      final sheetName = context.t.common.labels.category(n: 2);
      final excel = Excel.createExcel()..rename('Sheet1', sheetName);
      final sheet = excel[sheetName];

      _createExcelHeaders(sheet, context);
      _fillExcelSampleData(sheet, context);

      await _saveExcelFile(excel, sheetName, context);
    } on Exception catch (e, stackTrace) {
      logger
        ..e('Error generating Excel template: $e')
        ..e('Stack trace: $stackTrace');

      if (context.mounted) {
        _showError(context, context.t.messages.errors.excel_not_valid);
      }
    }
  }

  void _createExcelHeaders(Sheet sheet, BuildContext context) {
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      context.t.common.labels.type,
    );
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
      context.t.common.labels.category(n: 1),
    );
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
      context.t.common.labels.subcategory,
    );
  }

  void _fillExcelSampleData(Sheet sheet, BuildContext context) {
    final sampleData = _excelParserService.generateSampleData(context);

    for (var i = 0; i < sampleData.length; i++) {
      final row = sampleData[i];
      sheet.cell(CellIndex.indexByString('A${i + 2}')).value = TextCellValue(
        row[0],
      );
      sheet.cell(CellIndex.indexByString('B${i + 2}')).value = TextCellValue(
        row[1],
      );
      sheet.cell(CellIndex.indexByString('C${i + 2}')).value = TextCellValue(
        row[2],
      );
    }
  }

  Future<void> _saveExcelFile(
    Excel excel,
    String sheetName,
    BuildContext context,
  ) async {
    final excelBytes = excel.encode();
    if (excelBytes == null) return;

    final fileName = '${sheetName.toLowerCase()}_import_template.xlsx';
    await AppSystemFiles.fileSaver(
      fileName: fileName,
      excelBytes: excelBytes,
    );

    if (context.mounted) {
      CWSnackBar.snackBar(
        title: context.t.messages.success.export_successfully,
        type: SnackBarType.success,
      );
    }
  }

  Future<void> onTapUploadExcelCategories(BuildContext context) async {
    try {
      final fileBytes = await AppSystemFiles.filePicker();
      if (fileBytes == null) {
        logger.i('No file selected by user');
        return;
      }

      final sheet = await AppSystemFiles.processExcelFile(fileBytes, context);
      if (sheet == null) return;

      final parseResult = _excelParserService.parseExcelData(sheet, context);

      if (parseResult.categories.isEmpty) {
        _showError(context, context.t.messages.errors.excel_not_valid);
        return;
      }

      final importResult = await _categoryImportService.importCategories(
        parseResult.categories,
        parseResult.validRows,
        context,
      );

      await categoriesBloc.loadCategories();
      await AppSystemFiles.showImportResult(context, importResult);
    } on Exception catch (e, stackTrace) {
      logger
        ..e('Error importing categories from Excel: $e')
        ..e('Stack trace: $stackTrace');

      if (context.mounted) {
        _showError(context, context.t.messages.errors.excel_not_valid);
      }
    }
  }

  void _showError(BuildContext context, String message) {
    CWSnackBar.snackBar(title: message, type: SnackBarType.error);
  }
}
