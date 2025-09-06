import 'package:app_database/src/items/category/presentation/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../../../database/database_manager.dart';
import '../domain/index.dart';
import '../repository/i_category_repository.dart';

mixin CategoryCrudUsecaseOperations {
  ICategoryRepository get categoryRepository;

  Future<Either<Failure, CategoryData>> createCategory({
    required CategoryName name,
    required FinancialType categoryType,
    ParentCategoryId? parentCategoryId,
  }) async {
    try {
      final categoryCompanion = CategoriesCompanion(
        name: Value(name.value),
        categoryType: Value(categoryType),
        parentCategoryId: parentCategoryId != null
            ? Value.absentIfNull(parentCategoryId.value)
            : const Value.absent(),
      );

      return await categoryRepository.createCategory(categoryCompanion);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating category: $e'),
      );
    }
  }

  Future<Either<Failure, CategoryData>> updateCategory({
    required int id,
    CategoryName? name,
    ParentCategoryId? parentCategoryId,
    bool? isActive,
    bool updateParentId = false,
  }) async {
    try {
      final currentCategoryResult = await categoryRepository.getCategoryById(
        id,
      );

      return await currentCategoryResult.fold(Either.left, (
        currentCategory,
      ) async {
        if (currentCategory == null) {
          return Either.left(const ValidationFailure('Category not found'));
        }

        if (_hasNoChanges(
          currentCategory: currentCategory,
          updateParentId: updateParentId,
          name: name,
          parentCategoryId: parentCategoryId,
          isActive: isActive,
        )) {
          return Either.left(
            const NoChangesFailure('No changes were provided'),
          );
        }

        final categoryCompanion = CategoriesCompanion(
          name: name != null ? Value(name.value) : const Value.absent(),
          parentCategoryId: updateParentId
              ? Value.absentIfNull(parentCategoryId?.value)
              : const Value.absent(),
          isActive: isActive != null ? Value(isActive) : const Value.absent(),
        );

        return categoryRepository.updateCategory(id, categoryCompanion);
      });
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error updating category: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteCategory(int id) async {
    try {
      return await categoryRepository.deleteCategory(id);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error deleting category: $e'),
      );
    }
  }

  bool _hasNoChanges({
    required CategoryData currentCategory,
    required bool updateParentId,
    CategoryName? name,
    ParentCategoryId? parentCategoryId,
    bool? isActive,
  }) {
    final nameChanged = name != null && name.value != currentCategory.name;
    final parentIdChanged =
        updateParentId &&
        parentCategoryId?.value != currentCategory.parentCategoryId;
    final isActiveChanged =
        isActive != null && isActive != currentCategory.isActive;

    return !nameChanged && !parentIdChanged && !isActiveChanged;
  }
}
