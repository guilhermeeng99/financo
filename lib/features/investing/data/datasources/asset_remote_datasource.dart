import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investing/data/models/asset_model.dart';

abstract class AssetRemoteDataSource {
  Future<List<AssetModel>> getAssets({required String userId});
  Future<AssetModel> createAsset(AssetModel model);
  Future<AssetModel> updateAsset(AssetModel model);
  Future<void> deleteAsset(String id);
}

class AssetRemoteDataSourceImpl implements AssetRemoteDataSource {
  AssetRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection =>
      _firestore.collection('investment_assets');

  @override
  Future<List<AssetModel>> getAssets({required String userId}) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map(AssetModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to fetch assets.');
    }
  }

  @override
  Future<AssetModel> createAsset(AssetModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return AssetModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create asset.');
    }
  }

  @override
  Future<AssetModel> updateAsset(AssetModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return AssetModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update asset.');
    }
  }

  @override
  Future<void> deleteAsset(String id) async {
    try {
      await _collection.doc(id).delete();
    } on Exception {
      throw const ServerException('Failed to delete asset.');
    }
  }
}
