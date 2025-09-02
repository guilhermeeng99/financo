import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/exceptions.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../../../database/database_manager.dart';
import '../domain/index.dart';
import '../repository/i_category_repository.dart';
import 'category_validation_helpers.dart';

mixin CategoryCrudUsecaseOperations {
  ICategoryRepository get categoryRepository;

  Future<Either<Failure, CategoryData>> createCategory({
    required String name,
    required FinancialType categoryType,
    int? parentCategoryId,
  }) async {
    try {
      final nameResult = CategoryValidationHelpers.validateCategoryName(name);
      if (nameResult.isLeft) {
        return nameResult.fold(
          Either.left,
          (_) => throw StateError('This should never happen'),
        );
      }

      final parentIdResult = CategoryValidationHelpers.validateParentCategoryId(
        parentCategoryId,
      );
      if (parentIdResult.isLeft) {
        return parentIdResult.fold(
          Either.left,
          (_) => throw StateError('This should never happen'),
        );
      }

      final categoryName = nameResult.fold(
        (_) => throw StateError('This should never happen'),
        (r) => r,
      );
      final parentId = parentIdResult.fold(
        (_) => throw StateError('This should never happen'),
        (r) => r,
      );

      final categoryCompanion = CategoriesCompanion(
        name: Value(categoryName.value),
        categoryType: Value(categoryType),
        parentCategoryId: Value.absentIfNull(parentId.value),
      );

      return await categoryRepository.createCategory(categoryCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error creating category: $e'),
      );
    }
  }

  Future<Either<Failure, CategoryData>> updateCategory({
    required int id,
    String? name,
    int? parentCategoryId,
    bool? isActive,
    bool updateParentId = false,
  }) async {
    try {
      if (!CategoryValidationHelpers.hasAnyChanges(
        name: name,
        parentCategoryId: parentCategoryId,
        isActive: isActive,
        updateParentId: updateParentId,
      )) {
        return Either.left(
          const ValidationFailure(
            'At least one field must be provided for update',
          ),
        );
      }

      Value<String>? nameValue;
      Value<int?>? parentIdValue;
      Value<bool>? isActiveValue;

      if (name != null) {
        final nameResult = CategoryValidationHelpers.validateCategoryName(name);
        if (nameResult.isLeft) {
          return nameResult.fold(
            Either.left,
            (_) => throw StateError('This should never happen'),
          );
        }
        final categoryName = nameResult.fold(
          (_) => throw StateError('This should never happen'),
          (r) => r,
        );
        nameValue = Value(categoryName.value);
      }

      if (updateParentId) {
        final parentIdResult =
            CategoryValidationHelpers.validateParentCategoryId(
              parentCategoryId,
            );
        if (parentIdResult.isLeft) {
          return parentIdResult.fold(
            Either.left,
            (_) => throw StateError('This should never happen'),
          );
        }
        final parentId = parentIdResult.fold(
          (_) => throw StateError('This should never happen'),
          (r) => r,
        );
        parentIdValue = Value(parentId.value);
      }

      if (isActive != null) {
        isActiveValue = Value(isActive);
      }

      final categoryCompanion = CategoriesCompanion(
        id: Value(id),
        name: nameValue ?? const Value.absent(),
        parentCategoryId: parentIdValue ?? const Value.absent(),
        isActive: isActiveValue ?? const Value.absent(),
      );

      return await categoryRepository.updateCategory(id, categoryCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error updating category: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteCategory(int id) async {
    return categoryRepository.deleteCategory(id);
  }
}
