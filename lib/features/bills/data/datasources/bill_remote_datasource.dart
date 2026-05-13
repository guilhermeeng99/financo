import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/bills/data/models/bill_model.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';

abstract class BillRemoteDataSource {
  Future<List<BillModel>> getBills({
    required String userId,
    BillStatus? status,
  });
  Future<BillModel> getBill(String id);
  Future<BillModel> createBill(BillModel model);
  Future<BillModel> updateBill(BillModel model);
  Future<void> deleteBill(String id);

  /// Atomic update of [models] in a single Firestore `WriteBatch`. Either
  /// every document is updated or none — used by the "propagate edit to
  /// future occurrences" flow where a partial write would leave the chain
  /// half-rewritten with the old amount on the tail end.
  Future<void> updateBillsBatch(List<BillModel> models);
}

class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  BillRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection => _firestore.collection('bills');

  @override
  Future<List<BillModel>> getBills({
    required String userId,
    BillStatus? status,
  }) async {
    try {
      var query = _collection.where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('dueDate');

      final snapshot = await query.get();
      return snapshot.docs.map(BillModel.fromFirestore).toList();
    } on Exception catch (e, st) {
      log(
        'getBills failed',
        name: 'BillRemoteDataSource',
        error: e,
        stackTrace: st,
      );
      throw const ServerException('Failed to fetch bills.');
    }
  }

  @override
  Future<BillModel> getBill(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      return BillModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to fetch bill.');
    }
  }

  @override
  Future<BillModel> createBill(BillModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return BillModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create bill.');
    }
  }

  @override
  Future<BillModel> updateBill(BillModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return BillModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update bill.');
    }
  }

  @override
  Future<void> deleteBill(String id) async {
    try {
      await _collection.doc(id).delete();
    } on Exception {
      throw const ServerException('Failed to delete bill.');
    }
  }

  @override
  Future<void> updateBillsBatch(List<BillModel> models) async {
    if (models.isEmpty) return;
    try {
      final batch = _firestore.batch();
      for (final model in models) {
        batch.update(_collection.doc(model.id), model.toJson());
      }
      await batch.commit();
    } on Exception catch (e, st) {
      log(
        'updateBillsBatch failed',
        name: 'BillRemoteDataSource',
        error: e,
        stackTrace: st,
      );
      throw const ServerException('Failed to update bills.');
    }
  }
}
