import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/database/firestore_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../harness/mocks.dart';

void main() {
  late MockFirebaseFirestore firestore;
  late MockWriteBatch batch;

  setUp(() {
    firestore = MockFirebaseFirestore();
    batch = MockWriteBatch();
    when(firestore.batch).thenReturn(batch);
    when(batch.commit).thenAnswer((_) async {});
  });

  // Real QueryDocumentSnapshots from a fake — QueryDocumentSnapshot is sealed
  // and can't be mocked. The mock firestore/batch above let us count commits.
  Future<List<QueryDocumentSnapshot>> seedDocs(int count) async {
    final fake = FakeFirebaseFirestore();
    for (var i = 0; i < count; i++) {
      await fake.collection('c').add({'i': i});
    }
    final snap = await fake.collection('c').get();
    return snap.docs;
  }

  test('applies the operation to every doc and chunks commits', () async {
    final docs = await seedDocs(5);
    var applied = 0;

    await commitInBatches(
      firestore: firestore,
      docs: docs,
      operation: (_, _) => applied++,
      batchLimit: 2,
    );

    expect(applied, 5);
    // 5 docs / limit 2 -> chunks of 2, 2, 1 -> three commits.
    verify(batch.commit).called(3);
  });

  test('commits exactly once when count == batchLimit', () async {
    final docs = await seedDocs(2);

    await commitInBatches(
      firestore: firestore,
      docs: docs,
      operation: (_, _) {},
      batchLimit: 2,
    );

    verify(batch.commit).called(1);
  });

  test('does nothing for an empty doc list', () async {
    await commitInBatches(
      firestore: firestore,
      docs: const [],
      operation: (_, _) {},
    );

    verifyNever(firestore.batch);
    verifyNever(batch.commit);
  });
}
