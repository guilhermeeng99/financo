// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_snapshots_dao.dart';

// ignore_for_file: type=lint
mixin _$InvestmentSnapshotsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalInvestmentSnapshotsTable get localInvestmentSnapshots =>
      attachedDatabase.localInvestmentSnapshots;
  InvestmentSnapshotsDaoManager get managers =>
      InvestmentSnapshotsDaoManager(this);
}

class InvestmentSnapshotsDaoManager {
  final _$InvestmentSnapshotsDaoMixin _db;
  InvestmentSnapshotsDaoManager(this._db);
  $$LocalInvestmentSnapshotsTableTableManager get localInvestmentSnapshots =>
      $$LocalInvestmentSnapshotsTableTableManager(
        _db.attachedDatabase,
        _db.localInvestmentSnapshots,
      );
}
