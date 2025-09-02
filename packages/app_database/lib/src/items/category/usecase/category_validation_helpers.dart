import '../../../core/either.dart';
import '../../../core/exceptions.dart';
import '../../../core/failures.dart';
import '../domain/index.dart';

class CategoryValidationHelpers {
  static Either<Failure, CategoryName> validateCategoryName(String name) {
    try {
      final categoryName = CategoryName.create(name);
      return Either.right(categoryName);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        ValidationFailure('Unexpected error validating category name: $e'),
      );
    }
  }

  static Either<Failure, ParentCategoryId> validateParentCategoryId(
    int? parentCategoryId,
  ) {
    try {
      final parentId = ParentCategoryId.create(parentCategoryId);
      return Either.right(parentId);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        ValidationFailure('Unexpected error validating parent category ID: $e'),
      );
    }
  }

  static bool hasAnyChanges({
    String? name,
    int? parentCategoryId,
    bool? isActive,
    bool updateParentId = false,
  }) {
    return name != null || updateParentId || isActive != null;
  }
}
