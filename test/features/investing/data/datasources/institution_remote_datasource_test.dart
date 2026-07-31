import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investing/data/datasources/institution_remote_datasource.dart';
import 'package:financo/features/investing/data/models/institution_model.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

// Tests go through the public `InstitutionRemoteDataSource` interface only —
// the impl was moved onto `FirestoreCrudDataSource` and the interface is what
// must not change.
void main() {
  late FakeFirebaseFirestore firestore;
  late InstitutionRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = InstitutionRemoteDataSourceImpl(firestore: firestore);
  });

  group('createInstitution + getInstitutions', () {
    test('persists the model and returns it with the generated id', () async {
      final model = InstitutionModel.fromEntity(InstitutionFactory.avenue());

      final created = await datasource.createInstitution(model);

      expect(created.id, isNotEmpty);
      expect(created.id, isNot(model.id));
      expect(created.name, 'Avenue');
      expect(created.kind, InstitutionKind.internationalBroker);
      expect(created.currency, model.currency);
      expect(created.userId, userId);
    });

    test('writes into the institutions collection', () async {
      await datasource.createInstitution(
        InstitutionModel.fromEntity(InstitutionFactory.nubank()),
      );

      final docs = await firestore.collection('institutions').get();
      expect(docs.docs, hasLength(1));
    });

    test("returns only the given user's institutions", () async {
      await datasource.createInstitution(
        InstitutionModel.fromEntity(InstitutionFactory.nubank()),
      );
      await datasource.createInstitution(
        InstitutionModel.fromEntity(
          InstitutionFactory.avenue(userId: 'user-2'),
        ),
      );

      final institutions = await datasource.getInstitutions(userId: userId);

      expect(institutions, hasLength(1));
      expect(institutions.single.name, 'Nubank');
    });

    test('returns an empty list when the user has none', () async {
      expect(await datasource.getInstitutions(userId: userId), isEmpty);
    });
  });

  group('updateInstitution', () {
    test('overwrites stored fields and returns the fresh doc', () async {
      final created = await datasource.createInstitution(
        InstitutionModel.fromEntity(InstitutionFactory.nubank()),
      );

      final updated = await datasource.updateInstitution(
        InstitutionModel.fromEntity(
          InstitutionFactory.nubank(id: created.id, name: 'Nu Invest'),
        ),
      );

      expect(updated.id, created.id);
      expect(updated.name, 'Nu Invest');
      final refetched = await datasource.getInstitutions(userId: userId);
      expect(refetched.single.name, 'Nu Invest');
    });
  });

  group('deleteInstitution', () {
    test('removes the doc, leaving siblings intact', () async {
      final keep = await datasource.createInstitution(
        InstitutionModel.fromEntity(InstitutionFactory.nubank()),
      );
      final drop = await datasource.createInstitution(
        InstitutionModel.fromEntity(InstitutionFactory.avenue()),
      );

      await datasource.deleteInstitution(drop.id);

      final remaining = await datasource.getInstitutions(userId: userId);
      expect(remaining.map((i) => i.id).toList(), [keep.id]);
    });
  });

  group('failures', () {
    // fake_cloud_firestore cannot throw transport errors, so the raw client is
    // mocked. The message wording is asserted because it is what the shared
    // base derives from `entityLabel` — a wrong label would surface the wrong
    // failure text to the user.
    late MockFirebaseFirestore mockFirestore;
    late MockMapCollectionReference collection;
    late InstitutionRemoteDataSourceImpl flaky;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      collection = MockMapCollectionReference();
      when(
        () => mockFirestore.collection('institutions'),
      ).thenReturn(collection);
      flaky = InstitutionRemoteDataSourceImpl(firestore: mockFirestore);
    });

    test('create surfaces a ServerException', () async {
      when(() => collection.add(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        () => flaky.createInstitution(
          InstitutionModel.fromEntity(InstitutionFactory.nubank()),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to create institution.',
          ),
        ),
      );
    });

    test('fetch surfaces a ServerException', () async {
      when(() => collection.where('userId', isEqualTo: userId)).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      expect(
        () => flaky.getInstitutions(userId: userId),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to fetch institutions.',
          ),
        ),
      );
    });

    test('delete surfaces a ServerException', () async {
      final doc = MockMapDocumentReference();
      when(() => collection.doc('inst-1')).thenReturn(doc);
      when(doc.delete).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        () => flaky.deleteInstitution('inst-1'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to delete institution.',
          ),
        ),
      );
    });
  });
}
