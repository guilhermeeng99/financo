import 'package:cloud_firestore/cloud_firestore.dart';
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
    } on Exception {
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
}
