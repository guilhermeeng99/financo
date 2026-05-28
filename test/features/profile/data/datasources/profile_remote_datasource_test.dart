import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProfileRemoteDataSourceImpl datasource;

  const userId = 'user-1';
  const otherUserId = 'user-2';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = ProfileRemoteDataSourceImpl(firestore: firestore);
  });

  Future<void> seed(String collection, String ownerId, {int count = 1}) async {
    for (var i = 0; i < count; i++) {
      await firestore.collection(collection).add({'userId': ownerId});
    }
  }

  Future<int> docsFor(String collection, String ownerId) async {
    final snap = await firestore
        .collection(collection)
        .where('userId', isEqualTo: ownerId)
        .get();
    return snap.docs.length;
  }

  group('wipeUserData', () {
    test('deletes documents across every user-scoped collection', () async {
      // Regression: budgets used to be missing from the wipe list, leaving
      // orphan budget rows that pointed at deleted categoryIds.
      await seed('bills', userId, count: 2);
      await seed('transactions', userId);
      await seed('chat_messages', userId);
      await seed('categories', userId);
      await seed('accounts', userId);
      await seed('budgets', userId, count: 3);
      // Regression: asset_classes/asset_holdings were missing from the wipe
      // list, leaving orphaned investment data live after "clear account".
      await seed('asset_classes', userId, count: 2);
      await seed('asset_holdings', userId, count: 4);

      await datasource.wipeUserData(userId);

      expect(await docsFor('bills', userId), 0);
      expect(await docsFor('transactions', userId), 0);
      expect(await docsFor('chat_messages', userId), 0);
      expect(await docsFor('categories', userId), 0);
      expect(await docsFor('accounts', userId), 0);
      expect(await docsFor('budgets', userId), 0);
      expect(await docsFor('asset_classes', userId), 0);
      expect(await docsFor('asset_holdings', userId), 0);
    });

    test('does not touch documents owned by other users', () async {
      await seed('bills', userId);
      await seed('bills', otherUserId, count: 3);
      await seed('budgets', userId);
      await seed('budgets', otherUserId, count: 2);

      await datasource.wipeUserData(userId);

      expect(await docsFor('bills', userId), 0);
      expect(await docsFor('bills', otherUserId), 3);
      expect(await docsFor('budgets', userId), 0);
      expect(await docsFor('budgets', otherUserId), 2);
    });
  });

  group('getProfile', () {
    test('returns model for an existing user document', () async {
      await firestore.collection('users').doc(userId).set({
        'name': 'Foo',
        'email': 'foo@example.com',
        'createdAt': Timestamp.fromDate(DateTime(2024)),
      });

      final model = await datasource.getProfile(userId);

      expect(model.id, userId);
      expect(model.name, 'Foo');
      expect(model.email, 'foo@example.com');
    });
  });
}
