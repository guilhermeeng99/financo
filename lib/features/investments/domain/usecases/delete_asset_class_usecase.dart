import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/domain/repositories/asset_class_repository.dart';

/// Deletes an allocation class. Refuses to delete while subclasses still point
/// at it — the user must remove or re-parent them first. (The V2 investing
/// module derives allocation from `Asset.metadata['allocationClassId']`, so
/// there are no separate holding records to block on anymore.)
class DeleteAssetClassUseCase {
  const DeleteAssetClassUseCase({
    required AssetClassRepository assetClassRepository,
  }) : _classRepository = assetClassRepository;

  final AssetClassRepository _classRepository;

  Future<Either<Failure, void>> call({
    required String id,
    required String userId,
  }) async {
    final classesResult = await _classRepository.getAssetClasses(
      userId: userId,
    );
    final subclassFailure = classesResult.fold<Failure?>(
      (failure) => failure,
      (classes) {
        final subs = classes.where((c) => c.parentId == id).toList();
        if (subs.isEmpty) return null;
        return AssetClassHasSubclassesFailure(subs.length);
      },
    );
    if (subclassFailure != null) return Left(subclassFailure);

    return _classRepository.deleteAssetClass(id);
  }
}
