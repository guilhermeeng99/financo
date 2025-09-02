import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../../../database/database_manager.dart';
import '../domain/category_table.dart';

mixin CategoryQueryOperations {
  DatabaseManager get database;

  Future<Either<Failure, CategoryData?>> getCategoryByNameAndTypeAndParent(
    String name,
    FinancialType type,
    int? parentCategoryId,
  ) async {
    try {
      final query = database.select(database.categories)
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

  Future<Either<Failure, List<CategoryData>>> getCategoriesByType(
    FinancialType type, {
    bool onlyActive = true,
  }) async {
    try {
      var query = database.select(database.categories)
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

  Future<Either<Failure, List<CategoryData>>> getEligibleParentCategories(
    FinancialType type,
    int? excludeCategoryId,
  ) async {
    try {
      final allCategoriesQuery = database.select(database.categories)
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

  Future<Either<Failure, CategoryData?>> getCategoryById(int id) async {
    try {
      final result = await (database.select(
        database.categories,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      return Either.right(result);
    } catch (e) {
      return Either.left(DatabaseFailure('Error fetching category by id: $e'));
    }
  }

  Future<Either<Failure, String>> getCategoryDisplayName(int id) async {
    try {
      final query = database.selectOnly(database.categories)
        ..addColumns([
          database.categories.name,
          database.categories.parentCategoryId,
        ])
        ..where(database.categories.id.equals(id));

      final result = await query.getSingleOrNull();

      if (result == null) {
        return Either.right('Category not found');
      }

      final categoryName = result.read(database.categories.name)!;
      final parentCategoryId = result.read(
        database.categories.parentCategoryId,
      );

      if (parentCategoryId == null) {
        return Either.right(categoryName);
      }

      final parentQuery = database.select(database.categories)
        ..where((tbl) => tbl.id.equals(parentCategoryId));

      final parentResult = await parentQuery.getSingleOrNull();

      if (parentResult != null) {
        return Either.right('${parentResult.name} / $categoryName');
      } else {
        return Either.right(categoryName);
      }
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error getting category display name: $e'),
      );
    }
  }
}
