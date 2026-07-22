import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/index_points_table.dart';
import 'package:financo/features/investing/domain/entities/index_point.dart';

part 'index_points_dao.g.dart';

@DriftAccessor(tables: [LocalIndexPoints])
class IndexPointsDao extends DatabaseAccessor<AppDatabase>
    with _$IndexPointsDaoMixin {
  IndexPointsDao(super.attachedDatabase);

  /// Every persisted series, keyed by the stored index name, oldest point
  /// first.
  Future<Map<String, List<IndexPoint>>> allByIndexName() async {
    final rows = await (select(
      localIndexPoints,
    )..orderBy([(t) => OrderingTerm(expression: t.date)])).get();
    final byName = <String, List<IndexPoint>>{};
    for (final row in rows) {
      (byName[row.indexName] ??= []).add(
        IndexPoint(date: row.date, rate: row.rate),
      );
    }
    return byName;
  }

  Future<void> saveSeries(String indexName, List<IndexPoint> points) async {
    if (points.isEmpty) return;
    await batch((b) {
      for (final point in points) {
        b.insert(
          localIndexPoints,
          LocalIndexPointsCompanion.insert(
            indexName: indexName,
            date: point.date,
            rate: point.rate,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> deleteAllIndexPoints() => delete(localIndexPoints).go();
}
