import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';

class GetAssetHoldingsUseCase {
  const GetAssetHoldingsUseCase(this._repository);

  final AssetHoldingRepository _repository;

  Future<Either<Failure, List<AssetHoldingEntity>>> call({
    required String userId,
    bool forceRefresh = false,
  }) => _repository.getAssetHoldings(
    userId: userId,
    forceRefresh: forceRefresh,
  );
}
