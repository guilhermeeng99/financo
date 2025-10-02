import 'package:app_database/app_database.dart';

class ImportCategoryData {
  const ImportCategoryData({
    required this.name,
    required this.type,
    required this.isParent,
    required this.parentName,
    this.parentId,
  });

  final String name;
  final FinancialType type;
  final bool isParent;
  final String parentName;
  final int? parentId;

  String get key => '${type}_$parentName';
}

class ParsedExcelData {
  const ParsedExcelData({
    required this.categories,
    required this.validRows,
  });

  final List<ImportCategoryData> categories;
  final int validRows;
}

class CreatedParentCategory {
  const CreatedParentCategory({
    required this.id,
    required this.name,
    required this.categoryType,
  });

  final int id;
  final String name;
  final FinancialType categoryType;
}
