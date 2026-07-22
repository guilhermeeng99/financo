import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';

class GetAssetsUseCase {
  const GetAssetsUseCase(this._repo);

  final AssetRepository _repo;

  Future<Either<Failure, List<Asset>>> call({
    required String userId,
    bool forceRefresh = false,
  }) {
    return _repo.getAssets(userId: userId, forceRefresh: forceRefresh);
  }
}
