import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/investment_snapshots_table.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/enum_parse.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';

part 'investment_snapshots_dao.g.dart';

@DriftAccessor(tables: [LocalInvestmentSnapshots])
class InvestmentSnapshotsDao extends DatabaseAccessor<AppDatabase>
    with _$InvestmentSnapshotsDaoMixin {
  InvestmentSnapshotsDao(super.attachedDatabase);

  Future<void> insertAllSnapshots(List<Snapshot> snapshots) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localInvestmentSnapshots,
        snapshots.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertSnapshot(Snapshot snapshot) => into(
    localInvestmentSnapshots,
  ).insertOnConflictUpdate(_toCompanion(snapshot));

  Future<List<Snapshot>> getSnapshots(String userId) async {
    final rows =
        await (select(localInvestmentSnapshots)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.asc(t.date)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> deleteAllSnapshots() => delete(localInvestmentSnapshots).go();

  LocalInvestmentSnapshotsCompanion _toCompanion(Snapshot e) =>
      LocalInvestmentSnapshotsCompanion.insert(
        id: '${e.userId}_${e.dayKey}',
        userId: e.userId,
        date: e.date,
        totalValueMinor: e.totalValue.minorUnits,
        totalInvestedMinor: e.totalInvested.minorUnits,
        unrealizedPlMinor: e.unrealizedPL.minorUnits,
        currency: e.totalValue.currency.name,
      );

  Snapshot _toEntity(LocalInvestmentSnapshot row) {
    final currency = enumByName(Currency.values, row.currency, Currency.brl);
    return Snapshot(
      userId: row.userId,
      date: row.date,
      totalValue: Money(row.totalValueMinor, currency),
      totalInvested: Money(row.totalInvestedMinor, currency),
      unrealizedPL: Money(row.unrealizedPlMinor, currency),
    );
  }
}
