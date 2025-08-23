import 'package:drift/drift.dart';

import '../../core/either.dart';
import '../../core/failures.dart';
import '../../database/database_manager.dart';
import 'category_domain.dart';

abstract class ICategoryRepository {
  Future<Either<Failure, CategoryData>> createCategory(
    CategoriesCompanion category,
  );
  Future<Either<Failure, List<CategoryData>>> getAllCategories();
  Future<Either<Failure, List<CategoryData>>> getCategoriesByType(
    CategoryType type, {
    bool onlyActive = true,
    bool onlyMainCategories = false,
  });

  Future<Either<Failure, List<CategoryData>>> getEligibleParentCategories(
    CategoryType type,
    int? excludeCategoryId,
  );

  Future<Either<Failure, List<CategoryData>>> getSubcategoriesFor(
    int parentCategoryId,
  );

  Future<Either<Failure, CategoryData?>> getCategoryById(int id);

  Future<Either<Failure, CategoryData>> updateCategory(
    int id,
    CategoriesCompanion category,
  );
  Future<Either<Failure, bool>> deleteCategory(int id);
}

class CategoryRepository implements ICategoryRepository {
  CategoryRepository(this._database);

  final DatabaseManager _database;

  @override
  Future<Either<Failure, CategoryData>> createCategory(
    CategoriesCompanion category,
  ) async {
    try {
      final result = await _database
          .into(_database.categories)
          .insertReturning(category);
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error creating category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryData>>> getAllCategories() async {
    try {
      final result =
          await (_database.select(_database.categories)
                ..where((tbl) => tbl.isActive.equals(true))
                ..orderBy([(t) => OrderingTerm(expression: t.name)]))
              .get();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching categories: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryData>>> getCategoriesByType(
    CategoryType type, {
    bool onlyActive = true,
    bool onlyMainCategories = false,
  }) async {
    try {
      var query = _database.select(_database.categories)
        ..where((tbl) => tbl.categoryType.equals(type.value));

      if (onlyActive) {
        query = query..where((tbl) => tbl.isActive.equals(true));
      }

      if (onlyMainCategories) {
        query = query..where((tbl) => tbl.parentCategoryId.isNull());
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
    CategoryType type,
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

      final categoriesWithSubcategories =
          await (_database.select(_database.categories)..where(
                (tbl) =>
                    tbl.parentCategoryId.isNotNull() &
                    tbl.isActive.equals(true),
              ))
              .get();

      final parentIds = categoriesWithSubcategories
          .map((category) => category.parentCategoryId!)
          .toSet();

      final eligibleParents = allCategories
          .where((category) => !parentIds.contains(category.id))
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
  Future<Either<Failure, List<CategoryData>>> getSubcategoriesFor(
    int parentCategoryId,
  ) async {
    try {
      final result =
          await (_database.select(_database.categories)
                ..where(
                  (tbl) =>
                      tbl.parentCategoryId.equals(parentCategoryId) &
                      tbl.isActive.equals(true),
                )
                ..orderBy([(t) => OrderingTerm(expression: t.name)]))
              .get();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching subcategories: $e'));
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
    try {
      final updated = await (_database.update(
        _database.categories,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(category);

      if (updated.isEmpty) {
        return Either.left(DatabaseFailure('Category with id $id not found'));
      }

      return Either.right(updated.first);
    } catch (e) {
      return Either.left(DatabaseFailure('Error updating category: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(int id) async {
    try {
      final companion = CategoriesCompanion(
        id: Value(id),
        isActive: const Value(false),
      );

      final updated = await (_database.update(
        _database.categories,
      )..where((tbl) => tbl.id.equals(id))).writeReturning(companion);

      if (updated.isEmpty) {
        return Either.left(DatabaseFailure('Category with id $id not found'));
      }

      return Either.right(true);
    } catch (e) {
      return Either.left(DatabaseFailure('Error deleting category: $e'));
    }
  }
}
