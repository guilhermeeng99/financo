import 'package:dartz/dartz.dart';
import 'package:financo/core/cache/app_data_cache.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/categories/data/models/category_model.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required CategoryRemoteDataSource remoteDataSource,
    required AppDataCache cache,
  }) : _remote = remoteDataSource,
       _cache = cache;

  final CategoryRemoteDataSource _remote;
  final AppDataCache _cache;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    required String userId,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _cache.categories != null) {
        return Right(_cache.categories!);
      }
      final result = await _remote.getCategories(userId: userId);
      _cache.categories = result;
      return Right(result);
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
      _cache.categories = null;
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
      _cache.categories = null;
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _remote.deleteCategory(id);
      _cache.categories = null;
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
