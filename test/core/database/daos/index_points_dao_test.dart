import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/index_points_dao.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late IndexPointsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.indexPointsDao;
  });

  tearDown(() => db.close());

  group('saveSeries + allByIndexName', () {
    test('round-trips a series keyed by index name', () async {
      await dao.saveSeries(EconomicIndex.cdi.name, [
        IndexPoint(date: DateTime(2024, 3, 4), rate: 0.041),
        IndexPoint(date: DateTime(2024, 3, 5), rate: 0.042),
      ]);

      final series = await dao.allByIndexName();

      expect(series.keys, ['cdi']);
      expect(series['cdi'], [
        IndexPoint(date: DateTime(2024, 3, 4), rate: 0.041),
        IndexPoint(date: DateTime(2024, 3, 5), rate: 0.042),
      ]);
    });

    test('returns each point oldest first', () async {
      // Fixed income compounds forward from the purchase date, so an
      // out-of-order series would accrue against the wrong days.
      await dao.saveSeries(EconomicIndex.cdi.name, [
        IndexPoint(date: DateTime(2024, 3, 10), rate: 0.05),
        IndexPoint(date: DateTime(2024, 3, 2), rate: 0.01),
        IndexPoint(date: DateTime(2024, 3, 5), rate: 0.03),
      ]);

      expect(
        (await dao.allByIndexName())['cdi']!.map((p) => p.rate).toList(),
        [0.01, 0.03, 0.05],
      );
    });

    test('keeps distinct indices in separate buckets', () async {
      await dao.saveSeries(EconomicIndex.cdi.name, [
        IndexPoint(date: DateTime(2024, 3, 5), rate: 0.041),
      ]);
      await dao.saveSeries(EconomicIndex.ipca.name, [
        IndexPoint(date: DateTime(2024, 3, 5), rate: 0.42),
      ]);

      final series = await dao.allByIndexName();

      expect(series.keys.toSet(), {'cdi', 'ipca'});
      expect(series['cdi']!.single.rate, 0.041);
      expect(series['ipca']!.single.rate, 0.42);
    });

    test('re-saving a date replaces the point, not duplicates it', () async {
      await dao.saveSeries(EconomicIndex.cdi.name, [
        IndexPoint(date: DateTime(2024, 3, 5), rate: 0.041),
      ]);
      await dao.saveSeries(EconomicIndex.cdi.name, [
        IndexPoint(date: DateTime(2024, 3, 5), rate: 0.045),
      ]);

      final points = (await dao.allByIndexName())['cdi']!;
      expect(points, hasLength(1));
      expect(points.single.rate, 0.045);
    });

    test('an empty series is a no-op', () async {
      await dao.saveSeries(EconomicIndex.cdi.name, []);

      expect(await dao.allByIndexName(), isEmpty);
    });

    test('returns an empty map when nothing is cached', () async {
      expect(await dao.allByIndexName(), isEmpty);
    });
  });

  test('deleteAllIndexPoints clears every series', () async {
    await dao.saveSeries(EconomicIndex.cdi.name, [
      IndexPoint(date: DateTime(2024, 3, 5), rate: 0.041),
    ]);
    await dao.saveSeries(EconomicIndex.selic.name, [
      IndexPoint(date: DateTime(2024, 3, 5), rate: 0.043),
    ]);

    await dao.deleteAllIndexPoints();

    expect(await dao.allByIndexName(), isEmpty);
  });
}
