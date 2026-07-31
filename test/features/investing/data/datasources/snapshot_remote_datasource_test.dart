import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/datasources/snapshot_remote_datasource.dart';
import 'package:financo/features/investing/data/models/snapshot_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SnapshotRemoteDataSourceImpl datasource;

  const userId = 'user-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = SnapshotRemoteDataSourceImpl(firestore: firestore);
  });

  group('upsertSnapshot', () {
    test('writes under the deterministic per-day doc id', () async {
      await datasource.upsertSnapshot(
        SnapshotModel.fromEntity(
          SnapshotFactory.day(date: DateTime(2024, 3, 5)),
        ),
      );

      final doc = await firestore
          .collection('investment_snapshots')
          .doc('user-1_2024-03-05')
          .get();
      expect(doc.exists, isTrue);
    });

    test('re-recording the same day overwrites instead of appending', () async {
      // The idempotency contract from docs/specs/valuation.md: the history must
      // hold at most one point per user per calendar day, whatever time of day
      // the recorder runs.
      await datasource.upsertSnapshot(
        SnapshotModel.fromEntity(
          SnapshotFactory.day(
            date: DateTime(2024, 3, 5, 9),
            totalValue: const Money(100000, Currency.brl),
            totalInvested: const Money(80000, Currency.brl),
          ),
        ),
      );
      await datasource.upsertSnapshot(
        SnapshotModel.fromEntity(
          SnapshotFactory.day(
            date: DateTime(2024, 3, 5, 21),
            totalValue: const Money(150000, Currency.brl),
            totalInvested: const Money(80000, Currency.brl),
          ),
        ),
      );

      final snapshots = await datasource.getSnapshots(userId: userId);
      expect(snapshots, hasLength(1));
      expect(snapshots.single.totalValue.minorUnits, 150000);
      expect(snapshots.single.unrealizedPL.minorUnits, 70000);
    });

    test('money survives the round-trip to the exact minor unit', () async {
      await datasource.upsertSnapshot(
        SnapshotModel.fromEntity(
          SnapshotFactory.day(
            totalValue: const Money(123456789, Currency.brl),
            totalInvested: const Money(98765432, Currency.brl),
          ),
        ),
      );

      final snapshot = (await datasource.getSnapshots(userId: userId)).single;

      expect(snapshot.totalValue.minorUnits, 123456789);
      expect(snapshot.totalInvested.minorUnits, 98765432);
      expect(snapshot.unrealizedPL.minorUnits, 24691357);
    });
  });

  group('getSnapshots', () {
    test("returns only the given user's snapshots", () async {
      await datasource.upsertSnapshot(
        SnapshotModel.fromEntity(SnapshotFactory.day()),
      );
      await datasource.upsertSnapshot(
        SnapshotModel.fromEntity(SnapshotFactory.day(userId: 'user-2')),
      );

      final snapshots = await datasource.getSnapshots(userId: userId);

      expect(snapshots, hasLength(1));
      expect(snapshots.single.userId, userId);
    });

    test('returns every day the user has recorded', () async {
      for (final day in [1, 2, 3]) {
        await datasource.upsertSnapshot(
          SnapshotModel.fromEntity(
            SnapshotFactory.day(date: DateTime(2024, 3, day)),
          ),
        );
      }

      // Deliberately unordered — the query carries no orderBy (that would need
      // a composite index), so the local DAO sorts on read.
      expect(await datasource.getSnapshots(userId: userId), hasLength(3));
    });

    test('returns an empty list when the user has none', () async {
      expect(await datasource.getSnapshots(userId: userId), isEmpty);
    });
  });

  group('failures', () {
    late MockFirebaseFirestore mockFirestore;
    late MockMapCollectionReference collection;
    late SnapshotRemoteDataSourceImpl flaky;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      collection = MockMapCollectionReference();
      when(
        () => mockFirestore.collection('investment_snapshots'),
      ).thenReturn(collection);
      flaky = SnapshotRemoteDataSourceImpl(firestore: mockFirestore);
    });

    test('fetch surfaces a ServerException', () async {
      when(() => collection.where('userId', isEqualTo: userId)).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      expect(
        () => flaky.getSnapshots(userId: userId),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to fetch snapshots.',
          ),
        ),
      );
    });

    test('upsert surfaces a ServerException', () async {
      final doc = MockMapDocumentReference();
      when(() => collection.doc(any())).thenReturn(doc);
      when(() => doc.set(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        () => flaky.upsertSnapshot(
          SnapshotModel.fromEntity(SnapshotFactory.day()),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to record snapshot.',
          ),
        ),
      );
    });
  });
}
