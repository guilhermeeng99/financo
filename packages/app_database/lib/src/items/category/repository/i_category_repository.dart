import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../../../database/database_manager.dart';
import '../domain/category_table.dart';

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

  Future<Either<Failure, String>> getCategoryDisplayName(int id);

  Future<Either<Failure, bool>> checkNameConflict(
    String name,
    FinancialType type,
    int? parentCategoryId,
    int? excludeId,
  );
}
