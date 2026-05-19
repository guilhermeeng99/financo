import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';

abstract class AssetClassRepository {
  Future<Either<Failure, List<AssetClassEntity>>> getAssetClasses({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, AssetClassEntity>> createAssetClass(
    AssetClassEntity assetClass,
  );

  Future<Either<Failure, AssetClassEntity>> updateAssetClass(
    AssetClassEntity assetClass,
  );

  Future<Either<Failure, void>> deleteAssetClass(String id);
}
