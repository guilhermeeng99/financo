import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';

class DeleteAssetTransactionUseCase {
  const DeleteAssetTransactionUseCase(this._repo);

  final AssetTransactionRepository _repo;

  Future<Either<Failure, void>> call(String id) {
    return _repo.deleteTransaction(id);
  }
}
