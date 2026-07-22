// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_assets_dao.dart';

// ignore_for_file: type=lint
mixin _$InvestmentAssetsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalInvestmentAssetsTable get localInvestmentAssets =>
      attachedDatabase.localInvestmentAssets;
  InvestmentAssetsDaoManager get managers => InvestmentAssetsDaoManager(this);
}

class InvestmentAssetsDaoManager {
  final _$InvestmentAssetsDaoMixin _db;
  InvestmentAssetsDaoManager(this._db);
  $$LocalInvestmentAssetsTableTableManager get localInvestmentAssets =>
      $$LocalInvestmentAssetsTableTableManager(
        _db.attachedDatabase,
        _db.localInvestmentAssets,
      );
}
