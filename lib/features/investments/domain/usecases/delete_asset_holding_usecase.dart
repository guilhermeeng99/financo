import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/repositories/asset_holding_repository.dart';

class DeleteAssetHoldingUseCase {
  const DeleteAssetHoldingUseCase(this._repository);

  final AssetHoldingRepository _repository;

  Future<Either<Failure, void>> call(String id) =>
      _repository.deleteAssetHolding(id);
}
