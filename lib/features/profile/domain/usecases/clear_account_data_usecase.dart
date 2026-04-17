import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/errors/failures.dart';

class ClearAccountDataUseCase {
  ClearAccountDataUseCase({
    required FirebaseFirestore firestore,
    required AppDatabase database,
  }) : _firestore = firestore,
       _database = database;

  final FirebaseFirestore _firestore;
  final AppDatabase _database;

  Future<Either<Failure, void>> call(String userId) async {
    try {
      await _deleteCollectionDocs('transactions', userId);
      await _deleteCollectionDocs('chat_messages', userId);
      await _deleteCollectionDocs('categories', userId);
      await _deleteCollectionDocs('accounts', userId);
      await _database.clearAllTables();
      return const Right(null);
    } on Exception {
      return const Left(ServerFailure('Failed to clear account data.'));
    }
  }

  Future<void> _deleteCollectionDocs(String collection, String userId) async {
    final snapshot = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
