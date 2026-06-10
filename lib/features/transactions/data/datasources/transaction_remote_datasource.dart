import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/database/firestore_batch.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueStartDate,
    DateTime? dueEndDate,
    String? categoryId,
    String? accountId,
    TransactionSettlementStatus? settlementStatus,
    TransactionRecurrence? recurrence,
    String? recurrenceGroupId,
  });
  Future<TransactionModel> getTransaction(String id);
  Future<TransactionModel> createTransaction(TransactionModel model);
  Future<List<TransactionModel>> createTransactions(
    List<TransactionModel> models,
  );
  Future<TransactionModel> updateTransaction(TransactionModel model);
  Future<List<TransactionModel>> updateTransactions(
    List<TransactionModel> models,
  );
  Future<void> deleteTransaction(String id);
  Future<void> deleteTransactions(List<String> ids);

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
    DateTime? dueStartDate,
    DateTime? dueEndDate,
    String? categoryId,
    String? accountId,
    TransactionSettlementStatus? settlementStatus,
    TransactionRecurrence? recurrence,
    String? recurrenceGroupId,
  }) async {
    try {
      var query = _collection.where('userId', isEqualTo: userId);
      final dateField = dueStartDate != null || dueEndDate != null
          ? 'dueDate'
          : 'date';

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
      if (dueStartDate != null) {
        query = query.where(
          'dueDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dueStartDate),
        );
      }
      if (dueEndDate != null) {
        query = query.where(
          'dueDate',
          isLessThanOrEqualTo: Timestamp.fromDate(dueEndDate),
        );
      }
      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (accountId != null) {
        query = query.where('accountId', isEqualTo: accountId);
      }
      if (settlementStatus != null) {
        query = query.where(
          'settlementStatus',
          isEqualTo: settlementStatus.name,
        );
      }
      if (recurrence != null) {
        query = query.where('recurrence', isEqualTo: recurrence.name);
      }
      if (recurrenceGroupId != null) {
        query = query.where(
          'recurrenceGroupId',
          isEqualTo: recurrenceGroupId,
        );
      }

      query = query.orderBy(dateField, descending: true);

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
  Future<List<TransactionModel>> createTransactions(
    List<TransactionModel> models,
  ) async {
    if (models.isEmpty) return [];
    try {
      final refs = [
        for (final model in models)
          model.id.isEmpty ? _collection.doc() : _collection.doc(model.id),
      ];
      final batch = _firestore.batch();
      for (var i = 0; i < models.length; i++) {
        batch.set(refs[i], models[i].toJson());
      }
      await batch.commit();

      final docs = await Future.wait(refs.map((ref) => ref.get()));
      return docs.map(TransactionModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to create transactions.');
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
  Future<List<TransactionModel>> updateTransactions(
    List<TransactionModel> models,
  ) async {
    if (models.isEmpty) return [];
    try {
      final batch = _firestore.batch();
      for (final model in models) {
        batch.update(_collection.doc(model.id), model.toJson());
      }
      await batch.commit();

      final docs = await Future.wait(
        models.map((model) => _collection.doc(model.id).get()),
      );
      return docs.map(TransactionModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to update transactions.');
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
  Future<void> deleteTransactions(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_collection.doc(id));
      }
      await batch.commit();
    } on Exception {
      throw const ServerException('Failed to delete transactions.');
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
