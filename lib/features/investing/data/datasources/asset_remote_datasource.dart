import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/database/firestore_crud_data_source.dart';
import 'package:financo/features/investing/data/models/asset_model.dart';

abstract class AssetRemoteDataSource {
  Future<List<AssetModel>> getAssets({required String userId});
  Future<AssetModel> createAsset(AssetModel model);
  Future<AssetModel> updateAsset(AssetModel model);
  Future<void> deleteAsset(String id);
}

class AssetRemoteDataSourceImpl extends FirestoreCrudDataSource<AssetModel>
    implements AssetRemoteDataSource {
  AssetRemoteDataSourceImpl({required super.firestore});

  @override
  String get collectionName => 'investment_assets';

  @override
  String get entityLabel => 'asset';

  @override
  AssetModel fromFirestore(DocumentSnapshot<Object?> doc) =>
      AssetModel.fromFirestore(doc);

  @override
  Map<String, dynamic> toJson(AssetModel model) => model.toJson();

  @override
  String idOf(AssetModel model) => model.id;

  @override
  Future<List<AssetModel>> getAssets({required String userId}) =>
      fetchAllForUser(userId);

  @override
  Future<AssetModel> createAsset(AssetModel model) => create(model);

  @override
  Future<AssetModel> updateAsset(AssetModel model) => update(model);

  @override
  Future<void> deleteAsset(String id) => deleteById(id);
}
