// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index_points_dao.dart';

// ignore_for_file: type=lint
mixin _$IndexPointsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalIndexPointsTable get localIndexPoints =>
      attachedDatabase.localIndexPoints;
  IndexPointsDaoManager get managers => IndexPointsDaoManager(this);
}

class IndexPointsDaoManager {
  final _$IndexPointsDaoMixin _db;
  IndexPointsDaoManager(this._db);
  $$LocalIndexPointsTableTableManager get localIndexPoints =>
      $$LocalIndexPointsTableTableManager(
        _db.attachedDatabase,
        _db.localIndexPoints,
      );
}
