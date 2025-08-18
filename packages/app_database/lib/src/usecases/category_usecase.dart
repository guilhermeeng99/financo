import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

class CategoryUsecase {
  CategoryUsecase(this._categoryRepository);

  final ICategoryRepository _categoryRepository;

  Future<Either<Failure, CategoryData>> createCategory({
    required String name,
    required CategoryType categoryType,
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

  Future<Either<Failure, List<CategoryData>>> getAllCategories() async {
    return _categoryRepository.getAllCategories();
  }

  Future<Either<Failure, List<CategoryData>>> getExpenseCategories() async {
    return _categoryRepository.getCategoriesByType(CategoryType.expense);
  }

  Future<Either<Failure, List<CategoryData>>> getIncomeCategories() async {
    return _categoryRepository.getCategoriesByType(CategoryType.income);
  }

  Future<Either<Failure, List<CategoryData>>> getSubcategories(
    int parentId,
  ) async {
    return _categoryRepository.getSubcategories(parentId);
  }

  Future<Either<Failure, CategoryData>> getCategoryById(int id) async {
    return _categoryRepository.getCategoryById(id);
  }

  Future<Either<Failure, CategoryData>> updateCategory({
    required int id,
    String? name,
    int? parentCategoryId,
  }) async {
    try {
      CategoriesCompanion categoryCompanion;

      if (name != null) {
        final categoryName = CategoryName.create(name);
        final parentId = ParentCategoryId.create(parentCategoryId);

        categoryCompanion = CategoriesCompanion(
          id: Value(id),
          name: Value(categoryName.value),
          parentCategoryId: Value.absentIfNull(parentId.value),
        );
      } else {
        final parentId = ParentCategoryId.create(parentCategoryId);

        categoryCompanion = CategoriesCompanion(
          id: Value(id),
          parentCategoryId: Value.absentIfNull(parentId.value),
        );
      }

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
}
