import 'package:sqlite3/sqlite3.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';
import '../domain/category_table.dart';
import 'category_query_operations.dart';

mixin CategoryCrudOperations on CategoryQueryOperations {
  @override
  DatabaseManager get database;

  Future<Either<Failure, CategoryData>> createCategory(
    CategoriesCompanion category,
  ) async {
    if (category.name.present && category.categoryType.present) {
      final existingCheck = await getCategoryByNameAndTypeAndParent(
        category.name.value,
        category.categoryType.value,
        category.parentCategoryId.present
            ? category.parentCategoryId.value
            : null,
      );

      final existing = existingCheck.fold(
        (failure) => null,
        (categoryData) => categoryData,
      );

      if (existing != null) {
        return Either.left(
          const DuplicateEntryFailure('Category name already exists'),
        );
      }
    }

    try {
      final result = await database
          .into(database.categories)
          .insertReturning(category);
      return Either.right(result);
    } on SqliteException catch (e) {
      if (e.extendedResultCode == 2067 ||
          e.message.toLowerCase().contains('unique')) {
        return Either.left(
          const DuplicateEntryFailure('Category name already exists'),
        );
      }
      return Either.left(DatabaseFailure('SQLite error: ${e.message}'));
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('unique') ||
          errorMessage.contains('constraint') ||
          errorMessage.contains('duplicate')) {
        return Either.left(
          const DuplicateEntryFailure('Category name already exists'),
        );
      }
      return Either.left(DatabaseFailure('Error creating category: $e'));
    }
  }

  Future<Either<Failure, CategoryData>> updateCategory(
    int id,
    CategoriesCompanion category,
  ) async {
    if (category.name.present) {
      final currentCategoryResult = await getCategoryById(id);
      final currentCategory = currentCategoryResult.fold(
        (failure) => null,
        (categoryData) => categoryData,
      );

      if (currentCategory != null) {
        final categoryType = category.categoryType.present
            ? category.categoryType.value
            : currentCategory.categoryType;
        final parentCategoryId = category.parentCategoryId.present
            ? category.parentCategoryId.value
            : currentCategory.parentCategoryId;

        final existingCheck = await getCategoryByNameAndTypeAndParent(
          category.name.value,
          categoryType,
          parentCategoryId,
        );

        final existing = existingCheck.fold(
          (failure) => null,
          (categoryData) => categoryData,
        );

        if (existing != null && existing.id != id) {
          return Either.left(
            const DuplicateEntryFailure('Category name already exists'),
          );
        }
      }
    }

    try {
      final updated = await (database.update(
        database.categories,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(category);

      if (updated.isEmpty) {
        return Either.left(DatabaseFailure('Category with id $id not found'));
      }

      return Either.right(updated.first);
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('unique') ||
          errorMessage.contains('constraint') ||
          errorMessage.contains('duplicate')) {
        return Either.left(
          const DuplicateEntryFailure('Category name already exists'),
        );
      }
      return Either.left(DatabaseFailure('Error updating category: $e'));
    }
  }

  Future<Either<Failure, bool>> deleteCategory(int id) async {
    try {
      await (database.delete(
        database.categories,
      )..where((tbl) => tbl.parentCategoryId.equals(id))).go();

      final deletedCount = await (database.delete(
        database.categories,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (deletedCount == 0) {
        return Either.left(DatabaseFailure('Category with id $id not found'));
      }

      return Either.right(true);
    } catch (e) {
      return Either.left(DatabaseFailure('Error deleting category: $e'));
    }
  }
}
