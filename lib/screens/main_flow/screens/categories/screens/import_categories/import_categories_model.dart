// ignore_for_file: use_build_context_synchronously

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/gen/assets.gen.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';
import 'package:flutter/services.dart';

ImportCategoriesModel get importCategoriesModel =>
    Modular.get<ImportCategoriesModel>();

class ImportCategoriesModel {
  CategoryUsecase get _categoryUsecase => Modular.get<CategoryUsecase>();

  Future<void> onTapDownloadDefaultExcelCategories(BuildContext context) async {
    try {
      final filePath =
          Assets.lib.app.assets.excels.defaultCategoriesImportModel;

      final byteData = await rootBundle.load(filePath);
      final excelBytes = byteData.buffer.asUint8List();

      const fileName = 'default_categories_import_model.xlsx';

      await AppUtilsSystemFiles.fileSaver(
        fileName: fileName,
        excelBytes: excelBytes,
      );
      logger.i('Category default excel downloaded successfully!');

      if (context.mounted) {
        AppWidgetsUtils.snackBar(
          title: context.t.export_successfully,
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      logger.e('Error exporting default categories: $e');

      if (context.mounted) {
        AppWidgetsUtils.snackBar(
          title: context.t.export_error,
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> onTapUploadExcelCategories(BuildContext context) async {
    try {
      final fileBytes = await AppUtilsSystemFiles.filePicker();
      if (fileBytes == null) {
        logger.i('No file selected by user');
        return;
      }

      final sheet = await AppUtilsSystemFiles.processExcelFile(
        fileBytes,
        context,
      );
      if (sheet == null) return;

      final categoriesToCreate = _parseExcelData(sheet);
      if (categoriesToCreate.isEmpty) {
        await _showError(context, context.t.excel_not_valid);
        return;
      }

      final importResult = await _importCategories(categoriesToCreate);
      await categoriesBloc.loadCategories();

      await _showImportResult(context, importResult);
    } catch (e, stackTrace) {
      logger
        ..e('Error importing categories from Excel: $e')
        ..e('Stack trace: $stackTrace');

      if (context.mounted) {
        AppWidgetsUtils.snackBar(
          title: context.t.excel_not_valid,
          type: SnackBarType.error,
        );
      }
    }
  }

  List<Map<String, dynamic>> _parseExcelData(Sheet sheet) {
    final categoriesToCreate = <Map<String, dynamic>>[];
    final parentCategoryIds = <String, int>{};

    for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.rows[rowIndex];
      if (row.length < 2) continue;

      final categoryData = _parseExcelRow(row);
      if (categoryData == null) continue;

      _addCategoryToList(categoryData, categoriesToCreate, parentCategoryIds);
    }

    logger.i('Found ${categoriesToCreate.length} categories to create');
    return categoriesToCreate;
  }

  Map<String, dynamic>? _parseExcelRow(List<Data?> row) {
    final typeCell = row[0];
    final categoryCell = row[1];
    final subcategoryCell = row.length > 2 ? row[2] : null;

    if (typeCell?.value == null || categoryCell?.value == null) return null;

    final typeStr = typeCell!.value.toString().toLowerCase();
    final categoryName = categoryCell!.value.toString().trim();
    final subcategoryName = subcategoryCell?.value?.toString().trim();

    if (categoryName.isEmpty) return null;

    final categoryType = _parseCategoryType(typeStr);
    if (categoryType == null) {
      logger.w('Invalid category type: $typeStr');
      return null;
    }

    return {
      'categoryName': categoryName,
      'subcategoryName': subcategoryName,
      'categoryType': categoryType,
    };
  }

  FinancialType? _parseCategoryType(String typeStr) {
    if (typeStr.contains('expense') || typeStr.contains('despesa')) {
      return FinancialType.expense;
    } else if (typeStr.contains('income') || typeStr.contains('receita')) {
      return FinancialType.income;
    }
    return null;
  }

  void _addCategoryToList(
    Map<String, dynamic> categoryData,
    List<Map<String, dynamic>> categoriesToCreate,
    Map<String, int> parentCategoryIds,
  ) {
    final categoryName = categoryData['categoryName'] as String;
    final subcategoryName = categoryData['subcategoryName'] as String?;
    final categoryType = categoryData['categoryType'] as FinancialType;

    if (subcategoryName == null || subcategoryName.isEmpty) {
     
      categoriesToCreate.add({
        'name': categoryName,
        'type': categoryType,
        'parentId': null,
        'isParent': true,
      });
    } else {
      final parentKey = '${categoryType.name}_$categoryName';

      if (!parentCategoryIds.containsKey(parentKey)) {
        categoriesToCreate.add({
          'name': categoryName,
          'type': categoryType,
          'parentId': null,
          'isParent': true,
          'parentKey': parentKey,
        });
      }

      categoriesToCreate.add({
        'name': subcategoryName,
        'type': categoryType,
        'parentKey': parentKey,
        'isParent': false,
      });
    }
  }

  Future<ImportResult> _importCategories(
    List<Map<String, dynamic>> categoriesToCreate,
  ) async {
    var successCount = 0;
    var errorCount = 0;
    final parentCategoryIds = <String, int>{};

    final parentCategories = categoriesToCreate
        .where((cat) => cat['isParent'] == true)
        .toList();

    logger.i('Creating ${parentCategories.length} parent categories...');

    for (final categoryData in parentCategories) {
      final result = await _createParentCategory(categoryData);
      result.fold((failure) => errorCount++, (createdCategory) {
        successCount++;
        final parentKey = categoryData['parentKey'] as String?;
        if (parentKey != null) {
          parentCategoryIds[parentKey] = createdCategory.id;
        }
      });
    }

    final subcategories = categoriesToCreate
        .where((cat) => cat['isParent'] == false)
        .toList();

    logger.i('Creating ${subcategories.length} subcategories...');

    for (final subcategoryData in subcategories) {
      final result = await _createSubcategory(
        subcategoryData,
        parentCategoryIds,
      );
      result.fold((failure) => errorCount++, (success) => successCount++);
    }

    logger.i('Import completed: $successCount success, $errorCount errors');
    return ImportResult(successCount, errorCount);
  }

  Future<Either<Failure, CategoryData>> _createParentCategory(
    Map<String, dynamic> categoryData,
  ) async {
    final result = await _categoryUsecase.createCategory(
      name: categoryData['name'] as String,
      categoryType: categoryData['type'] as FinancialType,
    );

    result.fold(
      (failure) => logger.e(
        'Error creating parent category ${categoryData['name']}: ${failure.message}',
      ),
      (createdCategory) =>
          logger.i('Parent category created: ${createdCategory.name}'),
    );

    return result;
  }

  Future<Either<Failure, CategoryData>> _createSubcategory(
    Map<String, dynamic> subcategoryData,
    Map<String, int> parentCategoryIds,
  ) async {
    final parentKey = subcategoryData['parentKey'] as String;
    final parentId = parentCategoryIds[parentKey];

    if (parentId == null) {
      logger.e(
        'Parent category not found for subcategory: ${subcategoryData['name']}',
      );
      return Either.left(const DatabaseFailure('Parent category not found'));
    }

    final result = await _categoryUsecase.createCategory(
      name: subcategoryData['name'] as String,
      categoryType: subcategoryData['type'] as FinancialType,
      parentCategoryId: parentId,
    );

    result.fold(
      (failure) => logger.e(
        'Error creating subcategory ${subcategoryData['name']}: ${failure.message}',
      ),
      (createdCategory) =>
          logger.i('Subcategory created: ${createdCategory.name}'),
    );

    return result;
  }

  Future<void> _showImportResult(
    BuildContext context,
    ImportResult result,
  ) async {
    if (!context.mounted) return;

    if (result.errorCount == 0) {
      AppWidgetsUtils.snackBar(
        title: context.t.excel_import_successfully,
        type: SnackBarType.success,
      );
    } else {
      AppWidgetsUtils.snackBar(
        title: context.t.excel_not_valid,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _showError(BuildContext context, String message) async {
    logger.w('No valid categories found in Excel file');
    if (context.mounted) {
      AppWidgetsUtils.snackBar(title: message, type: SnackBarType.error);
    }
  }
}

class ImportResult {
  const ImportResult(this.successCount, this.errorCount);

  final int successCount;
  final int errorCount;
}
