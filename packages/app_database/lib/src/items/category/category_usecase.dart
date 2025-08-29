import 'package:app_database/app_database.dart';
import 'package:app_database/src/items/category/category_repository.dart';
import 'package:drift/drift.dart';

class CategoryUsecase {
  CategoryUsecase(this._categoryRepository);

  final ICategoryRepository _categoryRepository;

  Future<Either<Failure, CategoryData>> createCategory({
    required String name,
    required FinancialType categoryType,
    int? parentCategoryId,
  }) async {
    try {
      final categoryName = CategoryName.create(name);
      final parentId = ParentCategoryId.create(parentCategoryId);

      final categoryCompanion = CategoriesCompanion(
        name: Value(categoryName.value),
        categoryType: Value(categoryType),
        parentCategoryId: Value.absentIfNull(parentId.value),
      );

      return await _categoryRepository.createCategory(categoryCompanion);
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
      Value<String>? nameValue;
      Value<int?>? parentIdValue;
      Value<bool>? isActiveValue;

      if (name != null) {
        final categoryName = CategoryName.create(name);
        nameValue = Value(categoryName.value);
      }

      if (updateParentId) {
        final parentId = ParentCategoryId.create(parentCategoryId);
        parentIdValue = Value(parentId.value);
      }

      if (isActive != null) {
        isActiveValue = Value(isActive);
      }

      if (nameValue == null && parentIdValue == null && isActiveValue == null) {
        return Either.left(
          const ValidationFailure(
            'At least one field must be provided for update',
          ),
        );
      }

      final categoryCompanion = CategoriesCompanion(
        id: Value(id),
        name: nameValue ?? const Value.absent(),
        parentCategoryId: parentIdValue ?? const Value.absent(),
        isActive: isActiveValue ?? const Value.absent(),
      );

      return await _categoryRepository.updateCategory(id, categoryCompanion);
    } on ValidationException catch (e) {
      return Either.left(ValidationFailure(e.message));
    } catch (e) {
      return Either.left(
        DatabaseFailure('Unexpected error updating category: $e'),
      );
    }
  }

  Future<Either<Failure, bool>> deleteCategory(int id) async {
    return _categoryRepository.deleteCategory(id);
  }

  Future<Either<Failure, CategoryData?>> getCategoryById(int id) async {
    return _categoryRepository.getCategoryById(id);
  }

  Future<Either<Failure, String>> getCategoryDisplayName(int id) async {
    return _categoryRepository.getCategoryDisplayName(id);
  }

  Future<Either<Failure, List<CategoryData>>> getEligibleParentCategories(
    FinancialType type,
    int? excludeCategoryId,
  ) async {
    return _categoryRepository.getEligibleParentCategories(
      type,
      excludeCategoryId,
    );
  }

  Future<Either<Failure, List<CategoryData>>> getCategoriesByType(
    FinancialType type, {
    bool onlyActive = true,
  }) async {
    return _categoryRepository.getCategoriesByType(
      type,
      onlyActive: onlyActive,
    );
  }

  Future<
    Either<Failure, Map<FinancialType, Map<CategoryData, List<CategoryData>>>>
  >
  getCategoriesAndSubcategories({bool onlyActive = true}) async {
    try {
      final result = <FinancialType, Map<CategoryData, List<CategoryData>>>{};

      for (final type in FinancialType.values) {
        final categoriesResult = await _categoryRepository.getCategoriesByType(
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
