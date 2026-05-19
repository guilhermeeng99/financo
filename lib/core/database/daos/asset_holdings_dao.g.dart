// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_holdings_dao.dart';

// ignore_for_file: type=lint
mixin _$AssetHoldingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalAssetHoldingsTable get localAssetHoldings =>
      attachedDatabase.localAssetHoldings;
  AssetHoldingsDaoManager get managers => AssetHoldingsDaoManager(this);
}

class AssetHoldingsDaoManager {
  final _$AssetHoldingsDaoMixin _db;
  AssetHoldingsDaoManager(this._db);
  $$LocalAssetHoldingsTableTableManager get localAssetHoldings =>
      $$LocalAssetHoldingsTableTableManager(
        _db.attachedDatabase,
        _db.localAssetHoldings,
      );
}
