import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investments/data/models/asset_holding_model.dart';

abstract class AssetHoldingRemoteDataSource {
  Future<List<AssetHoldingModel>> getAssetHoldings({required String userId});
  Future<AssetHoldingModel> createAssetHolding(AssetHoldingModel model);
  Future<AssetHoldingModel> updateAssetHolding(AssetHoldingModel model);
  Future<void> deleteAssetHolding(String id);
  Future<void> deleteHoldingsForAccount({
    required String userId,
    required String accountId,
  });
  Future<void> deleteHoldingsForClass({
    required String userId,
    required String classId,
  });
}

class AssetHoldingRemoteDataSourceImpl implements AssetHoldingRemoteDataSource {
  AssetHoldingRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection =>
      _firestore.collection('asset_holdings');

  @override
  Future<List<AssetHoldingModel>> getAssetHoldings({
    required String userId,
  }) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map(AssetHoldingModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to fetch asset holdings.');
    }
  }

  @override
  Future<AssetHoldingModel> createAssetHolding(AssetHoldingModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return AssetHoldingModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create asset holding.');
    }
  }

  @override
  Future<AssetHoldingModel> updateAssetHolding(AssetHoldingModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return AssetHoldingModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update asset holding.');
    }
  }

  @override
  Future<void> deleteAssetHolding(String id) async {
    try {
      await _collection.doc(id).delete();
    } on Exception {
      throw const ServerException('Failed to delete asset holding.');
    }
  }

  @override
  Future<void> deleteHoldingsForAccount({
    required String userId,
    required String accountId,
  }) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('accountId', isEqualTo: accountId)
          .get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on Exception {
      throw const ServerException(
        'Failed to remove holdings for the deleted account.',
      );
    }
  }

  @override
  Future<void> deleteHoldingsForClass({
    required String userId,
    required String classId,
  }) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('assetClassId', isEqualTo: classId)
          .get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on Exception {
      throw const ServerException(
        'Failed to remove holdings for the deleted asset class.',
      );
    }
  }
}
