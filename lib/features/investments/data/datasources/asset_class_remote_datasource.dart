import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investments/data/models/asset_class_model.dart';

abstract class AssetClassRemoteDataSource {
  Future<List<AssetClassModel>> getAssetClasses({required String userId});
  Future<AssetClassModel> createAssetClass(AssetClassModel model);
  Future<AssetClassModel> updateAssetClass(AssetClassModel model);
  Future<void> deleteAssetClass(String id);
}

class AssetClassRemoteDataSourceImpl implements AssetClassRemoteDataSource {
  AssetClassRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection => _firestore.collection('asset_classes');

  @override
  Future<List<AssetClassModel>> getAssetClasses({
    required String userId,
  }) async {
    try {
      // Single-field `where` only — Firestore would otherwise demand a
      // composite index (`userId` + `name`) just to sort. The DAO
      // already orders by `name` when handing rows to the cubit, so we
      // skip the remote ordering entirely.
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map(AssetClassModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to fetch asset classes.');
    }
  }

  @override
  Future<AssetClassModel> createAssetClass(AssetClassModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return AssetClassModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create asset class.');
    }
  }

  @override
  Future<AssetClassModel> updateAssetClass(AssetClassModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return AssetClassModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update asset class.');
    }
  }

  @override
  Future<void> deleteAssetClass(String id) async {
    try {
      await _collection.doc(id).delete();
    } on Exception {
      throw const ServerException('Failed to delete asset class.');
    }
  }
}
