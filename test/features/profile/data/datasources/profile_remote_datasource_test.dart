import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/database/user_scoped_collections.dart';
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
    // Driven off the canonical list rather than a hand-written enumeration:
    // a collection added to `kUserScopedCollections` gets coverage for free,
    // and one that is *missing* from it is caught by
    // `test/core/database/user_scoped_collections_test.dart`, which derives
    // its expectation from firestore.rules. Two earlier regressions — budgets,
    // then asset_classes/asset_holdings — got through precisely because both
    // the wipe list and its test were edited by hand, together.
    test('deletes documents across every user-scoped collection', () async {
      for (final collection in kUserScopedCollections) {
        await seed(collection, userId, count: 2);
      }

      await datasource.wipeUserData(userId);

      for (final collection in kUserScopedCollections) {
        expect(
          await docsFor(collection, userId),
          0,
          reason: '$collection survived the wipe',
        );
      }
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
