import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investing/data/models/snapshot_model.dart';

abstract class SnapshotRemoteDataSource {
  Future<List<SnapshotModel>> getSnapshots({required String userId});

  /// Writes the day's snapshot under its deterministic id (idempotent).
  Future<void> upsertSnapshot(SnapshotModel model);
}

class SnapshotRemoteDataSourceImpl implements SnapshotRemoteDataSource {
  SnapshotRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection =>
      _firestore.collection('investment_snapshots');

  @override
  Future<List<SnapshotModel>> getSnapshots({required String userId}) async {
    try {
      // No orderBy here: `where(userId) + orderBy(date)` would need a composite
      // Firestore index, and this runs inside fullSync at startup — a missing
      // index would abort the whole sync. The local DAO orders by date on read.
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map(SnapshotModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to fetch snapshots.');
    }
  }

  @override
  Future<void> upsertSnapshot(SnapshotModel model) async {
    try {
      await _collection.doc(model.docId).set(model.toJson());
    } on Exception {
      throw const ServerException('Failed to record snapshot.');
    }
  }
}
