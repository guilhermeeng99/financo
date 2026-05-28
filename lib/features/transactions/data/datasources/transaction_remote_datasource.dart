import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/database/firestore_batch.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
  });
  Future<TransactionModel> getTransaction(String id);
  Future<TransactionModel> createTransaction(TransactionModel model);
  Future<TransactionModel> updateTransaction(TransactionModel model);
  Future<void> deleteTransaction(String id);

  /// Deletes both legs of a transfer atomically. WHY: a transfer is two
  /// linked docs; deleting them in separate requests can leave a dangling
  /// half-transfer (one leg gone, the other still pointing at it) that
  /// double-counts in balances.
  Future<void> deleteTransfer(String id, String linkedId);
  Future<List<TransactionModel>> createTransfer({
    required TransactionModel expense,
    required TransactionModel income,
  });
  Future<void> reassignTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  TransactionRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection => _firestore.collection('transactions');

  @override
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? accountId,
  }) async {
    try {
      var query = _collection.where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }
      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (accountId != null) {
        query = query.where('accountId', isEqualTo: accountId);
      }

      query = query.orderBy('date', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map(TransactionModel.fromFirestore).toList();
    } on Exception catch (e, st) {
      log(
        'getTransactions failed',
        name: 'TransactionRemoteDataSource',
        error: e,
        stackTrace: st,
      );
      throw const ServerException('Failed to fetch transactions.');
    }
  }

  @override
  Future<TransactionModel> getTransaction(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      return TransactionModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to fetch transaction.');
    }
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return TransactionModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create transaction.');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return TransactionModel.fromFirestore(doc);
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

  @override
  Future<void> deleteTransfer(String id, String linkedId) async {
    try {
      final batch = _firestore.batch()
        ..delete(_collection.doc(id))
        ..delete(_collection.doc(linkedId));
      await batch.commit();
    } on Exception {
      throw const ServerException('Failed to delete transfer.');
    }
  }

  @override
  Future<List<TransactionModel>> createTransfer({
    required TransactionModel expense,
    required TransactionModel income,
  }) async {
    try {
      // Pre-allocate both refs so each leg can be written with the other's id
      // already set, then commit atomically. WHY: the old sequential
      // add/add/update/update could drop between writes and leave a leg with
      // a null linkedTransactionId, which cascade-delete then orphans —
      // double-counting balances and mis-classifying 50/30/20 savings.
      final expenseRef = _collection.doc();
      final incomeRef = _collection.doc();

      final batch = _firestore.batch()
        ..set(expenseRef, {
          ...expense.toJson(),
          'linkedTransactionId': incomeRef.id,
        })
        ..set(incomeRef, {
          ...income.toJson(),
          'linkedTransactionId': expenseRef.id,
        });
      await batch.commit();

      final expenseDoc = await expenseRef.get();
      final incomeDoc = await incomeRef.get();

      return [
        TransactionModel.fromFirestore(expenseDoc),
        TransactionModel.fromFirestore(incomeDoc),
      ];
    } on Exception {
      throw const ServerException('Failed to create transfer.');
    }
  }

  @override
  Future<void> reassignTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    try {
      final snapshot = await _collection
          .where('categoryId', isEqualTo: fromCategoryId)
          .get();
      // Chunked: a category with >500 transactions would blow the Firestore
      // 500-op batch cap if updated in a single batch.
      await commitInBatches(
        firestore: _firestore,
        docs: snapshot.docs,
        operation: (batch, doc) =>
            batch.update(doc.reference, {'categoryId': toCategoryId}),
      );
    } on Exception {
      throw const ServerException('Failed to reassign transactions.');
    }
  }
}
