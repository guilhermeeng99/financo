import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/features/access_control/data/models/allowed_email_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/allowed_email_factory.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  Future<DocumentSnapshot> snapshotFor(
    String email,
    Map<String, dynamic> data,
  ) async {
    final doc = firestore.collection('allowed_emails').doc(email);
    await doc.set(data);
    return doc.get();
  }

  group('fromFirestore', () {
    test('reads the email from the doc id and converts the timestamp',
        () async {
      final snapshot = await snapshotFor('friend@example.com', {
        'addedAt': Timestamp.fromDate(DateTime(2026, 5, 10)),
        'note': 'college buddy',
      });

      final model = AllowedEmailModel.fromFirestore(snapshot);

      expect(model.email, 'friend@example.com');
      expect(model.addedAt, DateTime(2026, 5, 10));
      expect(model.note, 'college buddy');
    });

    test('tolerates a missing note', () async {
      final snapshot = await snapshotFor('friend@example.com', {
        'addedAt': Timestamp.fromDate(DateTime(2026)),
      });

      final model = AllowedEmailModel.fromFirestore(snapshot);

      expect(model.note, isNull);
    });

    test('falls back to now when addedAt is absent or malformed', () async {
      final before = DateTime.now();
      final snapshot = await snapshotFor('friend@example.com', {
        'addedAt': 'not-a-timestamp',
      });

      final model = AllowedEmailModel.fromFirestore(snapshot);

      final after = DateTime.now();
      expect(model.addedAt.isBefore(before), isFalse);
      expect(model.addedAt.isAfter(after), isFalse);
    });
  });

  group('toJson', () {
    test('serialises addedAt as a Timestamp and includes the note', () {
      final model = AllowedEmailModel.fromEntity(
        AllowedEmailFactory.entry(note: 'sister'),
      );

      final json = model.toJson();

      expect(json['addedAt'], Timestamp.fromDate(model.addedAt));
      expect(json['note'], 'sister');
    });

    test('omits the note key entirely when null', () {
      final model = AllowedEmailModel.fromEntity(AllowedEmailFactory.entry());

      final json = model.toJson();

      // `note: null` would clobber an existing note on merge writes —
      // absence is the contract.
      expect(json.containsKey('note'), isFalse);
    });
  });

  group('fromEntity', () {
    test('copies every field from the domain entity', () {
      final entity = AllowedEmailFactory.entry(
        email: 'a@b.com',
        addedAt: DateTime(2026, 2),
        note: 'note',
      );

      final model = AllowedEmailModel.fromEntity(entity);

      expect(model.email, entity.email);
      expect(model.addedAt, entity.addedAt);
      expect(model.note, entity.note);
    });
  });
}
