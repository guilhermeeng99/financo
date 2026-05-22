import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
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
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getCategories(userId: userId);
        await _dao.deleteAllCategories();
        if (remote.isNotEmpty) {
          await _dao.insertAllCategories(remote);
        }
      }
      return _dao.getCategories(userId);
    });
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  ) {
    return guardServer(() async {
      final result = await _remote.createCategory(
        CategoryModel.fromEntity(category),
      );
      await _dao.upsertCategory(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  ) {
    return guardServer(() async {
      final result = await _remote.updateCategory(
        CategoryModel.fromEntity(category),
      );
      await _dao.upsertCategory(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    // Not routed through guardServer: the subcategory guard returns a
    // ValidationFailure (not a ServerException) before any remote call.
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
