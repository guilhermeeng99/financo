import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../domain/index.dart';
import '../presentation/index.dart';

abstract class ICategoryUsecase {
  Future<Either<Failure, CategoryData>> createCategory({
    required CategoryName name,
    required FinancialType categoryType,
    ParentCategoryId? parentCategoryId,
  });

  Future<Either<Failure, CategoryData>> updateCategory({
    required int id,
    CategoryName? name,
    ParentCategoryId? parentCategoryId,
    bool? isActive,
    bool updateParentId = false,
  });

  Future<Either<Failure, bool>> deleteCategory(int id);

  Future<Either<Failure, CategoryData?>> getCategoryById(int id);

  Future<Either<Failure, String>> getCategoryDisplayName(int id);

  Future<Either<Failure, List<CategoryData>>> getCategoriesByType(
    FinancialType type, {
    bool onlyActive = true,
  });

  Future<Either<Failure, List<CategoryData>>> getEligibleParentCategories(
    FinancialType type,
    int? excludeCategoryId,
  );

  Future<
    Either<Failure, Map<FinancialType, Map<CategoryData, List<CategoryData>>>>
  >
  getCategoriesMapAsync({bool onlyActive = true});
}
