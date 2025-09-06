// ignore_for_file: use_build_context_synchronously

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/gen/assets.gen.dart';
import 'package:financo/screens/main_flow/screens/categories/categories_bloc.dart';

ImportCategoriesModel get importCategoriesModel =>
    Modular.get<ImportCategoriesModel>();

class ImportCategoriesModel {
  ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();

  Future<void> onTapDownloadDefaultExcelCategories(BuildContext context) async {
    await AppSystemFiles.onTapDownloadDefaultExcel(
      context: context,
      filePath: Assets.lib.app.assets.excels.defaultCategoriesImportModel,
    );
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

      final categoriesToCreate = _parseExcelData(sheet);
      if (categoriesToCreate.isEmpty) {
        await _showError(context, context.t.messages.errors.excel_not_valid);
        return;
      }

      final importResult = await _importCategories(categoriesToCreate, context);
      await categoriesBloc.loadCategories();

      await AppSystemFiles.showImportResult(context, importResult);
    } catch (e, stackTrace) {
      logger
        ..e('Error importing categories from Excel: $e')
        ..e('Stack trace: $stackTrace');

      if (context.mounted) {
        CWSnackBar.snackBar(
          title: context.t.messages.errors.excel_not_valid,
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
    BuildContext context,
  ) async {
    var successCount = 0;
    var errorCount = 0;
    final parentCategoryIds = <String, int>{};

    final parentCategories = categoriesToCreate
        .where((cat) => cat['isParent'] == true)
        .toList();

    logger.i('Creating ${parentCategories.length} parent categories...');

    for (final categoryData in parentCategories) {
      final result = await _createParentCategory(categoryData, context);
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
        context,
      );
      result.fold((failure) => errorCount++, (success) => successCount++);
    }

    logger.i('Import completed: $successCount success, $errorCount errors');
    return ImportResult(successCount, errorCount);
  }

  Future<Either<Failure, CategoryData>> _createParentCategory(
    Map<String, dynamic> categoryData,
    BuildContext context,
  ) async {
    try {
      final categoryName = CategoryName.create(
        categoryData['name'] as String,
        context,
      );

      final result = await _categoryUsecase.createCategory(
        name: categoryName,
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
    } on ValidationException catch (e) {
      logger.e('Validation error creating parent category: ${e.message}');
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      logger.e('Unexpected error creating parent category: $e');
      return Either.left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, CategoryData>> _createSubcategory(
    Map<String, dynamic> subcategoryData,
    Map<String, int> parentCategoryIds,
    BuildContext context,
  ) async {
    final parentKey = subcategoryData['parentKey'] as String;
    final parentId = parentCategoryIds[parentKey];

    if (parentId == null) {
      logger.e(
        'Parent category not found for subcategory: ${subcategoryData['name']}',
      );
      return Either.left(const DatabaseFailure('Parent category not found'));
    }

    try {
      final categoryName = CategoryName.create(
        subcategoryData['name'] as String,
        context,
      );

      final parentCategoryId = ParentCategoryId.create(parentId, context);

      final result = await _categoryUsecase.createCategory(
        name: categoryName,
        categoryType: subcategoryData['type'] as FinancialType,
        parentCategoryId: parentCategoryId,
      );

      result.fold(
        (failure) => logger.e(
          'Error creating subcategory ${subcategoryData['name']}: ${failure.message}',
        ),
        (createdCategory) =>
            logger.i('Subcategory created: ${createdCategory.name}'),
      );

      return result;
    } on ValidationException catch (e) {
      logger.e('Validation error creating subcategory: ${e.message}');
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      logger.e('Unexpected error creating subcategory: $e');
      return Either.left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  Future<void> _showError(BuildContext context, String message) async {
    logger.w('No valid categories found in Excel file');
    if (context.mounted) {
      CWSnackBar.snackBar(title: message, type: SnackBarType.error);
    }
  }
}
