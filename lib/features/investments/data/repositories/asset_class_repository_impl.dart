import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/asset_classes_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
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
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getAssetClasses(userId: userId);
        await _dao.deleteAllAssetClasses();
        if (remote.isNotEmpty) {
          await _dao.insertAllAssetClasses(remote);
        }
      }
      return _dao.getAssetClasses(userId);
    });
  }

  @override
  Future<Either<Failure, AssetClassEntity>> createAssetClass(
    AssetClassEntity assetClass,
  ) {
    return guardServer(() async {
      final result = await _remote.createAssetClass(
        AssetClassModel.fromEntity(assetClass),
      );
      await _dao.upsertAssetClass(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, AssetClassEntity>> updateAssetClass(
    AssetClassEntity assetClass,
  ) {
    return guardServer(() async {
      final result = await _remote.updateAssetClass(
        AssetClassModel.fromEntity(assetClass),
      );
      await _dao.upsertAssetClass(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteAssetClass(String id) {
    return guardServerVoid(() async {
      await _remote.deleteAssetClass(id);
      await _dao.deleteAssetClass(id);
    });
  }
}
