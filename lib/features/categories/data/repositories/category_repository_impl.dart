import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/categories/data/models/category_model.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required CategoryRemoteDataSource remoteDataSource,
    required CategoriesDao categoriesDao,
  }) : _remote = remoteDataSource,
       _dao = categoriesDao;

  final CategoryRemoteDataSource _remote;
  final CategoriesDao _dao;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    required String userId,
    bool forceRefresh = false,
  }) async {
    try {
      if (forceRefresh) {
        final remote = await _remote.getCategories(
          userId: userId,
        );
        await _dao.deleteAllCategories();
        if (remote.isNotEmpty) {
          await _dao.insertAllCategories(remote);
        }
      }
      return Right(await _dao.getCategories(userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await _remote.createCategory(model);
      await _dao.upsertCategory(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await _remote.updateCategory(model);
      await _dao.upsertCategory(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      final children = await _dao.getChildCategories(id);
      if (children.isNotEmpty) {
        return const Left(
          ValidationFailure(
            'Cannot delete a category that has subcategories.',
          ),
        );
      }
      await _remote.deleteCategory(id);
      await _dao.deleteCategory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
