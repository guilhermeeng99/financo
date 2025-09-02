import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../domain/index.dart';
import '../repository/i_category_repository.dart';

mixin CategoryQueryUsecaseOperations {
  ICategoryRepository get categoryRepository;

  Future<Either<Failure, CategoryData?>> getCategoryById(int id) async {
    return categoryRepository.getCategoryById(id);
  }

  Future<Either<Failure, String>> getCategoryDisplayName(int id) async {
    return categoryRepository.getCategoryDisplayName(id);
  }

  Future<Either<Failure, List<CategoryData>>> getEligibleParentCategories(
    FinancialType type,
    int? excludeCategoryId,
  ) async {
    return categoryRepository.getEligibleParentCategories(
      type,
      excludeCategoryId,
    );
  }

  Future<Either<Failure, List<CategoryData>>> getCategoriesByType(
    FinancialType type, {
    bool onlyActive = true,
  }) async {
    return categoryRepository.getCategoriesByType(type, onlyActive: onlyActive);
  }

  Future<
    Either<Failure, Map<FinancialType, Map<CategoryData, List<CategoryData>>>>
  >
  getCategoriesMapAsync({bool onlyActive = true}) async {
    try {
      final result = <FinancialType, Map<CategoryData, List<CategoryData>>>{};

      for (final type in FinancialType.values) {
        final categoriesResult = await categoryRepository.getCategoriesByType(
          type,
          onlyActive: onlyActive,
        );

        if (categoriesResult.isLeft) {
          return categoriesResult.fold(
            Either.left,
            (_) => Either.left(const DatabaseFailure('Unexpected error')),
          );
        }

        final allCategories = categoriesResult.fold(
          (_) => <CategoryData>[],
          (categories) => categories,
        );

        final categorySubcategoryMap = <CategoryData, List<CategoryData>>{};

        final parentCategories = allCategories
            .where((cat) => cat.parentCategoryId == null)
            .toList();

        for (final parentCategory in parentCategories) {
          final subcategories = allCategories
              .where((sub) => sub.parentCategoryId == parentCategory.id)
              .toList();
          categorySubcategoryMap[parentCategory] = subcategories;
        }

        if (categorySubcategoryMap.isNotEmpty) {
          result[type] = categorySubcategoryMap;
        }
      }

      return Either.right(result);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error fetching categories and subcategories: $e'),
      );
    }
  }
}
