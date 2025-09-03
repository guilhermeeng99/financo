import '../../../core/exceptions.dart';

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
    if (trimmedValue.length > 15) {
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
