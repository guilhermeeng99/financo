import 'package:drift/drift.dart';

import '../../../core/financial_type.dart';

@UseRowClass(CategoryData)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 50)();
  TextColumn get categoryType => textEnum<FinancialType>()();
  IntColumn get parentCategoryId =>
      integer().nullable().references(Categories, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {name, categoryType},
  ];
}

class CategoryData {
  CategoryData({
    required this.id,
    required this.name,
    required this.categoryType,
    required this.isActive,
    this.parentCategoryId,
  });

  final int id;
  final String name;
  final FinancialType categoryType;
  final int? parentCategoryId;
  final bool isActive;
}
