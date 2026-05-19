import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/asset_classes_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/data/datasources/asset_class_remote_datasource.dart';
import 'package:financo/features/investments/data/models/asset_class_model.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';

class AssetClassRepositoryImpl implements AssetClassRepository {
  AssetClassRepositoryImpl({
    required AssetClassRemoteDataSource remoteDataSource,
    required AssetClassesDao assetClassesDao,
  }) : _remote = remoteDataSource,
       _dao = assetClassesDao;

  final AssetClassRemoteDataSource _remote;
  final AssetClassesDao _dao;

  @override
  Future<Either<Failure, List<AssetClassEntity>>> getAssetClasses({
    required String userId,
    bool forceRefresh = false,
  }) async {
    try {
      if (forceRefresh) {
        final remote = await _remote.getAssetClasses(userId: userId);
        await _dao.deleteAllAssetClasses();
        if (remote.isNotEmpty) {
          await _dao.insertAllAssetClasses(remote);
        }
      }
      return Right(await _dao.getAssetClasses(userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AssetClassEntity>> createAssetClass(
    AssetClassEntity assetClass,
  ) async {
    try {
      final model = AssetClassModel.fromEntity(assetClass);
      final result = await _remote.createAssetClass(model);
      await _dao.upsertAssetClass(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AssetClassEntity>> updateAssetClass(
    AssetClassEntity assetClass,
  ) async {
    try {
      final model = AssetClassModel.fromEntity(assetClass);
      final result = await _remote.updateAssetClass(model);
      await _dao.upsertAssetClass(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAssetClass(String id) async {
    try {
      await _remote.deleteAssetClass(id);
      await _dao.deleteAssetClass(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
