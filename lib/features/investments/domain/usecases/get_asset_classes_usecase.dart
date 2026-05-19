import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';

class GetAssetClassesUseCase {
  const GetAssetClassesUseCase(this._repository);

  final AssetClassRepository _repository;

  Future<Either<Failure, List<AssetClassEntity>>> call({
    required String userId,
    bool forceRefresh = false,
  }) => _repository.getAssetClasses(
    userId: userId,
    forceRefresh: forceRefresh,
  );
}
