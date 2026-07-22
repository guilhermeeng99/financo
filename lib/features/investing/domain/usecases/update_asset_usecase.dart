import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';

/// Updates an asset with the same validations as create, excluding the asset
/// being edited from the uniqueness check.
class UpdateAssetUseCase {
  const UpdateAssetUseCase(this._repo);

  final AssetRepository _repo;

  Future<Either<Failure, Asset>> call(Asset asset) async {
    final ticker = asset.ticker.trim().toUpperCase();
    if (ticker.isEmpty) return const Left(EmptyNameFailure());
    if (asset.institutionId == null || asset.institutionId!.isEmpty) {
      return const Left(AssetInstitutionRequiredFailure());
    }

    final listResult = await _repo.getAssets(userId: asset.userId);
    final failure = listResult.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) return Left(failure);

    final isDuplicate = listResult
        .getOrElse(() => const [])
        .any(
          (e) =>
              e.id != asset.id &&
              e.market == asset.market &&
              e.ticker.trim().toUpperCase() == ticker,
        );
    if (isDuplicate) return Left(DuplicateAssetFailure(ticker));

    return _repo.updateAsset(asset.copyWith(ticker: ticker));
  }
}
