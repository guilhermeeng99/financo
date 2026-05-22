import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/asset_holdings_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
import 'package:financo/features/investments/data/datasources/asset_holding_remote_datasource.dart';
import 'package:financo/features/investments/data/models/asset_holding_model.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';

class AssetHoldingRepositoryImpl implements AssetHoldingRepository {
  AssetHoldingRepositoryImpl({
    required AssetHoldingRemoteDataSource remoteDataSource,
    required AssetHoldingsDao assetHoldingsDao,
    required String Function() resolveUserId,
  }) : _remote = remoteDataSource,
       _dao = assetHoldingsDao,
       _resolveUserId = resolveUserId;

  final AssetHoldingRemoteDataSource _remote;
  final AssetHoldingsDao _dao;

  /// Cascade-delete-by-account is called from the accounts cubit which
  /// does not pass the userId, so the repository resolves it lazily
  /// through this callback (typically wired to `AuthBloc.currentUserId`).
  final String Function() _resolveUserId;

  @override
  Future<Either<Failure, List<AssetHoldingEntity>>> getAssetHoldings({
    required String userId,
    bool forceRefresh = false,
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getAssetHoldings(userId: userId);
        await _dao.deleteAllAssetHoldings();
        if (remote.isNotEmpty) {
          await _dao.insertAllAssetHoldings(remote);
        }
      }
      return _dao.getAssetHoldings(userId);
    });
  }

  @override
  Future<Either<Failure, AssetHoldingEntity>> createAssetHolding(
    AssetHoldingEntity holding,
  ) {
    return guardServer(() async {
      final result = await _remote.createAssetHolding(
        AssetHoldingModel.fromEntity(holding),
      );
      await _dao.upsertAssetHolding(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, AssetHoldingEntity>> updateAssetHolding(
    AssetHoldingEntity holding,
  ) {
    return guardServer(() async {
      final result = await _remote.updateAssetHolding(
        AssetHoldingModel.fromEntity(holding),
      );
      await _dao.upsertAssetHolding(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteAssetHolding(String id) {
    return guardServerVoid(() async {
      await _remote.deleteAssetHolding(id);
      await _dao.deleteAssetHolding(id);
    });
  }

  @override
  Future<Either<Failure, void>> deleteHoldingsForAccount(String accountId) {
    return guardServerVoid(() async {
      final userId = _resolveUserId();
      if (userId.isEmpty) return;
      await _remote.deleteHoldingsForAccount(
        userId: userId,
        accountId: accountId,
      );
      await _dao.deleteHoldingsForAccount(accountId);
    });
  }

  @override
  Future<Either<Failure, void>> deleteHoldingsForClass(String classId) {
    return guardServerVoid(() async {
      final userId = _resolveUserId();
      if (userId.isEmpty) return;
      await _remote.deleteHoldingsForClass(userId: userId, classId: classId);
      await _dao.deleteHoldingsForClass(classId);
    });
  }
}
