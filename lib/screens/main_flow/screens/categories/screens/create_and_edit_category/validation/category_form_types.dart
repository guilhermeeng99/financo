import 'package:app_database/app_database.dart';

class CategoryFormData {
  CategoryFormData({
    this.name = '',
    this.categoryType = FinancialType.expense,
    this.parentCategoryId,
  });

  factory CategoryFormData.fromCategory(CategoryData category) {
    return CategoryFormData(
      name: category.name,
      categoryType: category.categoryType,
      parentCategoryId: category.parentCategoryId,
    );
  }

  final String name;
  final FinancialType categoryType;
  final int? parentCategoryId;

  CategoryFormData copyWith({
    String? name,
    FinancialType? categoryType,
    int? parentCategoryId,
    bool clearParentCategoryId = false,
  }) {
    return CategoryFormData(
      name: name ?? this.name,
      categoryType: categoryType ?? this.categoryType,
      parentCategoryId: clearParentCategoryId
          ? null
          : (parentCategoryId ?? this.parentCategoryId),
    );
  }
}

class CategoryFormErrors {
  const CategoryFormErrors({this.name = ''});

  final String name;

  bool get hasErrors => name.isNotEmpty;

  CategoryFormErrors copyWith({String? name}) {
    return CategoryFormErrors(name: name ?? this.name);
  }

  CategoryFormErrors clear() {
    return const CategoryFormErrors();
  }
}

abstract class BaseCategoryParams {
  const BaseCategoryParams({
    required this.name,
    required this.categoryType,
    required this.parentCategoryId,
  });

  final CategoryName name;
  final FinancialType categoryType;
  final ParentCategoryId? parentCategoryId;
}

class CreateCategoryParams extends BaseCategoryParams {
  const CreateCategoryParams({
    required super.name,
    required super.categoryType,
    required super.parentCategoryId,
  });
}

class UpdateCategoryParams extends BaseCategoryParams {
  const UpdateCategoryParams({
    required this.id,
    required super.name,
    required super.categoryType,
    required super.parentCategoryId,
    required this.updateParentId,
  });

  final int id;
  final bool updateParentId;
}
