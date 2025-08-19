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
    CategoryType type,
  );

  Future<Either<Failure, List<CategoryData>>> getEligibleParentCategories(
    CategoryType type,
    int? excludeCategoryId,
  );
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
    CategoryType type,
  ) async {
    try {
      final result =
          await (_database.select(_database.categories)
                ..where(
                  (tbl) =>
                      tbl.categoryType.equals(type.value) &
                      tbl.isActive.equals(true),
                )
                ..orderBy([(t) => OrderingTerm(expression: t.name)]))
              .get();
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
      // Buscar todas as categorias do tipo especificado
      final allCategoriesQuery = _database.select(_database.categories)
        ..where(
          (tbl) =>
              tbl.categoryType.equals(type.value) & tbl.isActive.equals(true),
        );

      // Se há uma categoria a ser excluída (modo edição), excluí-la
      if (excludeCategoryId != null) {
        allCategoriesQuery.where(
          (tbl) => tbl.id.equals(excludeCategoryId).not(),
        );
      }

      final allCategories = await allCategoriesQuery.get();

      // Buscar todas as categorias que têm subcategorias
      final categoriesWithSubcategories =
          await (_database.select(_database.categories)..where(
                (tbl) =>
                    tbl.parentCategoryId.isNotNull() &
                    tbl.isActive.equals(true),
              ))
              .get();

      // Extrair IDs das categorias que são pais (têm subcategorias)
      final parentIds = categoriesWithSubcategories
          .map((category) => category.parentCategoryId!)
          .toSet();

      // Filtrar categorias que não têm subcategorias
      final eligibleParents = allCategories
          .where((category) => !parentIds.contains(category.id))
          .toList();

      // Ordenar por nome
      eligibleParents.sort((a, b) => a.name.compareTo(b.name));

      return Either.right(eligibleParents);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error fetching eligible parent categories: $e'),
      );
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
      // Soft delete - mark as inactive
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
