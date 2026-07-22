import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/investment_snapshots_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
import 'package:financo/features/investing/data/datasources/snapshot_remote_datasource.dart';
import 'package:financo/features/investing/data/models/snapshot_model.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';
import 'package:financo/features/investing/domain/repositories/snapshot_repository.dart';

class SnapshotRepositoryImpl implements SnapshotRepository {
  SnapshotRepositoryImpl({
    required SnapshotRemoteDataSource remoteDataSource,
    required InvestmentSnapshotsDao snapshotsDao,
  }) : _remote = remoteDataSource,
       _dao = snapshotsDao;

  final SnapshotRemoteDataSource _remote;
  final InvestmentSnapshotsDao _dao;

  @override
  Future<Either<Failure, List<Snapshot>>> getSnapshots({
    required String userId,
    bool forceRefresh = false,
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getSnapshots(userId: userId);
        await _dao.deleteAllSnapshots();
        if (remote.isNotEmpty) {
          await _dao.insertAllSnapshots(remote);
        }
      }
      return _dao.getSnapshots(userId);
    });
  }

  @override
  Future<Either<Failure, Unit>> recordSnapshot(Snapshot snapshot) {
    return guardServerVoid(() async {
      final model = SnapshotModel.fromEntity(snapshot);
      await _remote.upsertSnapshot(model);
      await _dao.upsertSnapshot(snapshot);
    }).then((either) => either.map((_) => unit));
  }
}
