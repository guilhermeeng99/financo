// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_classes_dao.dart';

// ignore_for_file: type=lint
mixin _$AssetClassesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalAssetClassesTable get localAssetClasses =>
      attachedDatabase.localAssetClasses;
  AssetClassesDaoManager get managers => AssetClassesDaoManager(this);
}

class AssetClassesDaoManager {
  final _$AssetClassesDaoMixin _db;
  AssetClassesDaoManager(this._db);
  $$LocalAssetClassesTableTableManager get localAssetClasses =>
      $$LocalAssetClassesTableTableManager(
        _db.attachedDatabase,
        _db.localAssetClasses,
      );
}
