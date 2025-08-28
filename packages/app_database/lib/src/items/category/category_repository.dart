import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../core/either.dart';
import '../../core/failures.dart';
import '../../core/financial_type.dart';
import '../../database/database_manager.dart';
import 'category_domain.dart';

abstract class ICategoryRepository {
  Future<Either<Failure, CategoryData>> createCategory(
    CategoriesCompanion category,
  );

  Future<Either<Failure, CategoryData>> updateCategory(
    int id,
    CategoriesCompanion category,
  );

  Future<Either<Failure, bool>> deleteCategory(int id);

  Future<Either<Failure, List<CategoryData>>> getCategoriesByType(
    FinancialType type, {
    bool onlyActive = true,
  });

  Future<Either<Failure, List<CategoryData>>> getEligibleParentCategories(
    FinancialType type,
    int? excludeCategoryId,
  );

  Future<Either<Failure, CategoryData?>> getCategoryById(int id);

  Future<Either<Failure, CategoryData?>> getCategoryByNameAndTypeAndParent(
    String name,
    FinancialType type,
    int? parentCategoryId,
  );
}

class CategoryRepository implements ICategoryRepository {
  CategoryRepository(this._database);

  final DatabaseManager _database;

  @override
  Future<Either<Failure, CategoryData?>> getCategoryByNameAndTypeAndParent(
    String name,
    FinancialType type,
    int? parentCategoryId,
  ) async {
    try {
      final query = _database.select(_database.categories)
        ..where(
          (tbl) =>
              tbl.name.equals(name) &
              tbl.categoryType.equals(type.value) &
              (parentCategoryId != null
                  ? tbl.parentCategoryId.equals(parentCategoryId)
                  : tbl.parentCategoryId.isNull()),
        );

      final result = await query.getSingleOrNull();
      return Either.right(result);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error checking category existence: $e'),
      );
    }
  }

  @override
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
      final result = await _database
          .into(_database.categories)
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

  @override
  Future<Either<Failure, List<CategoryData>>> getCategoriesByType(
    FinancialType type, {
    bool onlyActive = true,
  }) async {
    try {
      var query = _database.select(_database.categories)
        ..where((tbl) => tbl.categoryType.equals(type.value));

      if (onlyActive) {
        query = query..where((tbl) => tbl.isActive.equals(true));
      }

      query = query..orderBy([(t) => OrderingTerm(expression: t.name)]);

      final result = await query.get();
      return Either.right(result);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error fetching categories by type: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<CategoryData>>> getEligibleParentCategories(
    FinancialType type,
    int? excludeCategoryId,
  ) async {
    try {
      final allCategoriesQuery = _database.select(_database.categories)
        ..where(
          (tbl) =>
              tbl.categoryType.equals(type.value) & tbl.isActive.equals(true),
        );

      if (excludeCategoryId != null) {
        allCategoriesQuery.where(
          (tbl) => tbl.id.equals(excludeCategoryId).not(),
        );
      }

      final allCategories = await allCategoriesQuery.get();

      final eligibleParents = allCategories
          .where((category) => category.parentCategoryId == null)
          .toList();

      eligibleParents.sort((a, b) => a.name.compareTo(b.name));

      return Either.right(eligibleParents);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error fetching eligible parent categories: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, CategoryData?>> getCategoryById(int id) async {
    try {
      final result = await (_database.select(
        _database.categories,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching category by id: $e'));
    }
  }

  @override
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
      final updated = await (_database.update(
        _database.categories,
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

  @override
  Future<Either<Failure, bool>> deleteCategory(int id) async {
    try {
      await (_database.delete(
        _database.categories,
      )..where((tbl) => tbl.parentCategoryId.equals(id))).go();

      final deletedCount = await (_database.delete(
        _database.categories,
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
