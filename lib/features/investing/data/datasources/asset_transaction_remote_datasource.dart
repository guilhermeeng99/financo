import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investing/data/models/asset_transaction_model.dart';

abstract class AssetTransactionRemoteDataSource {
  Future<List<AssetTransactionModel>> getTransactions({
    required String userId,
  });
  Future<AssetTransactionModel> createTransaction(AssetTransactionModel model);
  Future<AssetTransactionModel> updateTransaction(AssetTransactionModel model);
  Future<void> deleteTransaction(String id);
}

class AssetTransactionRemoteDataSourceImpl
    implements AssetTransactionRemoteDataSource {
  AssetTransactionRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection =>
      _firestore.collection('investment_transactions');

  @override
  Future<List<AssetTransactionModel>> getTransactions({
    required String userId,
  }) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map(AssetTransactionModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to fetch transactions.');
    }
  }

  @override
  Future<AssetTransactionModel> createTransaction(
    AssetTransactionModel model,
  ) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return AssetTransactionModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create transaction.');
    }
  }

  @override
  Future<AssetTransactionModel> updateTransaction(
    AssetTransactionModel model,
  ) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return AssetTransactionModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update transaction.');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _collection.doc(id).delete();
    } on Exception {
      throw const ServerException('Failed to delete transaction.');
    }
  }
}
