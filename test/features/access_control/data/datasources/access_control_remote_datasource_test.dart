import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/constants/access_control.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/access_control/data/datasources/access_control_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AccessControlRemoteDataSourceImpl datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = AccessControlRemoteDataSourceImpl(firestore: firestore);
  });

  group('isEmailAllowed', () {
    test('master email short-circuits to true without a Firestore read',
        () async {
      expect(await datasource.isEmailAllowed(kMasterEmail), isTrue);
      expect(
        await datasource.isEmailAllowed(kMasterEmail.toUpperCase()),
        isTrue,
      );
    });

    test('returns true when the lowercased doc exists', () async {
      await firestore
          .collection(kAllowedEmailsCollection)
          .doc('friend@example.com')
          .set({'addedAt': Timestamp.now()});

      expect(await datasource.isEmailAllowed('Friend@Example.com '), isTrue);
    });

    test('returns false when no doc exists', () async {
      expect(await datasource.isEmailAllowed('stranger@example.com'), isFalse);
    });

    test('permission-denied maps to false (fail-closed), not an exception',
        () async {
      // Regression: the auth gate fails OPEN on thrown errors, so a rules
      // misconfiguration that denies this read used to admit every
      // non-master account. permission-denied must read as "not allowed".
      final mockFirestore = MockFirebaseFirestore();
      final collection = MockMapCollectionReference();
      final doc = MockMapDocumentReference();
      when(() => mockFirestore.collection(kAllowedEmailsCollection))
          .thenReturn(collection);
      when(() => collection.doc('blocked@example.com')).thenReturn(doc);
      when(doc.get).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      final denied =
          AccessControlRemoteDataSourceImpl(firestore: mockFirestore);

      expect(await denied.isEmailAllowed('blocked@example.com'), isFalse);
    });

    test('other Firestore errors still surface as ServerException', () async {
      final mockFirestore = MockFirebaseFirestore();
      final collection = MockMapCollectionReference();
      final doc = MockMapDocumentReference();
      when(() => mockFirestore.collection(kAllowedEmailsCollection))
          .thenReturn(collection);
      when(() => collection.doc('friend@example.com')).thenReturn(doc);
      when(doc.get).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );
      final flaky = AccessControlRemoteDataSourceImpl(firestore: mockFirestore);

      expect(
        () => flaky.isEmailAllowed('friend@example.com'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('addAllowedEmail', () {
    test('lowercases the doc id and stores a trimmed note', () async {
      await datasource.addAllowedEmail(
        email: ' Friend@Example.COM ',
        note: '  college buddy  ',
      );

      final doc = await firestore
          .collection(kAllowedEmailsCollection)
          .doc('friend@example.com')
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['note'], 'college buddy');
      expect(doc.data()!['addedAt'], isNotNull);
    });

    test('omits the note field when blank', () async {
      await datasource.addAllowedEmail(email: 'friend@example.com', note: ' ');

      final doc = await firestore
          .collection(kAllowedEmailsCollection)
          .doc('friend@example.com')
          .get();
      expect(doc.data()!.containsKey('note'), isFalse);
    });
  });

  group('removeAllowedEmail', () {
    test('deletes the lowercased doc', () async {
      await firestore
          .collection(kAllowedEmailsCollection)
          .doc('friend@example.com')
          .set({'addedAt': Timestamp.now()});

      await datasource.removeAllowedEmail('Friend@Example.com');

      final doc = await firestore
          .collection(kAllowedEmailsCollection)
          .doc('friend@example.com')
          .get();
      expect(doc.exists, isFalse);
    });
  });

  group('listAllowedEmails', () {
    test('returns entries newest-first with doc id as email', () async {
      final collection = firestore.collection(kAllowedEmailsCollection);
      await collection.doc('older@example.com').set({
        'addedAt': Timestamp.fromDate(DateTime(2026)),
      });
      await collection.doc('newer@example.com').set({
        'addedAt': Timestamp.fromDate(DateTime(2026, 6)),
        'note': 'sister',
      });

      final entries = await datasource.listAllowedEmails();

      expect(entries.map((e) => e.email).toList(), [
        'newer@example.com',
        'older@example.com',
      ]);
      expect(entries.first.note, 'sister');
    });
  });
}
