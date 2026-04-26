// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bills_dao.dart';

// ignore_for_file: type=lint
mixin _$BillsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalBillsTable get localBills => attachedDatabase.localBills;
  BillsDaoManager get managers => BillsDaoManager(this);
}

class BillsDaoManager {
  final _$BillsDaoMixin _db;
  BillsDaoManager(this._db);
  $$LocalBillsTableTableManager get localBills =>
      $$LocalBillsTableTableManager(_db.attachedDatabase, _db.localBills);
}
