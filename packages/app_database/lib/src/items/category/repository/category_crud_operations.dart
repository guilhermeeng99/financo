import 'package:sqlite3/sqlite3.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
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
      final duplicateFailure = await _checkForDuplicateCategory(
        category.name.value,
        category.categoryType.value,
        category.parentCategoryId.present
            ? category.parentCategoryId.value
            : null,
      );
      if (duplicateFailure != null) return duplicateFailure;
    }

    try {
      final result = await database
          .into(database.categories)
          .insertReturning(category);
      return Either.right(result);
    } on SqliteException catch (e) {
      return Either.left(_handleSqliteException(e));
    } catch (e) {
      return Either.left(_handleGenericException(e, 'creating'));
    }
  }

  Future<Either<Failure, CategoryData>> updateCategory(
    int id,
    CategoriesCompanion category,
  ) async {
    if (category.name.present) {
      final duplicateFailure = await _checkForDuplicateCategoryOnUpdate(
        category,
        id,
      );
      if (duplicateFailure != null) return duplicateFailure;
    }

    try {
      final updated = await (database.update(
        database.categories,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(category);

      if (updated.isEmpty) {
        return Either.left(DatabaseFailure('Category with id $id not found'));
      }

      return Either.right(updated.first);
    } on SqliteException catch (e) {
      return Either.left(_handleSqliteException(e));
    } catch (e) {
      return Either.left(_handleGenericException(e, 'updating'));
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

  Future<Either<Failure, CategoryData>?> _checkForDuplicateCategory(
    String name,
    FinancialType type,
    int? parentCategoryId,
  ) async {
    // Check for any category with the same name in the same financial type
    final nameConflictCheck = await checkNameConflict(
      name,
      type,
      parentCategoryId,
      null,
    );

    return nameConflictCheck.fold(
      Either.left,
      (hasConflict) => hasConflict
          ? Either.left(
              const DuplicateEntryFailure(
                'A category with this name already exists',
              ),
            )
          : null,
    );
  }

  Future<Either<Failure, CategoryData>?> _checkForDuplicateCategoryOnUpdate(
    CategoriesCompanion category,
    int excludeId,
  ) async {
    final currentCategoryResult = await getCategoryById(excludeId);
    final currentCategory = currentCategoryResult.fold(
      (failure) => null,
      (categoryData) => categoryData,
    );

    if (currentCategory == null) {
      return Either.left(const DatabaseFailure('Category not found'));
    }

    final categoryType = category.categoryType.present
        ? category.categoryType.value
        : currentCategory.categoryType;
    final parentCategoryId = category.parentCategoryId.present
        ? category.parentCategoryId.value
        : currentCategory.parentCategoryId;

    // Check for name conflicts with any other category
    final nameConflictCheck = await checkNameConflict(
      category.name.value,
      categoryType,
      parentCategoryId,
      excludeId,
    );

    return nameConflictCheck.fold(
      Either.left,
      (hasConflict) => hasConflict
          ? Either.left(
              const DuplicateEntryFailure(
                'A category with this name already exists',
              ),
            )
          : null,
    );
  }

  Failure _handleSqliteException(SqliteException e) {
    if (e.extendedResultCode == 2067 ||
        e.message.toLowerCase().contains('unique')) {
      return const DuplicateEntryFailure('Category name already exists');
    }
    return DatabaseFailure('SQLite error: ${e.message}');
  }

  Failure _handleGenericException(Object e, String operation) {
    final errorMessage = e.toString().toLowerCase();
    if (errorMessage.contains('unique') ||
        errorMessage.contains('constraint') ||
        errorMessage.contains('duplicate')) {
      return const DuplicateEntryFailure('Category name already exists');
    }
    return DatabaseFailure('Error $operation category: $e');
  }
}
