import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/accounts/data/models/account_model.dart';

abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> getAccounts({required String userId});
  Future<AccountModel> getAccount(String id);
  Future<AccountModel> createAccount(AccountModel model);
  Future<AccountModel> updateAccount(AccountModel model);
  Future<void> deleteAccount(String id);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  AccountRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection => _firestore.collection('accounts');

  @override
  Future<List<AccountModel>> getAccounts({required String userId}) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt')
          .get();
      return snapshot.docs.map(AccountModel.fromFirestore).toList();
    } on Exception {
      throw const ServerException('Failed to fetch accounts.');
    }
  }

  @override
  Future<AccountModel> getAccount(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      return AccountModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to fetch account.');
    }
  }

  @override
  Future<AccountModel> createAccount(AccountModel model) async {
    try {
      final docRef = await _collection.add(model.toJson());
      final doc = await docRef.get();
      return AccountModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to create account.');
    }
  }

  @override
  Future<AccountModel> updateAccount(AccountModel model) async {
    try {
      await _collection.doc(model.id).update(model.toJson());
      final doc = await _collection.doc(model.id).get();
      return AccountModel.fromFirestore(doc);
    } on Exception {
      throw const ServerException('Failed to update account.');
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      await _collection.doc(id).update({'isActive': false});
    } on Exception {
      throw const ServerException('Failed to delete account.');
    }
  }
}
