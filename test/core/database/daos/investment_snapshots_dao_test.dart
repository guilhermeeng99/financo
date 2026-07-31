import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/investment_snapshots_dao.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/investing_factories.dart';

void main() {
  late AppDatabase db;
  late InvestmentSnapshotsDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.investmentSnapshotsDao;
  });

  tearDown(() => db.close());

  group('upsertSnapshot + getSnapshots', () {
    test('round-trips a snapshot exactly', () async {
      final snapshot = SnapshotFactory.day();

      await dao.upsertSnapshot(snapshot);

      expect((await dao.getSnapshots(userId)).single, snapshot);
    });

    test('preserves the totals to the exact minor unit', () async {
      await dao.upsertSnapshot(
        SnapshotFactory.day(
          totalValue: const Money(123456789, Currency.brl),
          totalInvested: const Money(98765432, Currency.brl),
        ),
      );

      final read = (await dao.getSnapshots(userId)).single;
      expect(read.totalValue.minorUnits, 123456789);
      expect(read.totalInvested.minorUnits, 98765432);
      expect(read.unrealizedPL.minorUnits, 24691357);
    });

    test('carries a negative P/L through unchanged', () async {
      await dao.upsertSnapshot(
        SnapshotFactory.day(
          totalValue: const Money(70000, Currency.brl),
          totalInvested: const Money(80000, Currency.brl),
        ),
      );

      expect(
        (await dao.getSnapshots(userId)).single.unrealizedPL.minorUnits,
        -10000,
      );
    });

    test('re-recording the same day overwrites instead of appending', () async {
      // The row id is derived as `userId_dayKey`, so the history holds at most
      // one point per user per calendar day whatever time the recorder runs.
      await dao.upsertSnapshot(
        SnapshotFactory.day(
          date: DateTime(2024, 3, 5, 9),
          totalValue: const Money(100000, Currency.brl),
          totalInvested: const Money(80000, Currency.brl),
        ),
      );
      await dao.upsertSnapshot(
        SnapshotFactory.day(
          date: DateTime(2024, 3, 5, 21),
          totalValue: const Money(150000, Currency.brl),
          totalInvested: const Money(80000, Currency.brl),
        ),
      );

      final snapshots = await dao.getSnapshots(userId);
      expect(snapshots, hasLength(1));
      expect(snapshots.single.totalValue.minorUnits, 150000);
    });

    test('keeps distinct days apart', () async {
      await dao.upsertSnapshot(
        SnapshotFactory.day(date: DateTime(2024, 3, 5)),
      );
      await dao.upsertSnapshot(
        SnapshotFactory.day(date: DateTime(2024, 3, 6)),
      );

      expect(await dao.getSnapshots(userId), hasLength(2));
    });
  });

  group('getSnapshots', () {
    test('scopes to the user and orders oldest date first', () async {
      // The remote query carries no orderBy (it would need a composite index),
      // so the chart depends on this DAO sorting the history.
      await dao.insertAllSnapshots([
        SnapshotFactory.day(date: DateTime(2024, 3, 20)),
        SnapshotFactory.day(date: DateTime(2024, 3, 5)),
        SnapshotFactory.day(date: DateTime(2024, 3, 12)),
        SnapshotFactory.day(date: DateTime(2024, 3, 2), userId: 'user-2'),
      ]);

      final snapshots = await dao.getSnapshots(userId);

      expect(snapshots.map((s) => s.date).toList(), [
        DateTime(2024, 3, 5),
        DateTime(2024, 3, 12),
        DateTime(2024, 3, 20),
      ]);
    });

    test('returns an empty list when the user has none', () async {
      expect(await dao.getSnapshots(userId), isEmpty);
    });
  });

  group('insertAllSnapshots', () {
    test('writes the whole batch and is safe to replay', () async {
      final batch = [
        SnapshotFactory.day(date: DateTime(2024, 3, 5)),
        SnapshotFactory.day(date: DateTime(2024, 3, 6)),
      ];

      await dao.insertAllSnapshots(batch);
      await dao.insertAllSnapshots(batch);

      expect(await dao.getSnapshots(userId), hasLength(2));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllSnapshots([]);

      expect(await dao.getSnapshots(userId), isEmpty);
    });
  });

  test('deleteAllSnapshots clears every user', () async {
    await dao.insertAllSnapshots([
      SnapshotFactory.day(),
      SnapshotFactory.day(userId: 'user-2'),
    ]);

    await dao.deleteAllSnapshots();

    expect(await dao.getSnapshots(userId), isEmpty);
    expect(await dao.getSnapshots('user-2'), isEmpty);
  });
}
