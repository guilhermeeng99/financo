import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/budgets/data/models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets({required String userId});
  Future<BudgetModel> createBudget(BudgetModel model);
  Future<BudgetModel> updateBudget(BudgetModel model);
  Future<void> deleteBudget(String id);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  BudgetRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection => _firestore.collection('budgets');

  @override
  Future<List<BudgetModel>> getBudgets({required String userId}) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt')
          .get();
      return snapshot.docs.map(BudgetModel.fromFirestore).toList();
    } on Exception catch (e, st) {
      log(
        'getBudgets failed',
        name: 'BudgetRemoteDataSource',
        error: e,
        stackTrace: st,
      );
      throw const ServerException('Failed to fetch budgets.');
    }
  }

  @override
  Future<BudgetModel> createBudget(BudgetModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return BudgetModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create budget.');
    }
  }

  @override
  Future<BudgetModel> updateBudget(BudgetModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return BudgetModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update budget.');
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      await _collection.doc(id).delete();
    } on Exception {
      throw const ServerException('Failed to delete budget.');
    }
  }
}
