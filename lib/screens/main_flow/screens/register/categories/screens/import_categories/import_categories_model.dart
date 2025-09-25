// ignore_for_file: use_build_context_synchronously

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/register/categories/categories_bloc.dart';

ImportCategoriesModel get importCategoriesModel =>
    Modular.get<ImportCategoriesModel>();

class ImportCategoriesModel {
  ICategoryUsecase get _categoryUsecase => Modular.get<ICategoryUsecase>();

  Future<void> onTapDownloadDefaultExcelCategories(BuildContext context) async {
    try {
      final sheetName = context.t.common.labels.category(n: 2);
      final excel = Excel.createExcel()..rename('Sheet1', sheetName);

      final sheet = excel[sheetName];

      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
        context.t.common.labels.type,
      );
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
        context.t.common.labels.category(n: 1),
      );
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
        context.t.common.labels.subcategory,
      );

      final sampleData = _sampleDataForDownload(context);

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

      final excelBytes = excel.encode();
      if (excelBytes != null) {
        final sheetName = context.t.common.labels.category(n: 2).toLowerCase();
        await AppSystemFiles.fileSaver(
          fileName: '${sheetName}_import_template.xlsx',
          excelBytes: excelBytes,
        );

        if (context.mounted) {
          CWSnackBar.snackBar(
            title: context.t.messages.success.export_successfully,
            type: SnackBarType.success,
          );
        }
      }
    } on Exception catch (e, stackTrace) {
      logger
        ..e('Error generating Excel template: $e')
        ..e('Stack trace: $stackTrace');

      if (context.mounted) {
        CWSnackBar.snackBar(
          title: context.t.messages.errors.excel_not_valid,
          type: SnackBarType.error,
        );
      }
    }
  }

  List<List<String>> _sampleDataForDownload(BuildContext context) {
    return [
      [
        context.t.transactions.types.expense,
        '${context.t.common.labels.category(n: 1)} 1',
        '',
      ],
      [
        context.t.transactions.types.income,
        '${context.t.common.labels.category(n: 1)} 2',
        '',
      ],
      [
        context.t.transactions.types.expense,
        '${context.t.common.labels.category(n: 1)} 3',
        '',
      ],
      [
        context.t.transactions.types.expense,
        '${context.t.common.labels.category(n: 1)} 3',
        '${context.t.common.labels.subcategory} 1',
      ],
      [
        context.t.transactions.types.income,
        '${context.t.common.labels.category(n: 1)} 4',
        '',
      ],
      [
        context.t.transactions.types.income,
        '${context.t.common.labels.category(n: 1)} 4',
        '${context.t.common.labels.subcategory} 2',
      ],
      [
        context.t.transactions.types.expense,
        '${context.t.common.labels.category(n: 1)} 5',
        '',
      ],
      [
        context.t.transactions.types.expense,
        '${context.t.common.labels.category(n: 1)} 5',
        '${context.t.common.labels.subcategory} 3',
      ],
      [
        context.t.transactions.types.income,
        '${context.t.common.labels.category(n: 1)} 6',
        '',
      ],
    ];
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

      final parseResult = _parseExcelData(sheet, context);
      final categories =
          parseResult['categories'] as List<Map<String, dynamic>>;
      final validRows = parseResult['validRows'] as int;

      if (categories.isEmpty) {
        await _showError(context, context.t.messages.errors.excel_not_valid);
        return;
      }

      final importResult = await _importCategories(
        categories,
        validRows,
        context,
      );
      await categoriesBloc.loadCategories();

      await AppSystemFiles.showImportResult(context, importResult);
    } on Exception catch (e, stackTrace) {
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

  Map<String, dynamic> _parseExcelData(Sheet sheet, BuildContext context) {
    final categoriesToCreate = <Map<String, dynamic>>[];
    var processedRows = 0;

    // Use fixed column order: 0=Type, 1=Category, 2=Subcategory
    final columnIndexes = {'type': 0, 'category': 1, 'subcategory': 2};

    logger.i(
      'Using fixed column order: Column 0=Type, Column 1=Category, Column 2=Subcategory (optional)',
    );

    for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.rows[rowIndex];
      if (row.isEmpty) continue;

      // Check if the row is empty
      final rowData = <String>[];
      for (var colIndex = 0; colIndex < row.length; colIndex++) {
        final cellValue = row[colIndex]?.value?.toString() ?? 'NULL';
        rowData.add(cellValue);
      }

      final isEmpty = rowData.every(
        (cell) => cell == 'NULL' || cell.trim().isEmpty,
      );
      if (isEmpty) continue;

      processedRows++;

      final categoryData = _parseExcelRow(row, columnIndexes, context);
      if (categoryData == null) continue;

      _addCategoryToList(categoryData, categoriesToCreate);
    }

    logger.i(
      'Found ${categoriesToCreate.length} categories to create from $processedRows valid data rows',
    );

    return {'categories': categoriesToCreate, 'validRows': processedRows};
  }

  Map<String, dynamic>? _parseExcelRow(
    List<Data?> row,
    Map<String, dynamic> columnIndexes,
    BuildContext context,
  ) {
    const typeIndex = 0;
    const categoryIndex = 1;
    const subcategoryIndex = 2;

    final typeCell = typeIndex < row.length ? row[typeIndex] : null;
    final categoryCell = categoryIndex < row.length ? row[categoryIndex] : null;
    final subcategoryCell = subcategoryIndex < row.length
        ? row[subcategoryIndex]
        : null;

    if (typeCell?.value == null || categoryCell?.value == null) return null;

    final typeStr = typeCell!.value.toString().toLowerCase();
    final categoryName = categoryCell!.value.toString().trim();
    final subcategoryName = subcategoryCell?.value?.toString().trim();

    if (categoryName.isEmpty) return null;

    final categoryType = _parseCategoryType(typeStr, context);
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

  FinancialType? _parseCategoryType(String typeStr, BuildContext context) {
    final normalizedType = typeStr.toLowerCase().trim();

    final expenseText = context.t.transactions.types.expense.toLowerCase();
    final incomeText = context.t.transactions.types.income.toLowerCase();

    if (normalizedType.contains(expenseText)) {
      return FinancialType.expense;
    } else if (normalizedType.contains(incomeText)) {
      return FinancialType.income;
    }

    return null;
  }

  void _addCategoryToList(
    Map<String, dynamic> categoryData,
    List<Map<String, dynamic>> categoriesToCreate,
  ) {
    final categoryName = categoryData['categoryName'] as String;
    final subcategoryName = categoryData['subcategoryName'] as String?;
    final categoryType = categoryData['categoryType'] as FinancialType;

    if (subcategoryName == null || subcategoryName.isEmpty) {
      // This is a parent category
      categoriesToCreate.add({
        'name': categoryName,
        'type': categoryType,
        'parentId': null,
        'isParent': true,
        'parentName': categoryName,
      });
    } else {
      // This is a subcategory
      categoriesToCreate.add({
        'name': subcategoryName,
        'type': categoryType,
        'parentName': categoryName,
        'isParent': false,
      });
    }
  }

  Future<ImportResult> _importCategories(
    List<Map<String, dynamic>> categoriesToCreate,
    int validRowsCount,
    BuildContext context,
  ) async {
    var successCount = 0;
    var errorCount = 0;
    final createdParentCategories = <String, Map<String, dynamic>>{};

    // First pass: collect unique parent categories and check if they already exist
    final uniqueParentCategories = <String, Map<String, dynamic>>{};

    for (final categoryData in categoriesToCreate) {
      if (categoryData['isParent'] == true) {
        final key = '${categoryData['type']}_${categoryData['name']}';
        uniqueParentCategories[key] = categoryData;
      } else {
        // For subcategories, ensure parent category exists
        final parentName = categoryData['parentName'] as String;
        final categoryType = categoryData['type'] as FinancialType;
        final parentKey = '${categoryType}_$parentName';

        if (!uniqueParentCategories.containsKey(parentKey)) {
          uniqueParentCategories[parentKey] = {
            'name': parentName,
            'type': categoryType,
            'parentId': null,
            'isParent': true,
            'parentName': parentName,
          };
        }
      }
    }

    logger.i(
      'Creating ${uniqueParentCategories.length} unique parent categories...',
    );

    // Create parent categories or find existing ones
    for (final entry in uniqueParentCategories.entries) {
      final parentKey = entry.key;
      final categoryData = entry.value;

      // First check if parent category already exists
      final existingCategory = await _findExistingParentCategory(
        categoryData['name'] as String,
        categoryData['type'] as FinancialType,
      );

      if (existingCategory != null) {
        // Parent category already exists, use it
        createdParentCategories[parentKey] = {
          'id': existingCategory.id,
          'name': existingCategory.name,
          'categoryType': existingCategory.categoryType,
        };
        logger.i('Using existing parent category: ${existingCategory.name}');
      } else {
        // Create new parent category
        final result = await _createParentCategory(categoryData, context);
        result.fold((failure) => errorCount++, (createdCategory) {
          successCount++;
          createdParentCategories[parentKey] = {
            'id': createdCategory.id,
            'name': createdCategory.name,
            'categoryType': createdCategory.categoryType,
          };
        });
      }
    }

    // Second pass: create subcategories
    final subcategories = categoriesToCreate
        .where((cat) => cat['isParent'] == false)
        .toList();

    logger.i('Creating ${subcategories.length} subcategories...');

    for (final subcategoryData in subcategories) {
      final parentName = subcategoryData['parentName'] as String;
      final categoryType = subcategoryData['type'] as FinancialType;
      final parentKey = '${categoryType}_$parentName';

      final parentCategory = createdParentCategories[parentKey];

      if (parentCategory == null) {
        logger.e(
          'Parent category not found for subcategory: ${subcategoryData['name']}',
        );
        errorCount++;
        continue;
      }

      final result = await _createSubcategory(
        subcategoryData,
        parentCategory['id'] as int,
        context,
      );
      result.fold((failure) => errorCount++, (success) => successCount++);
    }

    logger.i('Import completed: $successCount success, $errorCount errors');
    return ImportResult(successCount, errorCount, validRowsCount);
  }

  Future<CategoryData?> _findExistingParentCategory(
    String categoryName,
    FinancialType categoryType,
  ) async {
    try {
      final result = await _categoryUsecase.getCategoriesByType(categoryType);
      return result.fold((failure) => null, (categories) {
        // Find parent category (one without parentCategoryId)
        return categories
            .where(
              (cat) =>
                  cat.parentCategoryId == null &&
                  cat.name.toLowerCase() == categoryName.toLowerCase(),
            )
            .firstOrNull;
      });
    } on Exception catch (e) {
      logger.e('Error finding existing parent category: $e');
      return null;
    }
  }

  Future<Either<Failure, CategoryData>> _createParentCategory(
    Map<String, dynamic> categoryData,
    BuildContext context,
  ) async {
    try {
      final categoryName = CategoryName.create(categoryData['name'] as String);

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
    } on Exception catch (e) {
      logger.e('Unexpected error creating parent category: $e');
      return Either.left(DatabaseFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, CategoryData>> _createSubcategory(
    Map<String, dynamic> subcategoryData,
    int parentId,
    BuildContext context,
  ) async {
    try {
      final categoryName = CategoryName.create(
        subcategoryData['name'] as String,
      );

      final parentCategoryId = ParentCategoryId.create(parentId);

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
    } on Exception catch (e) {
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
