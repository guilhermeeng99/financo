import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';

/// Persists and reads the net-worth history. Snapshots are mirrored to
/// Firestore (`investment_snapshots/{userId_dayKey}`) and cached locally.
abstract class SnapshotRepository {
  /// The user's snapshots, oldest first.
  Future<Either<Failure, List<Snapshot>>> getSnapshots({
    required String userId,
    bool forceRefresh = false,
  });

  /// Records (or overwrites) the snapshot for its day — idempotent per day.
  Future<Either<Failure, Unit>> recordSnapshot(Snapshot snapshot);
}
