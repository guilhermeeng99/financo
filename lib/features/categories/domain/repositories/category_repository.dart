import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  );

  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  );

  Future<Either<Failure, void>> deleteCategory(String id);
}
