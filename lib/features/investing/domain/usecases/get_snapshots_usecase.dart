import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';
import 'package:financo/features/investing/domain/repositories/snapshot_repository.dart';

class GetSnapshotsUseCase {
  const GetSnapshotsUseCase(this._repo);

  final SnapshotRepository _repo;

  Future<Either<Failure, List<Snapshot>>> call({
    required String userId,
    bool forceRefresh = false,
  }) {
    return _repo.getSnapshots(userId: userId, forceRefresh: forceRefresh);
  }
}
