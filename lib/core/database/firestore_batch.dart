import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore hard-caps a single [WriteBatch] at 500 operations; committing
/// more throws `INVALID_ARGUMENT`. Real user data sets (transactions to wipe,
/// rows to reassign) routinely exceed that, so any "operate over every
/// matching doc" path MUST chunk.
const firestoreBatchLimit = 500;

/// Applies [operation] to every entry in [docs], committing in chunks of at
/// most [batchLimit] writes so the Firestore 500-op batch cap is never hit.
///
/// [operation] stages one write (delete/update/set) for a single doc onto the
/// supplied [WriteBatch]; this helper owns batching and committing.
///
/// Example:
/// ```dart
/// await commitInBatches(
///   firestore: _firestore,
///   docs: snapshot.docs,
///   operation: (batch, doc) => batch.delete(doc.reference),
/// );
/// ```
///
/// [batchLimit] is overridable only so tests can force chunking without
/// seeding 500+ documents; production callers should leave the default.
Future<void> commitInBatches({
  required FirebaseFirestore firestore,
  required List<QueryDocumentSnapshot> docs,
  required void Function(WriteBatch batch, QueryDocumentSnapshot doc) operation,
  int batchLimit = firestoreBatchLimit,
}) async {
  for (var start = 0; start < docs.length; start += batchLimit) {
    final end = (start + batchLimit < docs.length)
        ? start + batchLimit
        : docs.length;
    final batch = firestore.batch();
    for (var i = start; i < end; i++) {
      operation(batch, docs[i]);
    }
    await batch.commit();
  }
}
