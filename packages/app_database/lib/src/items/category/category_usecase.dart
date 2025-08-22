import 'package:app_database/app_database.dart';
import 'package:app_database/src/items/category/category_repository.dart';
import 'package:drift/drift.dart';

class CategoryUsecase {
  CategoryUsecase(this._categoryRepository);

  final ICategoryRepository _categoryRepository;

  Future<Either<Failure, CategoryData>> createCategory({
    required String name,
    required CategoryType categoryType,
    int? parentCategoryId,
  }) async {
    try {
      final categoryName = CategoryName.create(name);
      final parentId = ParentCategoryId.create(parentCategoryId);

      final categoryCompanion = CategoriesCompanion(
        name: Value(categoryName.value),
        categoryType: Value(categoryType),
        parentCategoryId: Value.absentIfNull(parentId.value),
      );

      return await _categoryRepository.createCategory(categoryCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating category: $e'),
      );
    }
  }

  Future<Either<Failure, List<CategoryData>>> getAllCategories() async {
    return _categoryRepository.getAllCategories();
  }


  Future<Either<Failure, CategoryData>> updateCategory({
    required int id,
    String? name,
    int? parentCategoryId,
    bool? isActive,
    bool updateParentId = false,
  }) async {
    try {
      Value<String>? nameValue;
      Value<int?>? parentIdValue;
      Value<bool>? isActiveValue;

      if (name != null) {
        final categoryName = CategoryName.create(name);
        nameValue = Value(categoryName.value);
      }

      if (updateParentId) {
        final parentId = ParentCategoryId.create(parentCategoryId);
        parentIdValue = Value(parentId.value);
      }

      if (isActive != null) {
        isActiveValue = Value(isActive);
      }

      if (nameValue == null && parentIdValue == null && isActiveValue == null) {
        return Either.left(
          const ValidationFailure(
            'At least one field must be provided for update',
          ),
        );
      }

      final categoryCompanion = CategoriesCompanion(
        id: Value(id),
        name: nameValue ?? const Value.absent(),
        parentCategoryId: parentIdValue ?? const Value.absent(),
        isActive: isActiveValue ?? const Value.absent(),
      );

      return await _categoryRepository.updateCategory(id, categoryCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error updating category: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteCategory(int id) async {
    return _categoryRepository.deleteCategory(id);
  }
}
