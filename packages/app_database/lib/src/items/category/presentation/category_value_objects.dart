import '../../../core/exceptions.dart';

class CategoryName {
  factory CategoryName.create(String value) {
    final trimmedValue = value.trim();
    const nameMinLengthNumber = 2;
    const nameMaxLengthNumber = 15;

    if (trimmedValue.isEmpty) {
      throw const NameEmptyException();
    }

    if (trimmedValue.length < nameMinLengthNumber) {
      throw const NameTooShortException(nameMinLengthNumber);
    }

    if (trimmedValue.length > nameMaxLengthNumber) {
      throw const NameTooLongException(nameMaxLengthNumber);
    }

    return CategoryName._(trimmedValue);
  }

  CategoryName._(this.value);

  final String value;
}

class ParentCategoryId {
  factory ParentCategoryId.create(int? value) {
    if (value != null && value <= 0) {
      throw const InvalidParentIdException();
    }

    return ParentCategoryId._(value);
  }

  factory ParentCategoryId.none() => ParentCategoryId._(null);

  ParentCategoryId._(this.value);

  final int? value;

  bool get hasParent => value != null;
}
