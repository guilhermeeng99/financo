import 'package:drift/drift.dart';

import '../../core/exceptions.dart';
import '../../core/financial_type.dart';

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
    {name, categoryType, parentCategoryId},
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

  CategoryData copyWith({
    int? id,
    String? name,
    FinancialType? categoryType,
    int? parentCategoryId,
    bool? isActive,
  }) {
    return CategoryData(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryType: categoryType ?? this.categoryType,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'CategoryData{'
        'id: $id, '
        'name: $name, '
        'categoryType: $categoryType, '
        'parentCategoryId: $parentCategoryId, '
        'isActive: $isActive, '
        '}';
  }
}

class CategoryName {
  factory CategoryName.create(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      throw const ValidationException('Category name cannot be empty');
    }

    if (trimmedValue.length < 2) {
      throw const ValidationException(
        'Category name must be at least 2 characters long',
      );
    }
    if (trimmedValue.length > 50) {
      throw const ValidationException(
        'Category name must be at most 50 characters long',
      );
    }

    return CategoryName._(trimmedValue);
  }

  CategoryName._(this.value);

  final String value;
}

class ParentCategoryId {
  factory ParentCategoryId.create(int? value) {
    if (value != null && value <= 0) {
      throw const ValidationException(
        'Parent category ID must be a positive number',
      );
    }

    return ParentCategoryId._(value);
  }

  factory ParentCategoryId.none() => ParentCategoryId._(null);

  ParentCategoryId._(this.value);

  final int? value;

  bool get hasParent => value != null;
}
