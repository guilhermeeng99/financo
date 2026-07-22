import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/investment_assets_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
import 'package:financo/features/investing/data/datasources/asset_remote_datasource.dart';
import 'package:financo/features/investing/data/models/asset_model.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';

class AssetRepositoryImpl implements AssetRepository {
  AssetRepositoryImpl({
    required AssetRemoteDataSource remoteDataSource,
    required InvestmentAssetsDao assetsDao,
  }) : _remote = remoteDataSource,
       _dao = assetsDao;

  final AssetRemoteDataSource _remote;
  final InvestmentAssetsDao _dao;

  @override
  Future<Either<Failure, List<Asset>>> getAssets({
    required String userId,
    bool forceRefresh = false,
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getAssets(userId: userId);
        await _dao.deleteAllAssets();
        if (remote.isNotEmpty) {
          await _dao.insertAllAssets(remote);
        }
      }
      return _dao.getAssets(userId);
    });
  }

  @override
  Future<Either<Failure, Asset>> createAsset(Asset a) {
    return guardServer(() async {
      final result = await _remote.createAsset(AssetModel.fromEntity(a));
      await _dao.upsertAsset(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, Asset>> updateAsset(Asset a) {
    return guardServer(() async {
      final result = await _remote.updateAsset(AssetModel.fromEntity(a));
      await _dao.upsertAsset(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteAsset(String id) {
    return guardServerVoid(() async {
      await _remote.deleteAsset(id);
      await _dao.deleteAsset(id);
    });
  }
}
