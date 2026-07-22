import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';

/// Reads/writes investing assets. Firestore-primary with a Drift cache. See
/// `docs/specs/investing_assets.md`.
abstract class AssetRepository {
  Future<Either<Failure, List<Asset>>> getAssets({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Asset>> createAsset(Asset a);

  Future<Either<Failure, Asset>> updateAsset(Asset a);

  Future<Either<Failure, void>> deleteAsset(String id);
}
