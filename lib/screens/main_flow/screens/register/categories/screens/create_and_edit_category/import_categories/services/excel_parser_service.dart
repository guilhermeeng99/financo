// ignore_for_file: depend_on_referenced_packages

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:excel/excel.dart';
import 'package:financo/screens/main_flow/screens/register/categories/screens/create_and_edit_category/import_categories/models/import_category_data.dart';

class ExcelParserService {
  ParsedExcelData parseExcelData(Sheet sheet, BuildContext context) {
    final categories = <ImportCategoryData>[];
    var processedRows = 0;

    logger.i(
      'Using fixed column order: Column 0=Type, Column 1=Category, Column 2=Subcategory (optional)',
    );

    for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.rows[rowIndex];
      if (row.isEmpty || _isRowEmpty(row)) continue;

      processedRows++;

      final categoryData = _parseExcelRow(row, context);
      if (categoryData != null) {
        categories.add(categoryData);
      }
    }

    logger.i(
      'Found ${categories.length} categories to create from $processedRows valid data rows',
    );

    return ParsedExcelData(categories: categories, validRows: processedRows);
  }

  bool _isRowEmpty(List<Data?> row) {
    final rowData = <String>[];
    for (var colIndex = 0; colIndex < row.length; colIndex++) {
      final cellValue = row[colIndex]?.value?.toString() ?? 'NULL';
      rowData.add(cellValue);
    }

    return rowData.every((cell) => cell == 'NULL' || cell.trim().isEmpty);
  }

  ImportCategoryData? _parseExcelRow(
    List<Data?> row,
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

    return _createImportCategoryData(
      categoryName,
      subcategoryName,
      categoryType,
    );
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

  ImportCategoryData _createImportCategoryData(
    String categoryName,
    String? subcategoryName,
    FinancialType categoryType,
  ) {
    if (subcategoryName == null || subcategoryName.isEmpty) {
      return ImportCategoryData(
        name: categoryName,
        type: categoryType,
        isParent: true,
        parentName: categoryName,
      );
    } else {
      return ImportCategoryData(
        name: subcategoryName,
        type: categoryType,
        isParent: false,
        parentName: categoryName,
      );
    }
  }

  List<List<String>> generateSampleData(BuildContext context) {
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
}
